help_string = %q{
Usage:
  ruby align_motifs pwm1_file pwm2_file pwm3_file
  ruby align_motifs pcm1_file pcm2_file pcm3_file --pcm
Output:
  pwm_1_file  shift_1  orientation_1
  pwm_2_file  shift_2  orientation_2
  pwm_3_file  shift_3  orientation_3
}

$:.unshift File.join(File.dirname(__FILE__),'./../../')
require 'macroape'

if ARGV.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| ARGV.include?(help_option)}
  STDERR.puts help_string
  exit
end

begin
  data_model = ARGV.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM
  leader = ARGV.shift
  background = [1,1,1,1]
  discretization = 100
  pvalue = 0.0005
  
  shifts = {leader => [0,:direct]}
  pwm_first = data_model.new(File.read(leader)).to_pwm.background(background).discrete(discretization)
  ARGV.each do |motif_name|
    pwm_second = data_model.new(File.read(motif_name)).to_pwm.background(background).discrete(discretization)
    cmp = Macroape::PWMCompare.new(pwm_first, pwm_second)
    first_threshold = pwm_first.threshold(pvalue)
    second_threshold = pwm_second.threshold(pvalue)
    info = cmp.jaccard(first_threshold, second_threshold)
    shifts[motif_name] = [info[:shift], info[:orientation]]
  end
  
  shifts.each do |motif_name, (shift,orientation)|
    puts "#{motif_name}\t#{shift}\t#{orientation}"
  end

rescue => err
  STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
end