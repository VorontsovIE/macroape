require 'test_helper'

puts "\n\nfind_pvalue test:"
class FindPvalueTest < Test::Unit::TestCase
  def test_process_one_threshold
    IO.popen(Helpers.exec_cmd('find_pvalue', 'test/data/KLF4_f2.pat 4.1719')){|f|
      assert_equal "4.1719\t1048.0\t0.00099945068359375\n", f.read
    }
  end
  def test_process_several_thresholds
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 4.1719 5.2403')){|f|
      assert_equal "4.1719\t1048.0\t0.00099945068359375\n5.2403\t524.0\t0.000499725341796875\n", f.read
    }
  end
  def test_process_several_thresholds_result_is_ordered
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 5.2403 4.1719')){|f|
      assert_equal "5.2403\t524.0\t0.000499725341796875\n4.1719\t1048.0\t0.00099945068359375\n", f.read
    }
  end
  def test_custom_discretization
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 5.2403 -d 100')){|f|
      assert_equal "5.2403\t527.0\t0.0005025863647460938\n", f.read
    }
  end
end

