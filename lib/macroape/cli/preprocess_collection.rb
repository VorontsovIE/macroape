require_relative '../../macroape'
require 'yaml'
require 'shellwords'

module Macroape
  module CLI
    module PreprocessCollection

      def self.main(argv)
        doc = %q{
        Command-line format:
          preprocess_collection <file or folder with PWMs or .stdin with filenames> [options]

        Options:
          [-p <list of P-values>]
          [-d <rough discretization> <precise discretization>]
          [-b <background probabilities, ACGT - 4 numbers, space-delimited, sum should be equal to 1>]
          [-o <output file>]
          [-n <name>] - specify name for a collection. Default filename is based on this parameter
          [--silent] - don't show current progress information during scan (by default this information's written into stderr)
          [--pcm] - treats your input motifs as PCM-s. Motifs are converted to PWMs internally so output is the same as for according PWMs
          [--strong-threshold]

        The tool stores preprocessed Macroape collection to the specified YAML-file.

        Example:
          preprocess_collection ./motifs -p 0.001 0.0005 0.0001 -d 1 10 -b 0.2 0.3 0.2 0.3 -o collection.yaml
        }
        doc.gsub!(/^#{doc[/\A +/]}/,'')
        if ['-h', '--h', '-help', '--help'].any?{|help_option| argv.include?(help_option)}
          STDERR.puts doc
          exit
        end

        data_model = argv.delete('--pcm') ? Bioinform::PCM : Bioinform::PWM

        default_pvalues = [0.0005]
        background = [1,1,1,1]
        rough_discretization = 1
        precise_discretization = 10
        output_file = 'collection.yaml'
        max_hash_size = 1000000

        data_source = argv.shift

        raise "No input. You'd specify file or folder with pwms" unless data_source
        raise "Error! File or folder #{data_source} doesn't exist" unless Dir.exist?(data_source) || File.exist?(data_source) || data_source == '.stdin'

        pvalues = []
        silent = false
        output_file_specified = false
        strong_threshold = false

        until argv.empty?
          case argv.shift
            when '-b'
              background = argv.shift(4).map(&:to_f)
              raise 'background should be symmetric: p(A)=p(T) and p(G) = p(C)' unless background == background.reverse
            when '-p'
              loop do
                begin
                  Float(argv.first)
                  pvalues << argv.shift.to_f
                rescue
                  raise StopIteration
                end
              end
            when '-d'
              rough_discretization, precise_discretization = argv.shift(2).map(&:to_f).sort
            when '-o'
              output_file = argv.shift
              output_file_specified = true
            when '-m'
              max_hash_size = argv.shift.to_i
            when '-n'
              collection_name = argv.shift
            when '--silent'
              silent = true
            when '--strong-threshold'
              strong_threshold = true
            end
        end
        pvalues = default_pvalues  if pvalues.empty?

        collection = Bioinform::Collection.new(rough_discretization: rough_discretization,
                                precise_discretization: precise_discretization,
                                background: background,
                                pvalues: pvalues)
        if collection_name
          collection.name = collection_name
          output_file = "#{collection_name}.yaml"  if !output_file_specified
        end

        if File.directory?(data_source)
          motifs = Dir.glob(File.join(data_source,'*')).sort.map do |filename|
            pwm = data_model.new(File.read(filename))
            pwm.name ||= File.basename(filename, File.extname(filename))
            pwm
          end
        elsif File.file?(data_source)
          input = File.read(data_source)
          motifs = data_model.split_on_motifs(input)
        elsif data_source == '.stdin'
          filelist = $stdin.read.shellsplit
          motifs = []
          filelist.each do |filename|
            motif = data_model.new(File.read(filename))
            motif.name ||= File.basename(filename, File.extname(filename))
            motifs << motif
          end
        else
          raise "Specified data source `#{data_source}` is neither directory nor file nor even .stdin"
        end

        pwms = motifs.map(&:to_pwm)

        pwms.each_with_index do |pwm,index|
          STDERR.puts "#{index + 1} -- Name: #{pwm.name}, Length: #{pwm.length}"  unless silent

          # When support of onefile collections is introduced - then here should be check if name exists.
          # Otherwise it should skip motif and tell you about this
          # Also two command line options to fail on skipping or to skip silently should be included

          info = OpenStruct.new(rough: {}, precise: {})
          pwm.set_parameters(background: background, max_hash_size: max_hash_size)
          skip_motif = false


          fill_rough_infos = ->(pvalue, threshold, real_pvalue) do
            if real_pvalue == 0
              $stderr.puts "#{pwm.name} at pvalue #{pvalue} has threshold that yields real-pvalue 0 in rough mode. Rough calculation will be skipped"
            else
              info.rough[pvalue] = threshold / rough_discretization
            end
          end

          fill_precise_infos = ->(pvalue, threshold, real_pvalue) do
            if real_pvalue == 0
              $stderr.puts "#{pwm.name} at pvalue #{pvalue} has threshold that yields real-pvalue 0 in precise mode. Motif will be excluded from collection"
              skip_motif = true
            else
              info.precise[pvalue] = threshold / precise_discretization
            end
          end

          if strong_threshold
            pwm.discrete(rough_discretization).thresholds(*pvalues, &fill_rough_infos)
          else
            pwm.discrete(rough_discretization).weak_thresholds(*pvalues, &fill_rough_infos)
          end

          if strong_threshold
            pwm.discrete(precise_discretization).thresholds(*pvalues, &fill_precise_infos)
          else
            pwm.discrete(precise_discretization).weak_thresholds(*pvalues,&fill_precise_infos)
          end
          collection.add_pm(pwm, info)  unless skip_motif
        end
        File.open(output_file, 'w') do |f|
          f.puts(collection.to_yaml)
        end
      rescue => err
        STDERR.puts "\n#{err}\n#{err.backtrace.first(5).join("\n")}\n\nUse -help option for help\n"
      end

    end
  end
end