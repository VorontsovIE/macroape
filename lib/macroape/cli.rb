require 'docopt'
require 'bioinform/support/strip_doc'

module Macroape
  module CLI
    module Helper
      def self.similarity_info_string(info)
        <<-EOS.strip_doc
          #{ info[:similarity] }
          #{ info[:recognized_by_both] }\t#{ info[:alignment_length] }
          #{ info[:text] }
          #{ info[:shift] }\t#{ info[:orientation] }
        EOS
      end
    end
  end
end