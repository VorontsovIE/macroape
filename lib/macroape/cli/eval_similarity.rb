require 'macroape'

module Macroape
  module CLI
    module EvalSimilarity
    
      def self.main(argv)
        help_string = %q{
        Command-line format:
        ruby eval_similarity.rb <1st matrix pat-file> <2nd matrix pat-file> [options]
             or on windows
        type <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_similarity.rb .stdin .stdin [options]
             or in linux
        cat <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_similarity.rb .stdin .stdin [options]

        Options:
          [-p <P-value>]
          [-d <discretization level>]
          [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

        Output has format:
          <jaccard similarity coefficient>
          <number of words recognized by both 1st and 2nd matrices | probability to draw a word recognized by both 1st and 2nd matrices> <length of the optimal alignment>
          <optimal alignment, the 1st matrix>
          <optimal alignment, the 2nd matrix>
          <shift> <orientation>

        Examples:
          ruby eval_similarity.rb motifs/KLF4.pat motifs/SP1.pat -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or on windows
          type motifs/SP1.pat | ruby eval_similarity.rb motifs/KLF4.pat .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or in linux
          cat motifs/KLF4.pat motifs/SP1.pat | ruby eval_similarity.rb .stdin .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
        }

        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts help_string
          exit
        end

        pvalue = 0.0005
        discretization = 10

        first_background = [1,1,1,1]
        second_background = [1,1,1,1]

        max_hash_size = 1000000
        max_pair_hash_size = 1000

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM      
        first_file = argv.shift
        second_file = argv.shift
        raise "You'd specify two input sources (each is filename or .stdin)" unless first_file and second_file

        until argv.empty?
          case argv.shift
            when '-p'
              pvalue = argv.shift.to_f
            when '-d'
              discretization = argv.shift.to_f
            when '-m'
              max_hash_size = argv.shift.to_i
            when '-md'
              max_pair_hash_size = argv.shift.to_i
            when '-b'
              second_background = first_background = argv.shift(4).map(&:to_f)
            when '-b1'
              first_background = argv.shift(4).map(&:to_f)
            when '-b2'
              second_background = argv.shift(4).map(&:to_f)
          end
        end
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless first_background == first_background.reverse
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless second_background == second_background.reverse

        parser = Bioinform::StringParser.new($stdin.read)  if first_file == '.stdin' || second_file == '.stdin'
        
        if first_file == '.stdin'
          input_first = parser.parse
        else
          raise "Error! File #{first_file} don't exist" unless File.exist?(first_file)
          input_first = File.read(first_file)
        end
        pwm_first = data_model.new(input_first).to_pwm

        if second_file == '.stdin'
          input_second = parser.parse
        else
          raise "Error! File #{second_file} don't exist" unless File.exist?(second_file)
          input_second = File.read(second_file)
        end
        pwm_second = data_model.new(input_second).to_pwm
        
        pwm_first.background!(first_background).max_hash_size!(max_hash_size).discrete!(discretization)
        pwm_second.background!(second_background).max_hash_size!(max_hash_size).discrete!(discretization)

        cmp = Macroape::PWMCompare.new(pwm_first, pwm_second).max_hash_size(max_pair_hash_size)

        info = cmp.jaccard_by_pvalue(pvalue)

        puts "#{info[:similarity]}\n#{info[:recognized_by_both]}\t#{info[:alignment_length]}\n#{info[:text]}\n#{info[:shift]}\t#{info[:orientation]}"

      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"      
      end
      
    end
  end
end