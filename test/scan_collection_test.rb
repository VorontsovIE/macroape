require 'test_helper'

class TestScanCollection < Test::Unit::TestCase
  def test_scan_default_cutoff
    assert_equal File.read('test/data/KLF4_f2_scan_results_default_cutoff.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('test/data/KLF4_f2.pat test/data/test_collection.yaml --silent').gsub("\r\n","\n")
  end
  def test_scan_and_output_all_results
    assert_equal File.read('test/data/KLF4_f2_scan_results_all.txt').gsub("\r\n", "\n"),
                 Helpers.scan_collection_output('test/data/KLF4_f2.pat test/data/test_collection.yaml --all --silent').gsub("\r\n","\n")
      
  end
  def test_scan_precise_mode
    assert_equal File.read('test/data/KLF4_f2_scan_results_precise_mode.txt').gsub("\r\n","\n"),
                 Helpers.scan_collection_output('test/data/KLF4_f2.pat test/data/test_collection.yaml --precise --all --silent').gsub("\r\n", "\n")
  end
  def test_process_query_pwm_from_stdin
    assert_equal Helpers.scan_collection_output('test/data/KLF4_f2.pat test/data/test_collection.yaml --silent'),
                Helpers.provide_stdin(File.read('test/data/KLF4_f2.pat')) {
                  Helpers.scan_collection_output('.stdin test/data/test_collection.yaml --silent')
                }
  end
end
