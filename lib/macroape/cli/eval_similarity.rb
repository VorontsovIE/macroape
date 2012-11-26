require_relative '../../macroape'

module Macroape
  module CLI
    module EvalSimilarity

      def self.main(argv)
        doc = %q{
        Command-line format:
        eval_similarity <1st matrix pat-file> <2nd matrix pat-file> [options]
             or on windows
        type <1st matrix pat-file> <2nd matrix pat-file> | eval_similarity .stdin .stdin [options]
             or in linux
        cat <1st matrix pat-file> <2nd matrix pat-file> | eval_similarity .stdin .stdin [options]

        Options:
          [-p <P-value>]
          [-d <discretization level>]
          [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]
          [--strong-threshold]
          [--first-threshold <threshold for the first matrix>]
          [--second-threshold <threshold for the second matrix>]

        Examples:
          eval_similarity motifs/KLF4.pat motifs/SP1.pat -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or on windows
          type motifs/SP1.pat | eval_similarity motifs/KLF4.pat .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
             or in linux
          cat motifs/KLF4.pat motifs/SP1.pat | eval_similarity .stdin .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        pvalue = 0.0005
        discretization = 10

        first_background = [1,1,1,1]
        second_background = [1,1,1,1]

        max_hash_size = 1000000
        max_pair_hash_size = 1000
        strong_threshold = false

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM
        first_file = argv.shift
        second_file = argv.shift
        raise 'You should specify two input files' unless first_file and second_file

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
            when '--strong-threshold'
              strong_threshold = true
            when '--first-threshold'
              threshold_first = argv.shift.to_f
            when '--second-threshold'
              threshold_second = argv.shift.to_f
          end
        end
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless first_background == first_background.reverse
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless second_background == second_background.reverse

        if first_file == '.stdin' || second_file == '.stdin'
          input = $stdin.read
          parser = data_model.choose_parser(input).new(input)
        end

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

        pwm_first.set_parameters(background: first_background, max_hash_size: max_hash_size).discrete!(discretization)
        pwm_second.set_parameters(background: second_background, max_hash_size: max_hash_size).discrete!(discretization)

        cmp = Macroape::PWMCompare.new(pwm_first, pwm_second).set_parameters(max_pair_hash_size: max_pair_hash_size)

        if threshold_first
          threshold_first *= discretization
        else
          if strong_threshold
            threshold_first = pwm_first.threshold(pvalue)
          else
            threshold_first = pwm_first.weak_threshold(pvalue)
          end
        end

        if threshold_second
          threshold_second *= discretization
        else
          if strong_threshold
            threshold_second = pwm_second.threshold(pvalue)
          else
            threshold_second = pwm_second.weak_threshold(pvalue)
          end
        end

        info = cmp.jaccard(threshold_first, threshold_second)
        info.merge!(threshold_first: threshold_first.to_f / discretization, threshold_second: threshold_second.to_f / discretization)
        puts Helper.similarity_info_string(info)

      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end