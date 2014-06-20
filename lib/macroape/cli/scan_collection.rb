require_relative '../../macroape'
require 'yaml'

module Macroape
  module CLI
    module ScanCollection
      def self.main(argv)
        doc = <<-EOS.strip_doc
          Command-line format:
          #{run_tool_cmd} <pat-file> <collection> [options]

          Options:
            [-p <P-value>]
            [-c <similarity cutoff>] minimal similarity to be included in output, '-c 0.05' by default, [--all] to print all results
            [--precise [<level>]] minimal similarity to check on the second pass in precise mode, off by default, '--precise 0.01' if level is not set
            [--silent] - hide current progress information during scan (printed to stderr by default)
            [--pcm] - treat the input file as Position Count Matrix. PCM-to-PWM transformation to be done internally.
            [--boundary lower|upper] Upper boundary (default) means that the obtained P-value is greater than or equal to the requested P-value
            [-b <background probabilities] ACGT - 4 numbers, comma-delimited(spaces not allowed), sum should be equal to 1, like 0.25,0.24,0.26,0.25

          Output format:
           <name> <jaccard index> <shift> <overlap> <orientation> ['*' in case that result was calculated on the second pass (in precise mode), '.' otherwise]
              Attention! Name can contain whitespace characters.
              Attention! The shift and orientation are reported for the collection matrix relative to the query matrix.

          Example:
            #{run_tool_cmd} motifs/KLF4_f2.pat hocomoco_ad_uniform.yaml
            #{run_tool_cmd} motifs/KLF4_f2.pat hocomoco_ad_uniform.yaml -p 0.0005 --precise 0.03
        EOS

        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          $stderr.puts doc
          exit
        end

        data_model = argv.delete('--pcm') ? :pcm : :pwm
        filename = argv.shift
        collection_file = argv.shift
        raise 'No input. You should specify input file with matrix' unless filename
        raise 'No input. You should specify input file with collection' unless collection_file
        raise "Collection file #{collection_file} doesn't exist" unless File.exist?(collection_file)

        pvalue = 0.0005
        cutoff = 0.05 # minimal similarity to output
        collection = YAML.load_file(collection_file)
        collection_background = collection.background #(collection.background == [1,1,1,1]) ? Bioinform::Background::Wordwise : Bioinform::Frequencies.new(collection.background)
        query_background = collection_background

        rough_discretization = collection.rough_discretization
        precise_discretization = collection.precise_discretization
        max_hash_size = 10000000
        max_pair_hash_size = 10000
        pvalue_boundary = :upper

        silent = false
        precision_mode = :rough
        until argv.empty?
          case argv.shift
            when '-b'
              query_background = Bioinform::Background.from_string(argv.shift)
              raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless query_background.symmetric?
            when '-p'
              pvalue = argv.shift.to_f
            when '--max-hash-size'
              max_hash_size = argv.shift.to_i
            when '--max-2d-hash-size'
              max_pair_hash_size = argv.shift.to_i
            when '-c'
              cutoff = argv.shift.to_f
            when '--all'
              cutoff = 0.0
            when '--silent'
              silent = true
            when '--boundary'
              pvalue_boundary = argv.shift.to_sym
              raise 'boundary should be either lower or upper'  unless  pvalue_boundary == :lower || pvalue_boundary == :upper
            when '--precise'
              precision_mode = :precise
              begin
                Float(argv.first)
                minimal_similarity = argv.shift.to_f
              rescue
                minimal_similarity = 0.05
              end
          end
        end

        raise "Thresholds for pvalue #{pvalue} aren't presented in collection (#{collection.pvalues.join(', ')}). Use one of listed pvalues or recalculate the collection with needed pvalue" unless collection.pvalues.include? pvalue

        raise "Error! File #{filename} doesn't exist"  unless File.exist?(filename)
        query_input = File.read(filename)

        query_input = Bioinform::Parser.choose(query_input).parse!(query_input)
        case data_model
        when :pcm
          query_pcm = Bioinform::MotifModel::PCM.new(query_input.matrix).named(query_input.name)
          query_pwm = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(pseudocount: :log, background: query_background).convert(query_pcm)
        when :pwm
          query_pwm = Bioinform::MotifModel::PWM.new(query_input.matrix).named(query_input.name)
        end

        query_pwm_rough = query_pwm.discreted(rough_discretization)
        query_pwm_rough_counting = PWMCounting.new(query_pwm_rough, background: query_background, max_hash_size: max_hash_size)
        query_pwm_precise = query_pwm.discreted(precise_discretization)
        query_pwm_precise_counting = PWMCounting.new(query_pwm_precise, background: query_background, max_hash_size: max_hash_size)

        if pvalue_boundary == :lower
          query_threshold_rough, query_rough_real_pvalue = query_pwm_rough_counting.threshold_and_real_pvalue(pvalue)
          query_threshold_precise, query_precise_real_pvalue = query_pwm_precise_counting.threshold_and_real_pvalue(pvalue)
        else
          query_threshold_rough, query_rough_real_pvalue = query_pwm_rough_counting.weak_threshold_and_real_pvalue(pvalue)
          query_threshold_precise, query_precise_real_pvalue = query_pwm_precise_counting.weak_threshold_and_real_pvalue(pvalue)
        end

        if query_precise_real_pvalue == 0
          $stderr.puts "Query motif #{query_pwm.name} gives 0 recognized words for a given P-value of #{pvalue} with the precise discretization level of #{precise_discretization}. It's impossible to scan collection for this motif"
          return
        end

        if query_rough_real_pvalue == 0
          query_pwm_rough_counting, query_threshold_rough = query_pwm_precise_counting, query_threshold_precise
          $stderr.puts "Query motif #{query_pwm.name} gives 0 recognized words for a given P-value of #{pvalue} with the rough discretization level of #{rough_discretization}. Forcing precise discretization level of #{precise_discretization}"
        end

        similarities = {}
        precision_file_mode = {}

        collection.motifs.each_with_index do |motif_info, index|
          motif = motif_info.model
          $stderr.puts "Testing motif #{motif.name} (#{index+1} of #{collection.size}, #{index*100/collection.size}% complete)"  unless silent

          if motif_info.rough[pvalue]
            collection_pwm_rough = motif.discreted(rough_discretization)
            collection_pwm_rough_counting = Macroape::PWMCounting.new(collection_pwm_rough, background: collection_background, max_hash_size: max_hash_size)

            collection_threshold_rough = motif_info.rough[pvalue] * rough_discretization
            info = Macroape::PWMCompare.new(query_pwm_rough_counting, collection_pwm_rough_counting).tap{|x| x.max_pair_hash_size = max_pair_hash_size }.jaccard(query_threshold_rough, collection_threshold_rough)
            info[:precision_mode] = :rough
          end
          if !motif_info.rough[pvalue] || (precision_mode == :precise) && (info[:similarity] >= minimal_similarity)
            collection_pwm_precise = motif.discreted(precise_discretization)
            collection_pwm_precise_counting = Macroape::PWMCounting.new(collection_pwm_precise, background: collection_background, max_hash_size: max_hash_size)

            collection_threshold_precise = motif_info.precise[pvalue] * precise_discretization
            info = Macroape::PWMCompare.new(query_pwm_precise_counting, collection_pwm_precise_counting).tap{|x| x.max_pair_hash_size = max_pair_hash_size }.jaccard(query_threshold_precise, collection_threshold_precise)
            info[:precision_mode] = :precise
          end
          info[:name] = motif.name
          similarities[motif.name] = info
        end

        $stderr.puts "100% complete"  unless silent

        similarities_to_output = similarities.sort_by{|name, info| info[:similarity] }.reverse.select{|name,info| info[:similarity] >= cutoff }.map{|name,info|info}
        puts Helper.scan_collection_infos_string( similarities_to_output,
                                                  {cutoff: cutoff,
                                                  precision_mode: precision_mode,
                                                  rough_discretization: rough_discretization,
                                                  precise_discretization: precise_discretization,
                                                  minimal_similarity: minimal_similarity,
                                                  pvalue: pvalue,
                                                  pvalue_boundary: pvalue_boundary,
                                                  collection_background: collection_background,
                                                  query_background: query_background} )
      rescue => err
        $stderr.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse --help option for help\n\n#{doc}"
      end

    end
  end
end
