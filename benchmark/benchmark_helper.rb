$bioinform_folder = File.dirname(__FILE__) + '/../../bioinform/lib'
$LOAD_PATH.unshift $bioinform_folder

require 'benchmark'
require_relative '../lib/macroape'