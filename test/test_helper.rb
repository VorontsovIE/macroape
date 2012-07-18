$lib_folder = File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift $lib_folder
require 'test/unit'
 
module Helpers
  def self.obtain_pvalue_by_threshold(args)
    IO.popen("ruby -I #{$lib_folder} #{$lib_folder}/macroape/exec/find_pvalue.rb #{args}",&:read).strip.split.last
  end
  def self.exec_cmd(executable, param_list)
    "ruby -I #{$lib_folder} #{$lib_folder}/macroape/exec/#{executable}.rb #{param_list}"
  end
end
