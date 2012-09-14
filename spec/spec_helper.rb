$bioinform_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bioinform', 'lib'))
$LOAD_PATH.unshift $bioinform_folder

require 'rspec'