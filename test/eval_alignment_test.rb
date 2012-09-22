require_relative 'test_helper'

class TestEvalAlignment < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end
  def test_process_pcm_files
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_alignment_output('KLF4_f2.pcm SP1_f1.pcm -1 direct --pcm')
  end

  def test_process_at_optimal_alignment
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_alignment_output('KLF4_f2.pat SP1_f1.pat -1 direct')
  end
  def test_process_not_optimal_alignment
    assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", Helpers.eval_alignment_output('KLF4_f2.pat SP1_f1.pat 0 direct')
  end
  def test_process_alignment_first_motif_from_stdin
    assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", 
      Helpers.provide_stdin(File.read('KLF4_f2.pat')) {
        Helpers.eval_alignment_output('.stdin SP1_f1.pat 0 direct')
      }
  end
  def test_process_alignment_second_motif_from_stdin
    assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", 
      Helpers.provide_stdin(File.read('SP1_f1.pat')) {
        Helpers.eval_alignment_output('KLF4_f2.pat .stdin 0 direct')
      }
  end
  def test_process_alignment_both_motifs_from_stdin
    assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", 
      Helpers.provide_stdin(File.read('KLF4_f2.pat') + File.read('SP1_f1.pat')) {
        Helpers.eval_alignment_output('.stdin .stdin 0 direct')
      }
  end
  def test_process_at_optimal_alignment_reversed
    assert_equal "0.0\n0.0\t11\n.>>>>>>>>>>\n<<<<<<<<<<<\n-1\trevcomp\n", Helpers.eval_alignment_output('KLF4_f2.pat SP1_f1.pat -1 revcomp')
  end
end
