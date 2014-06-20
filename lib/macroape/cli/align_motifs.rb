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
            ls rest_pms/*.pm | #{run_tool_cmd} [options]
              or
            ls rest_pms/*.pm | #{run_tool_cmd} [options] <leader pm>

          Options:
            [-p <P-value>]
            [-d <discretization level>]
            [--pcm] - treat the input file as Position Count Matrix. PCM-to-PWM transformation to be done internally.
            [--boundary lower|upper] Upper boundary (default) means that the obtained P-value is greater than or equal to the requested P-value
            [-b <background probabilities] ACGT - 4 numbers, comma-delimited(spaces not allowed), sum should be equal to 1, like 0.25,0.24,0.26,0.25
        EOS

        if (argv.empty? && $stdin.tty?) || ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          $stderr.puts doc
          exit
        end

        leader_background = Bioinform::Background::Wordwise
        rest_motifs_background = Bioinform::Background::Wordwise
        discretization = 1
        pvalue = 0.0005
        max_hash_size = 10000000
        max_pair_hash_size = 10000
        pvalue_boundary = :upper

        data_model = argv.delete('--pcm') ? :pcm : :pwm

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
              rest_motifs_background = leader_background = Bioinform::Background.from_string(argv.shift)
            when '-b1'
              leader_background = Bioinform::Background.from_string(argv.shift)
            when '-b2'
              rest_motifs_background = Bioinform::Background.from_string(argv.shift)
            when '--boundary'
              pvalue_boundary = argv.shift.to_sym
              raise 'boundary should be either lower or upper'  unless  pvalue_boundary == :lower || pvalue_boundary == :upper
          end
        end

        pwm_files = argv
        pwm_files += $stdin.read.shellsplit  unless $stdin.tty?
        leader_pwm_file = pwm_files.first
        rest_pwm_files = pwm_files[1..-1]
        rest_pwm_files.reject!{|filename| File.expand_path(filename) == File.expand_path(leader_pwm_file)}

        raise 'Specify leader file'  unless leader_pwm_file

        shifts = []
        shifts << [leader_pwm_file, 0, :direct]

        input_first = File.read(leader_pwm_file)
        input_first = Bioinform::Parser.choose(input_first).parse!(input_first)
        case data_model
        when :pcm
          pcm_first = Bioinform::MotifModel::PCM.new(input_first[:matrix]).named(input_first[:name])
          pwm_first = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(pseudocount: :log, background: leader_background).convert(pcm_first)
        when :pwm
          pwm_first = Bioinform::MotifModel::PWM.new(input_first[:matrix]).named(input_first[:name])
        end

        pwm_first = pwm_first.discreted(discretization)
        counting_first = PWMCounting.new(pwm_first, background: leader_background, max_hash_size: max_hash_size)

        rest_pwm_files.each do |motif_name|
          input_second = File.read(motif_name)
          input_second = Bioinform::Parser.choose(input_second).parse!(input_second)
          case data_model
          when :pcm
            pcm_second = Bioinform::MotifModel::PCM.new(input_second[:matrix]).named(input_second[:name])
            pwm_second = Bioinform::ConversionAlgorithms::PCM2PWMConverter.new(pseudocount: :log, background: rest_motifs_background).convert(pcm_second)
          when :pwm
            pwm_second = Bioinform::MotifModel::PWM.new(input_second[:matrix]).named(input_second[:name])
          end
          pwm_second = pwm_second.discreted(discretization)
          counting_second = PWMCounting.new(pwm_second, background: rest_motifs_background, max_hash_size: max_hash_size)
          cmp = Macroape::PWMCompare.new(counting_first, counting_second).tap{|x| x.max_pair_hash_size = max_pair_hash_size }
          info = cmp.jaccard_by_pvalue(pvalue)
          shifts << [motif_name, info[:shift], info[:orientation]]
        end

        shifts.each do |motif_name, shift,orientation|
          puts "#{motif_name}\t#{shift}\t#{orientation}"
        end
      rescue => err
        $stderr.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse --help option for help\n\n#{doc}"
      end

    end
  end
end
