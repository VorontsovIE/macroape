require 'test_helper'

class TestScanCollection < Test::Unit::TestCase
  def test_scan_default_cutoff
    assert_equal File.read('test/data/KLF4_f2_scan_results_default_cutoff.txt'), 
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --silent'), &:read)
  end
  def test_scan_and_output_all_results
    assert_equal File.read('test/data/KLF4_f2_scan_results_all.txt'), 
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --all --silent'), &:read)
      
  end
  def test_scan_precise_mode
    assert_equal File.read('test/data/KLF4_f2_scan_results_precise_mode.txt'),
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --precise --all --silent'), &:read)
  end
end
