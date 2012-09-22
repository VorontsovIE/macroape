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
    assert_equal [%w[0.2420758234928527],
                  %w[779.0  11],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1 direct]],  Helpers.eval_similarity_output('KLF4_f2.pcm SP1_f1.pcm --pcm')
  end
  def test_process_pair_of_pwms
    assert_equal [%w[0.2420758234928527],
                  %w[779.0  11],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1  direct]],  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm')
  end
  def test_process_another_pair_of_pwms
    assert_equal [%w[0.0037332005973120955],
                  %w[15.0  11],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>.],
                  %w[1  direct]], Helpers.eval_similarity_output('SP1_f1.pwm AHR_si.pwm')
  end

  def test_recognize_orientation_of_alignment
    assert_equal [%w[1.0],
                  %w[2033.0  11],
                  %w[>>>>>>>>>>>],
                  %w[<<<<<<<<<<<],
                  %w[0  revcomp]], Helpers.eval_similarity_output('SP1_f1_revcomp.pwm SP1_f1.pwm')
  end

  def test_process_custom_discretization
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]], Helpers.eval_similarity_output('SP1_f1.pwm KLF4_f2.pwm -d 1')
  end

  def test_process_first_motif_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]],
      Helpers.provide_stdin(File.read('SP1_f1.pwm')){ Helpers.eval_similarity_output('.stdin KLF4_f2.pwm -d 1') }
  end

  def test_process_second_motif_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1 direct]],
      Helpers.provide_stdin(File.read('KLF4_f2.pwm')){
        Helpers.eval_similarity_output('SP1_f1.pwm .stdin -d 1')
      }
  end

  def test_process_both_motifs_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]],
      Helpers.provide_stdin(File.read('SP1_f1.pwm') + File.read('KLF4_f2.pwm')){ Helpers.eval_similarity_output('.stdin .stdin -d 1') }
  end



end
