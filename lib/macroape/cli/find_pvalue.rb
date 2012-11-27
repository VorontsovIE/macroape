require_relative '../../macroape'

module Macroape
  module CLI
    module FindPValue

      def self.main(argv)
        doc = %q{
          Command-line format:
          find_pvalue <pat-file> <threshold list>... [options]

          Options:
            [-d <discretization level>]
            [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

          Examples:
            find_pvalue motifs/KLF4.pat 7.32
            find_pvalue motifs/KLF4.pat 7.32 4.31 5.42 -d 1000 -b 0.2 0.3 0.2 0.3
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        discretization = 10000
        background = [1,1,1,1]
        thresholds = []
        max_hash_size = 10000000

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
        infos = []
        thresholds.each do |threshold|
          count = counts[threshold * discretization]
          pvalue = count.to_f / pwm.vocabulary_volume
          infos << {threshold: threshold,
                    number_of_recognized_words: count,
                    pvalue: pvalue}
        end

        puts Helper.find_pvalue_info_string( infos,
                                            {discretization: discretization,
                                            background: background} )
      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end
