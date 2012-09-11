require 'macroape'
require 'yaml'

module Macroape
  module CLI
    module ScanCollection
    
      def self.main(argv)
        help_string = %q{
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

        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts help_string
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
        query_pwm.background(background_query).max_hash_size(max_hash_size)
        
        query_pwm_rough = query_pwm.discrete(collection.parameters.rough_discretization)
        query_pwm_precise = query_pwm.discrete(collection.parameters.precise_discretization)

        query_threshold_rough = query_pwm_rough.threshold(pvalue)
        query_threshold_precise = query_pwm_precise.threshold(pvalue)

        similarities = {}
        precision_file_mode = {}

        collection.pwms.each_key do |name|
          pwm = collection.pwms[name]
          pwm.background(collection.parameters.background).max_hash_size(max_hash_size)
          pwm_rough = pwm.discrete(collection.parameters.rough_discretization)
          pwm_precise = pwm.discrete(collection.parameters.precise_discretization)
          
          pwm_info = collection.infos[name]
          
          pwm_threshold_rough = pwm_info[:rough][pvalue] * collection.parameters.rough_discretization
          pwm_threshold_precise = pwm_info[:precise][pvalue] * collection.parameters.precise_discretization
          
          
          STDERR.puts pwm.name unless silent
          cmp = Macroape::PWMCompare.new(query_pwm_rough, pwm_rough).max_hash_size(max_pair_hash_size)
          info = cmp.jaccard(query_threshold_rough, pwm_threshold_rough)
          precision_file_mode[name] = :rough

          if precision_mode == :precise and info[:similarity] >= minimal_similarity
            cmp = Macroape::PWMCompare.new(query_pwm_precise, pwm_precise).max_hash_size(max_pair_hash_size)
            info = cmp.jaccard(query_threshold_precise, pwm_threshold_precise)
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