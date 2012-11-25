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
                  %w[1964.0 2033.0],
                  %w[0.00046825408935546875 0.00048470497131347656],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1 direct]],  Helpers.eval_similarity_output('KLF4_f2.pcm SP1_f1.pcm --pcm --strong-threshold')
  end
  def test_process_weak_thresholds
    assert_equal [%w[0.24382446963092125],
                  %w[839.0  11],
                  %w[2104.0 2176.0],
                  %w[0.0005016326904296875 0.000518798828125],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1 direct]],  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm')
  end
  def test_process_custom_threshold
    assert_equal [%w[0.28505023241865346],
                  %w[1901.0  11],
                  %w[4348.0 4222.0],
                  %w[0.0010366439819335938 0.0010066032409667969],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1 direct]],  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm --first-threshold 4.7 --second-threshold 4.6')
  end

  def test_process_pair_of_pwms
    assert_equal [%w[0.2420758234928527],
                  %w[779.0  11],
                  %w[1964.0 2033.0],
                  %w[0.00046825408935546875 0.00048470497131347656],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1  direct]],  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm --strong-threshold')
  end
  def test_process_another_pair_of_pwms
    assert_equal [%w[0.0037332005973120955],
                  %w[15.0  11],
                  %w[2033.0 2000.0],
                  %w[0.00048470497131347656 0.000476837158203125],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>.],
                  %w[1  direct]], Helpers.eval_similarity_output('SP1_f1.pwm AHR_si.pwm --strong-threshold')
  end

  def test_recognize_orientation_of_alignment
    assert_equal [%w[1.0],
                  %w[2033.0  11],
                  %w[2033.0 2033.0],
                  %w[0.00048470497131347656 0.00048470497131347656],
                  %w[>>>>>>>>>>>],
                  %w[<<<<<<<<<<<],
                  %w[0  revcomp]], Helpers.eval_similarity_output('SP1_f1_revcomp.pwm SP1_f1.pwm --strong-threshold')
  end

  def test_process_custom_discretization
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[1863.0 1568.0],
                  %w[0.00044417381286621094 0.00037384033203125],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]], Helpers.eval_similarity_output('SP1_f1.pwm KLF4_f2.pwm -d 1 --strong-threshold')
  end

  def test_process_first_motif_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[1863.0 1568.0],
                  %w[0.00044417381286621094 0.00037384033203125],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]],
      Helpers.provide_stdin(File.read('SP1_f1.pwm')){ Helpers.eval_similarity_output('.stdin KLF4_f2.pwm -d 1 --strong-threshold') }
  end

  def test_process_second_motif_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[1863.0 1568.0],
                  %w[0.00044417381286621094 0.00037384033203125],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1 direct]],
      Helpers.provide_stdin(File.read('KLF4_f2.pwm')){
        Helpers.eval_similarity_output('SP1_f1.pwm .stdin -d 1 --strong-threshold')
      }
  end

  def test_process_both_motifs_from_stdin
    assert_equal [%w[0.22754919499105544],
                  %w[636.0  11],
                  %w[1863.0 1568.0],
                  %w[0.00044417381286621094 0.00037384033203125],
                  %w[>>>>>>>>>>>],
                  %w[.>>>>>>>>>>],
                  %w[1  direct]],
      Helpers.provide_stdin(File.read('SP1_f1.pwm') + File.read('KLF4_f2.pwm')){ Helpers.eval_similarity_output('.stdin .stdin -d 1 --strong-threshold') }
  end



end
