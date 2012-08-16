require 'test_helper'

puts "\n\neval_similarity test:"
class TestEvalSimilarity < Test::Unit::TestCase
  def test_process_pair_of_pwms
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_similarity_output('test/data/KLF4_f2.pat test/data/SP1_f1.pat')
  end
  def test_process_another_pair_of_pwms
    assert_equal "0.0037332005973120955\n15.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>.\n1\tdirect\n", Helpers.eval_similarity_output('test/data/SP1_f1.pat test/data/AHR_si.pat')
  end
  
  def test_recognize_orientation_of_alignment
    assert_equal "1.0\n2033.0\t11\n>>>>>>>>>>>\n<<<<<<<<<<<\n0\trevcomp\n", Helpers.eval_similarity_output('test/data/SP1_f1_revcomp.pat test/data/SP1_f1.pat')
  end

  def test_process_custom_discretization
    assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", Helpers.eval_similarity_output('test/data/SP1_f1.pat test/data/KLF4_f2.pat -d 1')
  end
end
