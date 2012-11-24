require_relative '../../macroape'

module Macroape
  module CLI
    module AlignMotifs

      def self.main(argv)
        doc = <<-DOCOPT
          Align motifs tool.
          It takes motifs and builds alignment of each motif to the first (leader) motif.

          Output has format:
            pwm_file_1  shift_1  orientation_1
            pwm_file_2  shift_2  orientation_2
            pwm_file_3  shift_3  orientation_3

          Usage:
            align_motifs [options] <pm-files>...

          Options:
            -h --help       Show this screen.
            --pcm           Use PCMs instead of PWMs as input
        DOCOPT

        doc.gsub!(/^#{doc[/\A +/]}/,'')
        options = Docopt::docopt(doc, argv: argv)

        data_model = options['--pcm'] ? Bioinform::PCM : Bioinform::PWM
        motif_files = options['<pm-files>']
        leader = motif_files.first
        background = [1,1,1,1]
        discretization = 1
        pvalue = 0.0005

        shifts = {leader => [0,:direct]}
        pwm_first = data_model.new(File.read(leader)).to_pwm
        pwm_first.set_parameters(background: background).discrete!(discretization)
        motif_files[1..-1].each do |motif_name|
          pwm_second = data_model.new(File.read(motif_name)).to_pwm
          pwm_second.set_parameters(background: background).discrete!(discretization)
          info = Macroape::PWMCompare.new(pwm_first, pwm_second).jaccard_by_pvalue(pvalue)
          shifts[motif_name] = [info[:shift], info[:orientation]]
        end

        shifts.each do |motif_name, (shift,orientation)|
          puts "#{motif_name}\t#{shift}\t#{orientation}"
        end

      rescue Docopt::Exit => e
        puts e.message
      end

    end
  end
end