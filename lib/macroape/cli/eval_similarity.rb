require_relative '../../macroape'

module Macroape
  module CLI
    module EvalSimilarity

      def self.main(argv)
        doc = <<-EOS.strip_doc
        Command-line format:
        #{run_tool_cmd} <1st matrix pat-file> <2nd matrix pat-file> [options]

        Options:
          [-p <P-value>]
          [-d <discretization level>]
          [--pcm] - treat the input file as Position Count Matrix. PCM-to-PWM transformation to be done internally.
          [--boundary lower|upper] Upper boundary (default) means that the obtained P-value is greater than or equal to the requested P-value
          [-b <background probabilities] ACGT - 4 numbers, comma-delimited(spaces not allowed), sum should be equal to 1, like 0.25,0.24,0.26,0.25
          [--first-threshold <threshold for the first matrix>]
          [--second-threshold <threshold for the second matrix>]

        Examples:
          #{run_tool_cmd} motifs/KLF4_f2.pat motifs/SP1_f1.pat -p 0.0005 -d 100 -b 0.3,0.2,0.2,0.3
        EOS

        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          $stderr.puts doc
          exit
        end

        pvalue = 0.0005
        discretization = 10.0

        first_background = Bioinform::Background::Wordwise
        second_background = Bioinform::Background::Wordwise

        max_hash_size = 10000000
        max_pair_hash_size = 10000
        pvalue_boundary = :upper

        data_model = argv.delete('--pcm') ? :pcm : :pwm
        first_file = argv.shift
        second_file = argv.shift
        raise 'You should specify two input files' unless first_file and second_file

        until argv.empty?
          case argv.shift
            when '-p'
              pvalue = argv.shift.to_f
            when '-d'
              discretization = argv.shift.to_f
            when '--max-hash-size'
              max_hash_size = argv.shift.to_i
            when '--max-2d-hash-size'
              max_pair_hash_size = argv.shift.to_i
            when '-b'
              second_background = first_background = Bioinform::Background.from_string(argv.shift)
            when '-b1'
              first_background = Bioinform::Background.from_string(argv.shift)
            when '-b2'
              second_background = Bioinform::Background.from_string(argv.shift)
            when '--boundary'
              pvalue_boundary = argv.shift.to_sym
              raise 'boundary should be either lower or upper'  unless  pvalue_boundary == :lower || pvalue_boundary == :upper
            when '--first-threshold'
              predefined_threshold_first = argv.shift.to_f
            when '--second-threshold'
              predefined_threshold_second = argv.shift.to_f
          end
        end
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless first_background.symmetric?
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless second_background.symmetric?

        if first_file == '.stdin' || second_file == '.stdin'
          input = $stdin.read
          parser = Bioinform::Parser.choose_for_collection(input) ## for_collection  or simple parser?
          stdin_multi_parser = Bioinform::CollectionParser.new(parser, input)
        end

        if first_file == '.stdin'
          input_first = stdin_multi_parser.parse
        else
          raise "Error! File #{first_file} don't exist" unless File.exist?(first_file)
          input_first = File.read(first_file)
          input_first = Bioinform::Parser.choose(input_first).parse!(input_first)
        end

        if second_file == '.stdin'
          input_second = stdin_multi_parser.parse
        else
          raise "Error! File #{second_file} don't exist" unless File.exist?(second_file)
          input_second = File.read(second_file)
          input_second = Bioinform::Parser.choose(input_second).parse!(input_second)
        end

        case data_model
        when :pcm
          pcm_first = Bioinform::MotifModel::PCM.new(input_first.matrix).named(input_first.name)
          pwm_first = Bioinform::ConversionAlgorithms::PCM2PWMConverter_.new(pseudocount: :log, background: first_background).convert(pcm_first)
          pcm_second = Bioinform::MotifModel::PCM.new(input_second.matrix).named(input_second.name)
          pwm_second = Bioinform::ConversionAlgorithms::PCM2PWMConverter_.new(pseudocount: :log, background: second_background).convert(pcm_second)
        when :pwm
          pwm_first = Bioinform::MotifModel::PWM.new(input_first.matrix).named(input_first.name)
          pwm_second = Bioinform::MotifModel::PWM.new(input_second.matrix).named(input_second.name)
        end

        pwm_first = pwm_first.discreted(discretization)
        pwm_second = pwm_second.discreted(discretization)

        counting_first = PWMCounting.new(pwm_first, background: first_background, max_hash_size: max_hash_size)
        counting_second = PWMCounting.new(pwm_second, background: second_background, max_hash_size: max_hash_size)

        cmp = Macroape::PWMCompare.new(counting_first, counting_second).tap{|x| x.max_pair_hash_size = max_pair_hash_size }

        if predefined_threshold_first
          threshold_first = predefined_threshold_first * discretization
        else
          if pvalue_boundary == :lower
            threshold_first = counting_first.threshold(pvalue)
          else
            threshold_first = counting_first.weak_threshold(pvalue)
          end
        end

        if predefined_threshold_second
          threshold_second = predefined_threshold_second * discretization
        else
          if pvalue_boundary == :lower
            threshold_second = counting_second.threshold(pvalue)
          else
            threshold_second = counting_second.weak_threshold(pvalue)
          end
        end

        info = cmp.jaccard(threshold_first, threshold_second)
        info.merge!(predefined_threshold_first: predefined_threshold_first,
                    predefined_threshold_second: predefined_threshold_second,
                    threshold_first: threshold_first.to_f / discretization,
                    threshold_second: threshold_second.to_f / discretization,
                    discretization: discretization,
                    first_background: first_background,
                    second_background: second_background,
                    requested_pvalue: pvalue,
                    pvalue_boundary: pvalue_boundary)
        puts Helper.similarity_info_string(info)

      rescue => err
        $stderr.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse --help option for help\n\n#{doc}"
      end

    end
  end
end
