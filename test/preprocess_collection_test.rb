require 'test_helper'
require 'yaml'
require 'macroape'

class TestPreprocessCollection < Test::Unit::TestCase
  def test_multipvalue_preproceessing
    system(Helpers.exec_cmd('preprocess_collection','test/data/test_collection -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent'))
    assert_equal YAML.load_file('test/data/test_collection.yaml'), YAML.load_file('test/data/test_collection.yaml.tmp')
    File.delete 'test/data/test_collection.yaml.tmp'
  end
end
