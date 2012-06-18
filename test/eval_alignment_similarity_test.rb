require 'test_helper'

class TestEvalAlignmentSimilarity < Test::Unit::TestCase
  def test_process_at_optimal_alignment
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 direct')){|f|
      assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", f.read
    }
  end
  def test_process_not_optimal_alignment
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat 0 direct')){|f|
      assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", f.read
    }
  end
  def test_process_at_optimal_alignment_reversed
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 revcomp')){|f|
      assert_equal "0.0\n0.0\t11\n.>>>>>>>>>>\n<<<<<<<<<<<\n-1\trevcomp\n", f.read
    }
  end
end
