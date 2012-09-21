require_relative 'test_helper'
require 'yaml'

# Don't use YAML.load_file() instead of YAML.load(File.read()) because in ruby before v1.93 p194
# it doesn't immediately release file descriptor (if I understood error right way) so File.delete fails

class TestPreprocessCollection < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    File.delete('test_collection.yaml.tmp')  if File.exist? 'test_collection.yaml.tmp'
    File.delete('my_collection.yaml')  if File.exist? 'my_collection.yaml'
    Dir.chdir(@start_dir)
  end

  def test_multipvalue_preprocessing
    Helpers.run_preprocess_collection('test_collection -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_a_single_file
    Helpers.run_preprocess_collection('test_collection_single_file.txt -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_stdin
    Helpers.provide_stdin('test_collection/GABPA_f1.pat  test_collection/KLF4_f2.pat  test_collection/SP1_f1.pat'){
      Helpers.run_preprocess_collection('.stdin -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    }
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_folder_pcm
    Helpers.run_preprocess_collection('test_collection_pcm -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_a_single_file_pcm
    Helpers.run_preprocess_collection('test_collection_single_file_pcm.txt -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_a_collection
    Helpers.run_preprocess_collection('collection_without_thresholds.yaml -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end
  def test_preprocessing_collection_from_a_pcm_collection
    Helpers.run_preprocess_collection('collection_pcm_without_thresholds.yaml -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_stdin_pcm
    Helpers.provide_stdin('test_collection_pcm/GABPA_f1.pcm  test_collection_pcm/KLF4_f2.pcm  test_collection_pcm/SP1_f1.pcm'){
      Helpers.run_preprocess_collection('.stdin -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent --pcm')
    }
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_with_name_specified
    Helpers.run_preprocess_collection('test_collection -n my_collection -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection.yaml')).set_parameters(name:'my_collection'), YAML.load(File.read('my_collection.yaml'))
    File.delete('my_collection.yaml')
  end

  def test_with_name_and_output_specified
    Helpers.run_preprocess_collection('test_collection -n my_collection -o test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection.yaml')).set_parameters(name:'my_collection'), YAML.load(File.read('test_collection.yaml.tmp'))
  end
end