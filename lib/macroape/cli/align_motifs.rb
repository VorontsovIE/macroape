require_relative '../../macroape'
require 'shellwords'

module Macroape
  module CLI
    module AlignMotifs

      def self.main(argv)
        doc = <<-EOS.strip_doc
          Align motifs tool.
          It takes motifs and builds alignment of each motif to the first (leader) motif.

          Output has format:
            pwm_file_1  shift_1  orientation_1
            pwm_file_2  shift_2  orientation_2
            pwm_file_3  shift_3  orientation_3

          Usage:
            #{run_tool_cmd} [options] <leader pm> <rest pm files>...
              or
            ls rest_pms/*.pm | #{run_tool_cmd} [options] <leader pm>

          Options:
            [-p <P-value>]
            [-d <discretization level>]
            [--pcm] - treat the input file as Position Count Matrix. PCM-to-PWM transformation to be done internally.
            [--boundary lower|upper] Upper boundary (default) means that the obtained P-value is greater than or equal to the requested P-value
            [-b <background probabilities] ACGT - 4 numbers, comma-delimited(spaces not allowed), sum should be equal to 1, like 0.25,0.24,0.26,0.25
        EOS

        if argv.empty? || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        leader_background = [1,1,1,1]
        rest_motifs_background = [1,1,1,1]
        discretization = 1
        pvalue = 0.0005
        max_hash_size = 10000000
        max_pair_hash_size = 10000
        pvalue_boundary = :upper

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM

        while argv.first && argv.first.start_with?('-')
          case argv.shift
            when '-p'
              pvalue = argv.shift.to_f
            when '-d'
              discretization = argv.shift.to_f
            when '--max-hash-size'
              max_hash_size = argv.shift.to_i
            when '--max-2d-hash-size'
              max_pair_hash_size = argv.shift.to_i
            when '-b'
              rest_motifs_background = leader_background = argv.shift.split(',').map(&:to_f)
            when '-b1'
              leader_background = argv.shift.split(',').map(&:to_f)
            when '-b2'
              rest_motifs_background = argv.shift.split(',').map(&:to_f)
            when '--boundary'
              pvalue_boundary = argv.shift.to_sym
              raise 'boundary should be either lower or upper'  unless  pvalue_boundary == :lower || pvalue_boundary == :upper
          end
        end

        leader_pwm_file = argv.shift
        rest_pwms_file = argv
        rest_pwms_file += $stdin.read.shellsplit  unless $stdin.tty?
        rest_pwms_file.reject!{|filename| File.expand_path(filename) == File.expand_path(leader_pwm_file)}

        shifts = []
        shifts << [leader_pwm_file, 0, :direct]
        pwm_first = data_model.new(File.read(leader_pwm_file)).to_pwm
        pwm_first.set_parameters(background: leader_background, max_hash_size: max_hash_size).discrete!(discretization)

        rest_pwms_file.each do |motif_name|
          pwm_second = data_model.new(File.read(motif_name)).to_pwm
          pwm_second.set_parameters(background: rest_motifs_background, max_hash_size: max_hash_size).discrete!(discretization)
          cmp = Macroape::PWMCompare.new(pwm_first, pwm_second).set_parameters(max_pair_hash_size: max_pair_hash_size)
          info = cmp.jaccard_by_pvalue(pvalue)
          shifts << [motif_name, info[:shift], info[:orientation]]
        end

        shifts.each do |motif_name, shift,orientation|
          puts "#{motif_name}\t#{shift}\t#{orientation}"
        end
      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse --help option for help\n\n#{doc}"
      end

    end
  end
end