require 'test_helper'

puts "\n\neval_alignment test:"
class TestEvalAlignment < Test::Unit::TestCase
  def test_process_at_optimal_alignment
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_alignment_output('test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 direct')
  end
  def test_process_not_optimal_alignment
    assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", Helpers.eval_alignment_output('test/data/KLF4_f2.pat test/data/SP1_f1.pat 0 direct')
  end
  def test_process_at_optimal_alignment_reversed
    assert_equal "0.0\n0.0\t11\n.>>>>>>>>>>\n<<<<<<<<<<<\n-1\trevcomp\n", Helpers.eval_alignment_output('test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 revcomp')
  end
end
