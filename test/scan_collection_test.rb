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
                 Helpers.scan_collection_output('KLF4_f2.pcm test_collection.yaml --silent --pcm').gsub("\r\n","\n")
  end
  def test_scan_default_cutoff
    assert_equal File.read('KLF4_f2_scan_results_default_cutoff.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pat test_collection.yaml --silent').gsub("\r\n","\n")
  end
  def test_scan_and_output_all_results
    assert_equal File.read('KLF4_f2_scan_results_all.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('KLF4_f2.pat test_collection.yaml --all --silent').gsub("\r\n","\n")
      
  end
  def test_scan_precise_mode
    assert_equal File.read('KLF4_f2_scan_results_precise_mode.txt').gsub("\r\n","\n"),
                 Helpers.scan_collection_output('KLF4_f2.pat test_collection.yaml --precise --all --silent').gsub("\r\n", "\n")
  end
  def test_process_query_pwm_from_stdin
    assert_equal Helpers.scan_collection_output('KLF4_f2.pat test_collection.yaml --silent'),
                Helpers.provide_stdin(File.read('KLF4_f2.pat')) {
                  Helpers.scan_collection_output('.stdin test_collection.yaml --silent')
                }
  end

  def test_scan_medium_length_motif
    assert_match /Query motif medium_motif_name gives 0 recognized words for a given P-value of 0\.0005 with the rough discretization level of 1. Forcing precise discretization level of 10/,
                 Helpers.scan_collection_stderr('medium_motif.pat test_collection.yaml --precise --all --silent').gsub("\r\n", "\n")
  end
  def test_scan_short_length_motif
    assert_match /Query motif short_motif_name gives 0 recognized words for a given P-value of 0\.0005 with the precise discretization level of 10\. It.s impossible to scan collection for this motif/,
                 Helpers.scan_collection_stderr('short_motif.pat test_collection.yaml --precise --all --silent').gsub("\r\n", "\n")
  end
end
