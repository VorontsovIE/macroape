help_string = %q{
Command-line format::
ruby find_threshold.rb <pat-file> [options]
        	or in linux
cat <pat-file> | ruby find_threshold.rb .stdin [options]
            or on windows
type <pat-file> | ruby find_threshold.rb .stdin [options]

Options:
  [-p <list of P-values>]
  [-d <discretization level>]
  [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

Output format:
 	requested_pvalue_1 threshold_1 achieved_pvalue_1
 	requested_pvalue_2 threshold_2 achieved_pvalue_2


Example:
  ruby find_threshold.rb motifs/KLF4.pat -p 0.001 0.0001 0.0005 -d 1000 -b 0.4 0.3 0.2 0.1
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape'

if ARGV.empty? or ARGV.include? '-h' or ARGV.include? '-help' or ARGV.include? '--help' or ARGV.include? '--h'
  STDERR.puts help_string
  exit
end

background = [1,1,1,1]
default_pvalues = [0.0005]
discretization = 10000

begin
  filename = ARGV.shift
  raise "No input. You'd specify input source: filename or .stdin" unless filename

  pvalues = []
  until ARGV.empty?
    case ARGV.shift
      when '-b'
        background = ARGV.shift(4).map(&:to_f)
      when '-m'
        Macroape::MaxHashSizeSingle = ARGV.shift.to_f
      when '-p'
        loop do
          begin
            Float(ARGV.first)
            pvalues << ARGV.shift.to_f
          rescue
            raise StopIteration
          end
        end
      when '-d'
        discretization = ARGV.shift.to_f
      end
  end
  pvalues = default_pvalues if pvalues.empty?

  Macroape::MaxHashSizeSingle = 1000000 unless defined? Macroape::MaxHashSizeSingle

  if filename == '.stdin'
##  TODO
  else
    raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
    pwm = Bioinform::PWM.new( File.read(filename) )
  end

  pwm.background(background)

  pwm.discrete(discretization).thresholds(*pvalues) do |pvalue, threshold, real_pvalue|
    puts "#{pvalue}\t#{threshold / discretization}\t#{real_pvalue}"
  end
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end