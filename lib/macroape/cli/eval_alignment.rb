require 'macroape'

module Macroape
  module CLI
    module EvalAlignment
    
      def self.main(argv)
        help_string = %q{
        Command-line format:
        ruby eval_alignment.rb <1st matrix pat-file> <2nd matrix pat-file> <shift> <orientation(direct/revcomp)> [options]
        type <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_alignment.rb .stdin .stdin <shift> <orientation(direct/revcomp)> [options]
             or in linux
        cat <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_alignment.rb .stdin .stdin <shift> <orientation(direct/revcomp)> [options]

        Options:
          [-p <P-value>]
          [-d <discretization level>]
          [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

        Output format:
          <jaccard similarity coefficient>
          <number of words recognized by both 1st and 2nd matrices | probability to draw a word recognized by both 1st and 2nd matrices> <length of the given alignment>
          <aligned 1st matrix>
          <aligned 2nd matrix>
          <shift> <orientation>

        Examples:
          ruby eval_alignment.rb motifs/KLF4_f2.pat motifs/SP1_f1.pat -1 direct -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or on windows
          type motifs/SP1.pat | ruby eval_alignment.rb motifs/KLF4.pat .stdin 0 revcomp -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or in linux
          cat motifs/KLF4.pat motifs/SP1.pat | ruby eval_alignment.rb .stdin .stdin 3 direct -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
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


        first_file = argv.shift
        second_file = argv.shift

        shift = argv.shift
        orientation = argv.shift

        raise "You'd specify two input sources (each is filename or .stdin)" unless first_file and second_file
        raise 'You\'d specify shift' unless shift
        raise 'You\'d specify orientation' unless orientation

        shift = shift.to_i
        orientation = orientation.to_sym

        case orientation
          when :direct
            reverse = false
          when :revcomp
            reverse = true
          else
            raise 'Unknown orientation(direct/revcomp)'
        end


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

      #  if first_file == '.stdin' || second_file == '.stdin'
      #    r_stream, w_stream = IO.pipe
      #    STDIN.readlines.each{|line| w_stream.write(line)}
      #    w_stream.close
      #  end

        if first_file == '.stdin'
      #    r_stream, w_stream, extracted_pwm = extract_pwm(r_stream, w_stream)
      #    pwm_first = Macroape::SingleMatrix.load_from_line_array(extracted_pwm)
        else
          raise "Error! File #{first_file} don't exist" unless File.exist?(first_file)
          pwm_first = Bioinform::PWM.new(File.read(first_file))
        end

        if second_file == '.stdin'
      #    r_stream, w_stream, extracted_pwm = extract_pwm(r_stream, w_stream)
      #    pwm_second = Macroape::SingleMatrix.load_from_line_array(extracted_pwm)
        else
          raise "Error! File #{second_file} don't exist" unless File.exist?(second_file)
          pwm_second = Bioinform::PWM.new(File.read(second_file))
        end

      #  r_stream.close if first_file == '.stdin' || second_file == '.stdin'
        
        pwm_first = pwm_first.background(first_background).max_hash_size(max_hash_size).discrete(discretization)
        pwm_second = pwm_second.background(second_background).max_hash_size(max_hash_size).discrete(discretization)

        cmp = Macroape::PWMCompareAligned.new(pwm_first, pwm_second, shift, orientation).max_hash_size(max_pair_hash_size)

        first_threshold = pwm_first.threshold(pvalue)
        second_threshold = pwm_second.threshold(pvalue)

        info = cmp.alignment_infos.merge( cmp.jaccard(first_threshold, second_threshold) )

        puts "#{info[:similarity]}\n#{info[:recognized_by_both]}\t#{info[:alignment_length]}\n#{info[:text]}\n#{info[:shift]}\t#{info[:orientation]}"

      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end