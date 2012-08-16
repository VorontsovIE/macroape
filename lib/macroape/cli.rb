require 'macroape'

module Macroape
  module CLI
    module FindThreshold
      def self.main(argv, help_string)
        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts help_string
          exit
        end
        
        background = [1,1,1,1]
        default_pvalues = [0.0005]
        discretization = 10000
        max_hash_size = 1000000

        filename = argv.shift
        raise "No input. You'd specify input source: filename or .stdin" unless filename

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
            end
        end
        pvalues = default_pvalues if pvalues.empty?

        if filename == '.stdin'
          pwm = Bioinform::PWM.new( STDIN.read )
        else
          raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
          pwm = Bioinform::PWM.new( File.read(filename) )
        end

        pwm.background(background).max_hash_size(max_hash_size)

        pwm.discrete(discretization).thresholds(*pvalues) do |pvalue, threshold, real_pvalue|
          puts "#{pvalue}\t#{threshold / discretization}\t#{real_pvalue}"
        end

      end
    end
  end
end


module Macroape
  module CLI
      module FindPValue
      def self.main(argv, help_string)
        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts help_string
          exit
        end

        discretization = 10000
        background = [1,1,1,1]
        thresholds = []
        max_hash_size = 1000000

        filename = argv.shift

        loop do
          begin
            Float(argv.first)
            thresholds << argv.shift.to_f
          rescue
            raise StopIteration
          end
        end

        raise "No input. You'd specify input source: filename or .stdin" unless filename
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
          pwm = Bioinform::PWM.new( STDIN.read )
        else
          raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
          pwm = Bioinform::PWM.new( File.read(filename) )
        end
        pwm.background(background).max_hash_size(max_hash_size)

        counts = pwm.discrete(discretization).counts_by_thresholds(* thresholds.map{|count| count * discretization})
        pvalues = counts.map{|count| count.to_f / pwm.vocabulary_volume}
        pvalues.zip(thresholds,counts).each{|pvalue,threshold,count|
          puts "#{threshold}\t#{count}\t#{pvalue}"
        }
      end
      
    end
  end
end
