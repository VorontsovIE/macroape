require 'yaml'
require 'macroape'
require_relative 'test_helper'

class TestPreprocessCollection < Test::Unit::TestCase
  def test_multipvalue_preproceessing
    Helpers.run_preprocess_collection('test/data/test_collection -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    # Don't use YAML.load_file() instead of YAML.load(File.read()) because in ruby before v1.93 p194 
    # it doesn't immediately release file descriptor (if I understood error right way) so File.delete fails
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end
  
  def test_preproceessing_collection_from_a_single_file
    Helpers.run_preprocess_collection('test/data/test_collection_single_file.txt -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end
  
  def test_preproceessing_collection_from_stdin
    Helpers.provide_stdin(File.read('test/data/test_collection_single_file.txt')){
      Helpers.run_preprocess_collection('.stdin -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    }
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end

  def test_preproceessing_folder_pcm
    Helpers.run_preprocess_collection('test/data/test_collection_pcm -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end
  
  def test_preproceessing_collection_from_a_single_file_pcm
    Helpers.run_preprocess_collection('test/data/test_collection_single_file_pcm.txt -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end
  
  def test_preproceessing_collection_from_stdin_pcm
    Helpers.provide_stdin(File.read('test/data/test_collection_single_file_pcm.txt')){
      Helpers.run_preprocess_collection('.stdin -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    }
    assert_equal YAML.load(File.read('test/data/test_collection.yaml')), YAML.load(File.read('test/data/test_collection.yaml.tmp'))
    File.delete 'test/data/test_collection.yaml.tmp'
  end

end
