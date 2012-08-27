require 'test_helper'

class FindThresholdTest < Test::Unit::TestCase
  def test_process_several_pvalues
    pvalues = []
    Helpers.find_threshold_output('test/data/KLF4_f2.pat -p 0.001 0.0005').lines.each{|line| 
      pvalue, threshold, real_pvalue = line.strip.split("\t")
      pvalues << pvalue
      assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
    }
    assert_equal pvalues, ['0.0005', '0.001']
  end
  def test_process_one_pvalue
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('test/data/KLF4_f2.pat -p 0.001').strip.split("\t")
    assert_equal '0.001', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
  end
  def test_process_default_pvalue
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('test/data/KLF4_f2.pat').strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
  end
  def test_custom_discretization
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('test/data/KLF4_f2.pat -d 100').strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold} -d 100"), real_pvalue
  end
  def test_process_pwm_from_stdin
    assert_equal Helpers.find_threshold_output('test/data/KLF4_f2.pat'),
                Helpers.provide_stdin(File.read('test/data/KLF4_f2.pat')) {
                  Helpers.find_threshold_output('.stdin')
                }
  end
end

