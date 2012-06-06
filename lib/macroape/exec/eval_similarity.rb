help_string = %q{
Command-line format:
ruby eval_similarity.rb <1st matrix pat-file> <2nd matrix pat-file> [options]
     or on windows
type <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_similarity.rb .stdin .stdin [options]
     or in linux
cat <1st matrix pat-file> <2nd matrix pat-file> | ruby eval_similarity.rb .stdin .stdin [options]

Options:
  [-p <P-value>]
  [-d <discretization level>]
  [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]

Output has format:
  <jaccard similarity coefficient>
  <number of words recognized by both 1st and 2nd matrices | probability to draw a word recognized by both 1st and 2nd matrices> <length of the optimal alignment>
  <optimal alignment, the 1st matrix>
  <optimal alignment, the 2nd matrix>
  <shift> <orientation>
 
Examples:  
  ruby eval_similarity.rb motifs/KLF4.pat motifs/SP1.pat -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
     or on windows 
  type motifs/SP1.pat | ruby eval_similarity.rb motifs/KLF4.pat .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
     or in linux
  cat motifs/KLF4.pat motifs/SP1.pat | ruby eval_similarity.rb .stdin .stdin -p 0.0005 -d 100 -b 0.4 0.3 0.2 0.1
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape'

if ARGV.empty? or ARGV.include? '-h' or ARGV.include? '-help' or ARGV.include? '--help' or ARGV.include? '--h'
  STDERR.puts help_string
  exit
end

pvalue = 0.0005
discretization = 10

first_background = [1,1,1,1]
second_background = [1,1,1,1]

begin 
  first_file = ARGV.shift
  second_file = ARGV.shift
  raise "You'd specify two input sources (each is filename or .stdin)" unless first_file and second_file

  until ARGV.empty?
    case ARGV.shift
      when '-p'
        pvalue = ARGV.shift.to_f
      when '-d'
        discretization = ARGV.shift.to_f
      when '-m'
        Macroape::MaxHashSizeSingle = ARGV.shift.to_f
      when '-md'
        Macroape::MaxHashSizeDouble = ARGV.shift.to_f
      when '-b'
        second_background = first_background = ARGV.shift(4).map(&:to_f)
      when '-b1'
        first_background = ARGV.shift(4).map(&:to_f)
      when '-b2'
        second_background = ARGV.shift(4).map(&:to_f)      
    end
  end
  raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless first_background == first_background.reverse
  raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless second_background == second_background.reverse
  
  Macroape::MaxHashSizeSingle = 1000000 unless defined? Macroape::MaxHashSizeSingle
  Macroape::MaxHashSizeDouble = 1000 unless defined? Macroape::MaxHashSizeDouble
  
  
  if first_file == '.stdin' || second_file == '.stdin'
    r_stream, w_stream = IO.pipe
    STDIN.readlines.each{|line| w_stream.write(line)}
    w_stream.close
  end
  
  if first_file == '.stdin'
    r_stream, w_stream, extracted_pwm = extract_pwm(r_stream, w_stream)
    pwm_first = Macroape::SingleMatrix.load_from_line_array(extracted_pwm).with_background(first_background).discrete(discretization)
  else
    raise "Error! File #{first_file} don't exist" unless File.exist?(first_file)
    pwm_first = Macroape::SingleMatrix.load_pat(first_file).with_background(first_background).discrete(discretization)
  end
  
  if second_file == '.stdin'
    r_stream, w_stream, extracted_pwm = extract_pwm(r_stream, w_stream)
    pwm_second = Macroape::SingleMatrix.load_from_line_array(extracted_pwm).with_background(second_background).discrete(discretization)
  else
    raise "Error! File #{second_file} don't exist" unless File.exist?(second_file)
    pwm_second = Macroape::SingleMatrix.load_pat(second_file).with_background(second_background).discrete(discretization)
  end
  
  r_stream.close if first_file == '.stdin' || second_file == '.stdin'

  cmp = Macroape::PWMCompare.new(pwm_first, pwm_second)

  first_threshold = pwm_first.threshold(pvalue)
  second_threshold = pwm_second.threshold(pvalue)

  info = cmp.jaccard(first_threshold, second_threshold)
  
  puts "#{info[:similarity]}\n#{info[:recognized_by_both]}\t#{info[:alignment_length]}\n#{info[:text]}\n#{info[:shift]}\t#{info[:orientation]}"
  
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end