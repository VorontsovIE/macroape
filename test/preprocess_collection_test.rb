require 'test_helper'
require 'yaml'
require 'macroape'

puts "\n\npreprocess_collection test:"
class TestPreprocessCollection < Test::Unit::TestCase
  def test_multipvalue_preproceessing
    Helpers.run_preprocess_collection('test/data/test_collection -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    # Don't use YAML.load_file() instead of YAML.load(File.read()) because in ruby before v1.93 p194 
    # it doesn't immediately release file descriptor (if I understood error right way) so File.delete fails
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end
end
