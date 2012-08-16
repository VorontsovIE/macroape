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
require 'macroape/cli'

begin
  Macroape::CLI::FindThreshold.main(ARGV, help_string)
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end