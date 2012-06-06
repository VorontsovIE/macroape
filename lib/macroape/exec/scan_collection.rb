help_string = %q{
Command-line format:
ruby scan_collection.rb <pat-file> <collection> [options]
        or in linux
cat <pat-file> | ruby scan_collection.rb .stdin <collection> [options]
        or on windows
type <pat-file> | ruby scan_collection.rb .stdin <collection> [options]

Options:
  [-p <P-value>]
  [-c <similarity cutoff (minimal similarity to be included in output)> ] or [--all], '-c 0.05' by default
  [--precise [<level, minimal similarity to check on a more precise discretization level on the second pass>]], off by default, '--precise 0.01' if level is not set
  [--silent] - don't show current progress information during scan (by default this information's written into stderr)
  
Output format:
 <name> <similarity jaccard index> <shift> <overlap> <orientation> * [in case that result calculated on the second pass(in precise mode)]
    Attention! Name can contain whitespace characters. 
    Attention! The shift and orientation are reported for the collection matrix relative to the query matrix.
	 
Example:  
  ruby scan_collection.rb motifs/KLF4.pat collection.yaml -p 0.005
            or in linux
  cat motifs/KLF4.pat | ruby scan_collection.rb .stdin collection.yaml -p 0.005 --precise 0.03
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape'

if ARGV.empty? or ARGV.include? '-h' or ARGV.include? '-help' or ARGV.include? '--help' or ARGV.include? '--h'
  STDERR.puts help_string
  exit
end

begin
  filename = ARGV.shift
  collection_file = ARGV.shift
  raise "No input. You'd specify input source for pat: filename or .stdin" unless filename
  raise "No input. You'd specify input file with collection" unless collection_file
  raise "Collection file #{collection_file} doesn't exist" unless File.exist?(collection_file)
  
  pvalue = 0.0005
  cutoff = 0.05 # minimal similarity to output
  collection = YAML.load_file(collection_file)
  background_query = collection.background

  silent = false
  precision_mode = :rough
  until ARGV.empty?
    case ARGV.shift
      when '-bq'
        background_query = ARGV.shift(4).map(&:to_f)
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless background_query == background_query.reverse
      when '-p'
        pvalue = ARGV.shift.to_f
      when '-m'
        Macroape::MaxHashSize = ARGV.shift.to_f
      when '-md'
        PWMCompare::MaxHashSize = ARGV.shift.to_f
      when '-c'
        cutoff = ARGV.shift.to_f
      when '--all'
        cutoff = 0.0
      when '--silent'
        silent = true
      when '--precise'
        precision_mode = :precise
        begin 
          Float(ARGV.first)
          minimal_similarity = ARGV.shift.to_f
        rescue
          minimal_similarity = 0.05
        end
    end
  end
  Macroape::MaxHashSize = 1000000 unless defined? Macroape::MaxHashSize
  PWMCompare::MaxHashSize = 1000 unless defined? PWMCompare::MaxHashSize
  
  raise "Thresholds for pvalue #{pvalue} aren't presented in collection (#{collection.pvalues.join(', ')}). Use one of listed pvalues or recalculate the collection with needed pvalue" unless collection.pvalues.include? pvalue
  
  if filename == '.stdin'
    query_pwm = Macroape::SingleMatrix.load_from_stdin(STDIN)
  else
    raise "Error! File #{filename} doesn't exist" unless File.exist?(filename)
    query_pwm = Macroape::SingleMatrix.load_pat(filename)
  end
  
  
  query_pwm_rough = query_pwm.with_background(background_query).discrete(collection.rough_discretization)
  query_pwm_precise = query_pwm.with_background(background_query).discrete(collection.precise_discretization)
  
  threshold = query_pwm_rough.threshold(pvalue)
  threshold_precise = query_pwm_precise.threshold(pvalue)
  
  similarities = {}
  precision_file_mode = {}
  unnamed_index = 0
  
  collection.pwms.each_key do |name|
    pwm = collection.pwms[name]
    pwm_info = collection.infos[name]
    STDERR.puts pwm.name unless silent
    cmp = PWMCompare::PWMCompare.new(query_pwm_rough, pwm.with_background(collection.background).discrete(collection.rough_discretization))
    info = cmp.jaccard(threshold, pwm_info[:rough][pvalue] * collection.rough_discretization)
    name = pwm.name || "Unnamed #{unnamed_index += 1}"
    precision_file_mode[name] = :rough
    
    if precision_mode == :precise and info[:similarity] >= minimal_similarity
      cmp = PWMCompare::PWMCompare.new(query_pwm_precise, pwm.with_background(collection.background).discrete(collection.precise_discretization))
      info = cmp.jaccard(threshold_precise, pwm_info[:precise][pvalue] * collection.precise_discretization)
      precision_file_mode[name] = :precise
    end
    similarities[name] = info
  end
  
  puts "#pwm\tsimilarity\tshift\toverlap\torientation"
  similarities.sort_by do |name, info|
    info[:similarity]
  end.reverse.each do |name, info|
    precision_text = (precision_file_mode[name] == :precise) ? "\t*" : ""
    puts "#{name}\t#{info[:similarity]}\t#{info[:shift]}\t#{info[:overlap]}\t#{info[:orientation]}#{precision_text}" if info[:similarity] >= cutoff
  end
  
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end