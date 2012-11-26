require_relative '../../macroape'

module Macroape
  module CLI
    module FindThreshold

      def self.main(argv)
        doc = %q{
          Command-line format::
          find_threshold <pat-file> [options]

          Options:
            [-p <list of P-values>]
            [-d <discretization level>]
            [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]
            [--weak-threshold]

          Example:
            find_threshold motifs/KLF4.pat -p 0.001 0.0001 0.0005 -d 1000 -b 0.4 0.3 0.2 0.1
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        background = [1,1,1,1]
        default_pvalues = [0.0005]
        discretization = 10000
        max_hash_size = 1000000
        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM
        strong_threshold = true

        filename = argv.shift
        raise 'No input. You should specify input file' unless filename

        pvalues = []
        until argv.empty?
          case argv.shift
            when '-b'
              background = argv.shift(4).map(&:to_f)
            when '-m'
              max_hash_size = argv.shift.to_i
            when '-p'
              loop do
                begin
                  Float(argv.first)
                  pvalues << argv.shift.to_f
                rescue
                  raise StopIteration
                end
              end
            when '-d'
              discretization = argv.shift.to_f
            when '--weak-threshold'
              strong_threshold = false
            end
        end
        pvalues = default_pvalues if pvalues.empty?

        if filename == '.stdin'
          input = $stdin.read
        else
          raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
          input = File.read(filename)
        end
        pwm = data_model.new(input).to_pwm
        pwm.set_parameters(background: background, max_hash_size: max_hash_size).discrete!(discretization)

        infos = []
        collect_infos_proc = ->(pvalue, threshold, real_pvalue) do
          infos << {expected_pvalue: pvalue,
                    threshold: threshold / discretization,
                    real_pvalue: real_pvalue,
                    recognized_words: pwm.vocabulary_volume * real_pvalue }
        end
        if strong_threshold
          pwm.thresholds(*pvalues, &collect_infos_proc)
        else
          pwm.weak_thresholds(*pvalues, &collect_infos_proc)
        end
        puts Helper.threshold_infos_string(infos)
      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end