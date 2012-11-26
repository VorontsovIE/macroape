require 'bioinform/support/strip_doc'

module Macroape
  module CLI
    module Helper
      def self.similarity_info_string(info)
        <<-EOS.strip_doc
          # S: similarity
          # D: distance (1-similarity)
          # L: length of the alignment
          # SH: shift of the 2nd PWM relative to the 1st
          # OR: orientation of the 2nd PWM relative to the 1st
          # A1: aligned 1st matrix
          # A2: aligned 2nd matrix
          # W: number of words recognized by both models (model = PWM + threshold)
          # W1: number of words and recognized by the first model
          # P1: P-value for the 1st matrix
          # T1: threshold for the 1st matrix
          # W2: number of words recognized by the 2nd model
          # P2: P-value for the 2nd matrix
          # T2: threshold for the 2nd matrix
          # V: discretization
          S\t#{ info[:similarity] }
          D\t#{ info[:tanimoto] }
          L\t#{ info[:alignment_length] }
          SH\t#{ info[:shift] }
          OR\t#{ info[:orientation] }
          A1\t#{ info[:text].lines.to_a.first.strip }
          A2\t#{ info[:text].lines.to_a.last.strip }
          W\t#{ info[:recognized_by_both] }
          W1\t#{ info[:recognized_by_first] }
          P1\t#{ info[:real_pvalue_first] }
          T1\t#{ info[:threshold_first] }
          W2\t#{ info[:recognized_by_second] }
          P2\t#{ info[:real_pvalue_second] }
          T2\t#{ info[:threshold_second] }
          V\t#{info[:discretization]}
        EOS
      end

############################################

      def self.threshold_infos_string(infos, parameters)
        parameters_data = []
        parameters_data << "# V\t#{parameters[:discretization]}\t#discretization value"
        parameters_data << "# B\t#{parameters[:background]}\t#background"  unless parameters[:background] == [1,1,1,1]
        parameters_string = parameters_data.join("\n")

        result_strings = infos.collect { |info|
          "#{ info[:expected_pvalue] }\t#{ info[:real_pvalue] }\t#{ info[:recognized_words] }\t#{ info[:threshold] }"
        }
        <<-EOS.strip_doc
          #{parameters_string}
          # P: requested P-value
          # AP: actual P-value
          # W: number of recognized words
          # T: threshold
          P\tAP\tW\tT
          #{result_strings.join("\n")}
        EOS
      end

############################################

      def self.scan_collection_parameters_string(parameters)
        result = []
        result << "#MS\t#{parameters[:cutoff]}\tminimal similarity to output"
        if parameters[:precision_mode] == :precise
          result << "#VR\t#{parameters[:rough_discretization]}\t#discretization value, rough"
          result << "#VP\t#{parameters[:precise_discretization]}\t#discretization value, precise"
          result << "#MP\t#{parameters[:minimal_similarity]}\t#minimal similarity for the 2nd pass in 'precise' mode"
        else
          result << "#V\t#{parameters[:rough_discretization]}\t#discretization value"
        end
        result << "#P\t#{parameters[:pvalue]}\t#P-Value"
        pvalue_boundary = parameters[:strong_threshold] ? 'lower' : 'upper'
        result << "#PB\t#{pvalue_boundary}\t#P-value boundary"
        result << "#BQ\t#{parameters[:query_background].join(' ')}#background for query matrix"  unless parameters[:query_background] == [1,1,1,1]
        result << "#BC\t#{parameters[:collection_background].join(' ')}#background for collection"  unless parameters[:collection_background] == [1,1,1,1]

        result.join("\n")
      end

############################################

      def self.scan_collection_infos_string(infos, parameters)
        result_strings = infos.collect do |name, info|
          precision_text = (info[:precision_mode] == :precise) ? "\t*" : ""
          "#{name}\t#{info[:similarity]}\t#{info[:shift]}\t#{info[:overlap]}\t#{info[:orientation]}#{precision_text}"
        end
        <<-EOS
          #{scan_collection_parameters_string(parameters)}
          # pwm\tsimilarity\tshift\toverlap\torientation
          #{result_strings.join("\n")}
        EOS
      end

############################################

      def self.find_pvalue_info_string(infos, parameters)
        result_strings = infos.collect do |info|
          "#{ info[:threshold] }\t#{ info[:number_of_recognized_words] }\t#{ info[:pvalue] }"
        end
        parameters_data = []
        parameters_data << "# V\t#{parameters[:discretization]}\t#discretization value"
        parameters_data << "# B\t#{parameters[:background]}\t#background"  unless parameters[:background] == [1,1,1,1]
        parameters_string = parameters_data.join("\n")
        <<-EOS.strip_doc
          #{parameters_string}
          # T: threshold
          # W: number of recognized words
          # P: P-value
          # T\tW\tP
          #{result_strings.join("\n")}
        EOS
      end
    end
  end
end