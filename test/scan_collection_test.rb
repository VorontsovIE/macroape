require 'test_helper'

class TestScanCollection < Test::Unit::TestCase
  def test_scan_default_cutoff
    assert_equal File.read('test/data/KLF4_f2_scan_results_default_cutoff.txt').gsub("\r\n", "\n"),
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --silent'), &:read).gsub("\r\n","\n")
  end
  def test_scan_and_output_all_results
    assert_equal File.read('test/data/KLF4_f2_scan_results_all.txt').gsub("\r\n", "\n"),
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --all --silent'), &:read).gsub("\r\n","\n")
      
  end
  def test_scan_precise_mode
    assert_equal File.read('test/data/KLF4_f2_scan_results_precise_mode.txt').gsub("\r\n","\n"),
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --precise --all --silent'), &:read).gsub("\r\n", "\n")
  end
end
