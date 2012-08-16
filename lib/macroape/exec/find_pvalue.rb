help_string = %q{
Command-line format:
ruby find_pvalue.rb <pat-file> <threshold list> [options]
        	or in linux
cat <pat-file> | ruby find_pvalue.rb .stdin <threshold> [options]
 	or on windows
type <pat-file> | ruby find_pvalue.rb .stdin <threshold> [options]

Options:
  [-d <discretization level>]
  [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

Output format:
	threshold_1 count_1  pvalue_1
	threshold_2 count_2  pvalue_2
	threshold_3 count_3  pvalue_3
The results are printed out in the same order as in the given threshold list.

Examples:
  ruby find_pvalue.rb motifs/KLF4.pat 7.32 -d 1000 -b 0.2 0.3 0.2 0.3
           or on windows
  type motifs/KLF4.pat | ruby find_pvalue.rb .stdin 7.32 4.31 5.42
           or in linux
  cat motifs/KLF4.pat | ruby find_pvalue.rb .stdin 7.32 4.31 5.42
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape/cli'

begin
  Macroape::CLI::FindPValue.main(ARGV, help_string)
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end