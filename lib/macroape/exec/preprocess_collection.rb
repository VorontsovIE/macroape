help_string = %q{
Command-line format:
  ruby preprocess_collection.rb <folder with PWMs> [options]

Options:
  [-p <list of P-values>]
  [-d <rough discretization> <precise discretization>]
  [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]
  [-o <output file>]
  [--silent] - don't show current progress information during scan (by default this information's written into stderr)

The tool stores preprocessed Macroape collection to the specified YAML-file.
 
Example:
  ruby preprocess_collection.rb ./motifs -p 0.001 0.0005 0.0001 -d 1 10 -b 0.2 0.3 0.2 0.3 -o collection.yaml
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape'
require 'bioinform'
require 'yaml'

if ARGV.empty? or ARGV.include? '-h' or ARGV.include? '-help' or ARGV.include? '--help' or ARGV.include? '--h'
  STDERR.puts help_string
  exit
end

default_pvalues = [0.0005]
background = [1,1,1,1]
rough_discretization = 1
precise_discretization = 10
output_file =  'collection.yaml'

begin
  folder = ARGV.shift
  raise "No input. You'd specify folder with pat-files" unless folder
  raise "Error! Folder #{folder} doesn't exist" unless Dir.exist?(folder)
  
  pvalues = []
  silent = false
  until ARGV.empty?
    case ARGV.shift
      when '-b'
        background = ARGV.shift(4).map(&:to_f)
        raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless background == background.reverse
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
        rough_discretization, precise_discretization = ARGV.shift(2).map(&:to_f).sort
      when '-o'
        output_file = ARGV.shift
      when '-m'
        Macroape::MaxHashSizeSingle = ARGV.shift.to_f
      when '-md'
        Macroape::MaxHashSizeDouble = ARGV.shift.to_f
      when '--silent'
        silent = true
      end
  end
  pvalues = default_pvalues if pvalues.empty?
  
  Macroape::MaxHashSizeSingle = 1000000 unless defined? Macroape::MaxHashSizeSingle
  Macroape::MaxHashSizeDouble = 1000 unless defined? Macroape::MaxHashSizeDouble

  collection = Macroape::Collection.new(rough_discretization, precise_discretization, background, pvalues)

  current_dir = File.dirname(__FILE__)
  Dir.glob(File.join(folder,'*')) do |filename|
    STDERR.puts filename unless silent
    pwm = Bioinform::PWM.new(File.read(filename))
    info = {rough: {}, precise: {}}
    output = `ruby "#{File.join current_dir,'find_threshold.rb'}" #{filename} -p #{pvalues.join(' ')} -b #{background.join(' ')} -d #{rough_discretization}`.split("\n")
    output.each do |line|
      pvalue, threshold, real_pvalue = line.split.map(&:to_f)
      info[:rough][pvalue] = threshold
    end
    
    output = `ruby "#{File.join current_dir,'find_threshold.rb'}" #{filename} -p #{pvalues.join(' ')} -b #{background.join(' ')} -d #{precise_discretization}`.split("\n")
    output.each do |line|
      pvalue, threshold, real_pvalue = line.split.map(&:to_f)
      info[:precise][pvalue] = threshold
    end
    collection.add_pwm(pwm, info)
  end
  File.open(output_file,'w') do |f|
    f.puts(collection.to_yaml)
  end
rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end