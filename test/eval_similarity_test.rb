require 'test_helper'

class TestEvalSimilarity < Test::Unit::TestCase
  def test_process_pair_of_pwms
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/KLF4_f2.pat test/data/SP1_f1.pat')){|f|
      assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", f.read
    }
  end
  def test_process_another_pair_of_pwms
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1.pat test/data/AHR_si.pat')){|f|
      assert_equal "0.0037332005973120955\n15.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>.\n1\tdirect\n", f.read
    }
  end
  
  def test_recognize_orientation_of_alignment
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1_revcomp.pat test/data/SP1_f1.pat')){|f|
      assert_equal "1.0\n2033.0\t11\n>>>>>>>>>>>\n<<<<<<<<<<<\n0\trevcomp\n", f.read
    }
  end

  def test_process_custom_discretization
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1.pat test/data/KLF4_f2.pat -d 1')){|f|
      assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", f.read
    }
  end
end
