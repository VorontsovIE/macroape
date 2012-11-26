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
        EOS
      end

      def self.threshold_infos_string(infos)
        result_strings = infos.collect { |info|
          "#{ info[:expected_pvalue] }\t#{ info[:real_pvalue] }\t#{ info[:recognized_words] }\t#{ info[:threshold] }" 
        }
        <<-EOS.strip_doc
          # P: requested P-value
          # AP: actual P-value
          # W: number of recognized words
          # T: threshold
          P\tAP\tW\tT
          #{result_strings.join("\n")}
        EOS
      end
    end
  end
end