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
    assert_equal [%w[0.2420758234928527],
                  %w[779.0  11],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1  direct]], Helpers.eval_alignment_output('KLF4_f2.pcm SP1_f1.pcm -1 direct --pcm')
  end

  def test_process_at_optimal_alignment
    assert_equal [%w[0.2420758234928527],
                  %w[779.0  11],
                  %w[.>>>>>>>>>>],
                  %w[>>>>>>>>>>>],
                  %w[-1  direct]], Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 direct')
  end
  def test_process_not_optimal_alignment
    assert_equal [%w[0.0017543859649122807],
                  %w[7.0  11],
                  %w[>>>>>>>>>>.],
                  %w[>>>>>>>>>>>],
                  %w[0  direct]], Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm 0 direct')
  end
  def test_process_alignment_first_motif_from_stdin
    assert_equal [%w[0.0017543859649122807],
                  %w[7.0  11],
                  %w[>>>>>>>>>>.],
                  %w[>>>>>>>>>>>],
                  %w[0  direct]], Helpers.provide_stdin(File.read('KLF4_f2.pwm')) { Helpers.eval_alignment_output('.stdin SP1_f1.pwm 0 direct') }
  end
  def test_process_alignment_second_motif_from_stdin
    assert_equal [%w[0.0017543859649122807],
                  %w[7.0  11],
                  %w[>>>>>>>>>>.],
                  %w[>>>>>>>>>>>],
                  %w[0  direct]], Helpers.provide_stdin(File.read('SP1_f1.pwm')) { Helpers.eval_alignment_output('KLF4_f2.pwm .stdin 0 direct') }
  end
  def test_process_alignment_both_motifs_from_stdin
    assert_equal [%w[0.0017543859649122807],
                  %w[7.0  11],
                  %w[>>>>>>>>>>.],
                  %w[>>>>>>>>>>>],
                  %w[0  direct]],
                Helpers.provide_stdin(File.read('KLF4_f2.pwm') + File.read('SP1_f1.pwm')) { Helpers.eval_alignment_output('.stdin .stdin 0 direct') }
  end
  def test_process_at_optimal_alignment_reversed
    assert_equal [%w[0.0],
                  %w[0.0  11],
                  %w[.>>>>>>>>>>],
                  %w[<<<<<<<<<<<],
                  %w[-1  revcomp]], Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 revcomp')
  end
end