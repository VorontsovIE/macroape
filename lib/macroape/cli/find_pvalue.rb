require_relative '../../macroape'

module Macroape
  module CLI
    module FindPValue

      def self.main(argv)
        doc = %q{
          Command-line format:
          find_pvalue <pat-file> <threshold list> [options]
                    or in linux
          cat <pat-file> | find_pvalue .stdin <threshold> [options]
            or on windows
          type <pat-file> | find_pvalue .stdin <threshold> [options]

          Options:
            [-d <discretization level>]
            [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

          Output format:
            threshold_1 count_1  pvalue_1
            threshold_2 count_2  pvalue_2
            threshold_3 count_3  pvalue_3
          The results are printed out in the same order as in the given threshold list.

          Examples:
            find_pvalue motifs/KLF4.pat 7.32 -d 1000 -b 0.2 0.3 0.2 0.3
                     or on windows
            type motifs/KLF4.pat | find_pvalue .stdin 7.32 4.31 5.42
                     or in linux
            cat motifs/KLF4.pat | find_pvalue .stdin 7.32 4.31 5.42
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        discretization = 10000
        background = [1,1,1,1]
        thresholds = []
        max_hash_size = 1000000

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM
        filename = argv.shift

        loop do
          begin
            Float(argv.first)
            thresholds << argv.shift.to_f
          rescue
            raise StopIteration
          end
        end

        raise 'No input. You should specify input file' unless filename
        raise 'You should specify at least one threshold' if thresholds.empty?

        until argv.empty?
          case argv.shift
            when '-b'
              background = argv.shift(4).map(&:to_f)
            when '-d'
              discretization = argv.shift.to_f
            when '-m'
              max_hash_size = argv.shift.to_i
          end
        end


        if filename == '.stdin'
          input = $stdin.read
        else
          raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
          input = File.read(filename)
        end
        pwm = data_model.new(input).to_pwm
        pwm.set_parameters(background: background, max_hash_size: max_hash_size).discrete!(discretization)

        counts = pwm.counts_by_thresholds(* thresholds.map{|count| count * discretization})
        pvalues = counts.map{|count| count.to_f / pwm.vocabulary_volume}
        pvalues.zip(thresholds,counts).each{|pvalue,threshold,count|
          puts "#{threshold}\t#{count}\t#{pvalue}"
        }
      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end
