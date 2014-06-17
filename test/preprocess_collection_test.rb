require_relative 'test_helper'
require 'yaml'

# Don't use YAML.load_file() instead of YAML.load(File.read()) because in ruby before v1.9.3 p194
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

  def test_weak_thresholds
    Helpers.run_preprocess_collection('test_collection test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent')
    assert_equal YAML.load(File.read('test_collection_weak.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_multipvalue_preprocessing
    Helpers.run_preprocess_collection('test_collection test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --boundary lower')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_a_single_file
    Helpers.run_preprocess_collection('test_collection_single_file.txt test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --boundary lower')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_stdin
    Helpers.provide_stdin('test_collection/GABPA_f1.pwm  test_collection/KLF4_f2.pwm  test_collection/SP1_f1.pwm'){
      Helpers.run_preprocess_collection('.stdin test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --boundary lower')
    }
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_folder_pcm
    Helpers.run_preprocess_collection('test_collection_pcm test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --pcm --boundary lower')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_a_single_file_pcm
    Helpers.run_preprocess_collection('test_collection_single_file_pcm.txt test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --pcm --boundary lower')
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end

  def test_preprocessing_collection_from_stdin_pcm
    Helpers.provide_stdin('test_collection_pcm/GABPA_f1.pcm  test_collection_pcm/KLF4_f2.pcm  test_collection_pcm/SP1_f1.pcm'){
      Helpers.run_preprocess_collection('.stdin test_collection.yaml.tmp -p 0.0005,0.0001,0.00005 --silent --pcm --boundary lower')
    }
    assert_equal YAML.load(File.read('test_collection.yaml')), YAML.load(File.read('test_collection.yaml.tmp'))
  end
end
