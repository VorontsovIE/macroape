require_relative 'test_helper'

class TestScanCollection < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end

  def test_scan_pcm
    assert_equal File.read('KLF4_f2_scan_results_default_cutoff.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pcm test_collection.yaml --silent --pcm --strong-threshold').gsub("\r\n","\n")
  end
  def test_scan_default_cutoff
    assert_equal File.read('KLF4_f2_scan_results_default_cutoff.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pwm test_collection.yaml --silent --strong-threshold').gsub("\r\n","\n")
  end
  def test_scan_weak_threshold
    assert_equal File.read('KLF4_f2_scan_results_weak_threshold.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pwm test_collection_weak.yaml --silent').gsub("\r\n","\n")
  end
  def test_scan_and_output_all_results
    assert_equal File.read('KLF4_f2_scan_results_all.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pwm test_collection.yaml --all --silent --strong-threshold').gsub("\r\n","\n")

  end
  def test_scan_precise_mode
    assert_equal File.read('KLF4_f2_scan_results_precise_mode.txt').gsub("\r\n","\n"),
                 Helpers.scan_collection_output('KLF4_f2.pwm test_collection.yaml --precise --all --silent --strong-threshold').gsub("\r\n", "\n")
  end
  def test_process_query_pwm_from_stdin
    assert_equal Helpers.scan_collection_output('KLF4_f2.pwm test_collection.yaml --silent --strong-threshold'),
                Helpers.provide_stdin(File.read('KLF4_f2.pwm')) {
                  Helpers.scan_collection_output('.stdin test_collection.yaml --silent --strong-threshold')
                }
  end

  def test_scan_medium_length_motif
    assert_match /Query motif medium_motif_name gives 0 recognized words for a given P-value of 0\.0005 with the rough discretization level of 1. Forcing precise discretization level of 10/,
                 Helpers.scan_collection_stderr('medium_motif.pwm test_collection.yaml --precise --all --silent --strong-threshold').gsub("\r\n", "\n")
  end
  def test_scan_short_length_motif
    assert_match /Query motif short_motif_name gives 0 recognized words for a given P-value of 0\.0005 with the precise discretization level of 10\. It.s impossible to scan collection for this motif/,
                 Helpers.scan_collection_stderr('short_motif.pwm test_collection.yaml --precise --all --silent --strong-threshold').gsub("\r\n", "\n")
  end
end
