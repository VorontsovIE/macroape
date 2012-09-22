require_relative '../../macroape'
require 'yaml'

module Macroape
  module CLI
    module ScanCollection

      def self.main(argv)
        doc = %q{
        Command-line format:
        ruby scan_collection.rb <pat-file> <collection> [options]
                or in linux
        cat <pat-file> | ruby scan_collection.rb .stdin <collection> [options]
                or on windows
        type <pat-file> | ruby scan_collection.rb .stdin <collection> [options]

        Options:
          [-p <P-value>]
          [-c <similarity cutoff (minimal similarity to be included in output)> ] or [--all], '-c 0.05' by default
          [--precise [<level, minimal similarity to check on a more precise discretization level on the second pass>]], off by default, '--precise 0.01' if level is not set
          [--silent] - don't show current progress information during scan (by default this information's written into stderr)

        Output format:
         <name> <similarity jaccard index> <shift> <overlap> <orientation> * [in case that result calculated on the second pass(in precise mode)]
            Attention! Name can contain whitespace characters.
            Attention! The shift and orientation are reported for the collection matrix relative to the query matrix.

        Example:
          ruby scan_collection.rb motifs/KLF4.pat collection.yaml -p 0.005
                    or in linux
          cat motifs/KLF4.pat | ruby scan_collection.rb .stdin collection.yaml -p 0.005 --precise 0.03
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM
        filename = argv.shift
        collection_file = argv.shift
        raise "No input. You'd specify input source for pat: filename or .stdin" unless filename
        raise "No input. You'd specify input file with collection" unless collection_file
        raise "Collection file #{collection_file} doesn't exist" unless File.exist?(collection_file)

        pvalue = 0.0005
        cutoff = 0.05 # minimal similarity to output
        collection = YAML.load_file(collection_file)
        background_query = collection.parameters.background
        max_hash_size = 1000000
        max_pair_hash_size = 1000

        silent = false
        precision_mode = :rough
        until argv.empty?
          case argv.shift
            when '-bq'
              background_query = argv.shift(4).map(&:to_f)
              raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless background_query == background_query.reverse
            when '-p'
              pvalue = argv.shift.to_f
            when '-m'
              max_hash_size = argv.shift.to_i
            when '-md'
              max_pair_hash_size = argv.shift.to_i
            when '-c'
              cutoff = argv.shift.to_f
            when '--all'
              cutoff = 0.0
            when '--silent'
              silent = true
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

        raise "Thresholds for pvalue #{pvalue} aren't presented in collection (#{collection.parameters.pvalues.join(', ')}). Use one of listed pvalues or recalculate the collection with needed pvalue" unless collection.parameters.pvalues.include? pvalue

        if filename == '.stdin'
          query_input = $stdin.read
        else
          raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
          query_input = File.read(filename)
        end

        query_pwm = data_model.new(query_input).to_pwm
        query_pwm.set_parameters(background: background_query, max_hash_size: max_hash_size)

        query_pwm_rough = query_pwm.discrete(collection.parameters.rough_discretization)
        query_pwm_precise = query_pwm.discrete(collection.parameters.precise_discretization)

        query_threshold_rough, query_rough_real_pvalue = query_pwm_rough.threshold_and_real_pvalue(pvalue)
        query_threshold_precise, query_precise_real_pvalue = query_pwm_precise.threshold_and_real_pvalue(pvalue)

        if query_precise_real_pvalue == 0
          $stderr.puts "Query motif #{query_pwm.name} gives 0 recognized words for a given P-value of #{pvalue} with the precise discretization level of #{collection.parameters.precise_discretization}. It's impossible to scan collection for this motif"
          return
        end

        if query_rough_real_pvalue == 0
          query_pwm_rough, query_threshold_rough = query_pwm_precise, query_threshold_precise
          $stderr.puts "Query motif #{query_pwm.name} gives 0 recognized words for a given P-value of #{pvalue} with the rough discretization level of #{collection.parameters.rough_discretization}. Forcing precise discretization level of #{collection.parameters.precise_discretization}"
        end

        similarities = {}
        precision_file_mode = {}

        collection.each do |motif|
          name = motif.name
          STDERR.puts name unless silent
          motif.set_parameters(background: collection.parameters.background, max_hash_size: max_hash_size)
          if motif.rough
            collection_pwm_rough = motif.pwm.discrete(collection.parameters.rough_discretization)
            collection_threshold_rough = motif.rough[pvalue] * collection.parameters.rough_discretization
            info = Macroape::PWMCompare.new(query_pwm_rough, collection_pwm_rough).set_parameters(max_pair_hash_size: max_pair_hash_size).jaccard(query_threshold_rough, collection_threshold_rough)
            precision_file_mode[name] = :rough
          end
          if !motif.rough || (precision_mode == :precise) && (info[:similarity] >= minimal_similarity)
            collection_pwm_precise = motif.pwm.discrete(collection.parameters.precise_discretization)
            collection_threshold_precise = motif.precise[pvalue] * collection.parameters.precise_discretization
            info = Macroape::PWMCompare.new(query_pwm_precise, collection_pwm_precise).set_parameters(max_pair_hash_size: max_pair_hash_size).jaccard(query_threshold_precise, collection_threshold_precise)
            precision_file_mode[name] = :precise
          end
          similarities[name] = info
        end

        puts "#pwm\tsimilarity\tshift\toverlap\torientation"
        similarities.sort_by do |name, info|
          info[:similarity]
        end.reverse.each do |name, info|
          precision_text = (precision_file_mode[name] == :precise) ? "\t*" : ""
          puts "#{name}\t#{info[:similarity]}\t#{info[:shift]}\t#{info[:overlap]}\t#{info[:orientation]}#{precision_text}" if info[:similarity] >= cutoff
        end

      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end