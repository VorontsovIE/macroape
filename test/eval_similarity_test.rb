require_relative 'test_helper'

class TestEvalSimilarity < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end
  def test_process_pair_of_pcms
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_similarity_output('KLF4_f2.pcm SP1_f1.pcm --pcm')
  end
  def test_process_pair_of_pwms
    assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", Helpers.eval_similarity_output('KLF4_f2.pat SP1_f1.pat')
  end
  def test_process_another_pair_of_pwms
    assert_equal "0.0037332005973120955\n15.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>.\n1\tdirect\n", Helpers.eval_similarity_output('SP1_f1.pat AHR_si.pat')
  end
  
  def test_recognize_orientation_of_alignment
    assert_equal "1.0\n2033.0\t11\n>>>>>>>>>>>\n<<<<<<<<<<<\n0\trevcomp\n", Helpers.eval_similarity_output('SP1_f1_revcomp.pat SP1_f1.pat')
  end

  def test_process_custom_discretization
    assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", Helpers.eval_similarity_output('SP1_f1.pat KLF4_f2.pat -d 1')
  end
  
  def test_process_first_motif_from_stdin
    assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", 
      Helpers.provide_stdin(File.read('SP1_f1.pat')){
        Helpers.eval_similarity_output('.stdin KLF4_f2.pat -d 1')
      }
  end
  
  def test_process_second_motif_from_stdin
    assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", 
      Helpers.provide_stdin(File.read('KLF4_f2.pat')){ 
        Helpers.eval_similarity_output('SP1_f1.pat .stdin -d 1') 
      }
  end

  def test_process_both_motifs_from_stdin
    assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", 
      Helpers.provide_stdin(File.read('SP1_f1.pat') + File.read('KLF4_f2.pat')){
        Helpers.eval_similarity_output('.stdin .stdin -d 1')
      }
  end


  
end
