require 'test_helper'

puts "\n\nfind_pvalue test:"
class FindPvalueTest < Test::Unit::TestCase
  def test_process_one_threshold
    assert_equal "4.1719\t1048.0\t0.00099945068359375\n", Helpers.find_pvalue_output('test/data/KLF4_f2.pat 4.1719')
  end
  def test_process_several_thresholds
    assert_equal "4.1719\t1048.0\t0.00099945068359375\n5.2403\t524.0\t0.000499725341796875\n", Helpers.find_pvalue_output('test/data/KLF4_f2.pat 4.1719 5.2403')
  end
  def test_process_several_thresholds_result_is_ordered
    assert_equal "5.2403\t524.0\t0.000499725341796875\n4.1719\t1048.0\t0.00099945068359375\n", Helpers.find_pvalue_output('test/data/KLF4_f2.pat 5.2403 4.1719')
  end
  def test_custom_discretization
    assert_equal "5.2403\t527.0\t0.0005025863647460938\n", Helpers.find_pvalue_output('test/data/KLF4_f2.pat 5.2403 -d 100')
  end
  def test_process_pwm_from_stdin
    assert_equal IO.popen(Helpers.exec_cmd('find_pvalue', '.stdin 1 < test/data/KLF4_f2.pat'), &:read),
                 Helpers.find_pvalue_output('test/data/KLF4_f2.pat 1')
  end
end

