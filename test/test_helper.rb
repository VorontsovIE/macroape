$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'test/unit'
 
module Helpers
  def self.obtain_pvalue_by_threshold(args)
    IO.popen("find_pvalue #{args}",&:read).strip.split.last
  end
  def self.exec_cmd(executable, param_list)
    "ruby #{File.dirname(File.absolute_path __FILE__)}/../lib/macroape/exec/#{executable}.rb #{param_list}"
  end
end
