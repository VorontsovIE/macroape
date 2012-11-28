require_relative 'test_helper'

class TestEvalAlignment < Test::Unit::TestCase
  include Helpers
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end

  def test_process_weak_threshold
    assert_similarity_info_output({similarity: 0.24382446963092125,
                                  distance: 0.7561755303690787,
                                  length: 11,
                                  shift: -1,
                                  orientation: 'direct',
                                  words_recognized_by_both: 839.0,
                                  threshold_first: 5.8,
                                  words_recognized_by_first: 2104.0,
                                  pvalue_recognized_by_first: 0.0005016326904296875,
                                  threshold_second: 5.6,
                                  words_recognized_by_second: 2176.0,
                                  pvalue_recognized_by_second: 0.000518798828125,
                                  matrix_first_alignment:  '.>>>>>>>>>>',
                                  matrix_second_alignment: '>>>>>>>>>>>',
                                  discretization: 10.0},
                                  Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 direct'))
  end


  def test_process_strong_threshold
    assert_similarity_info_output({similarity: 0.2420758234928527,
                                  distance: 0.7579241765071473,
                                  length: 11,
                                  shift: -1,
                                  orientation: 'direct',
                                  words_recognized_by_both: 779.0,
                                  threshold_first: 5.8100000000000005,
                                  words_recognized_by_first: 1964.0,
                                  pvalue_recognized_by_first: 0.00046825408935546875,
                                  threshold_second: 5.61,
                                  words_recognized_by_second: 2033.0,
                                  pvalue_recognized_by_second: 0.00048470497131347656,
                                  matrix_first_alignment:  '.>>>>>>>>>>',
                                  matrix_second_alignment: '>>>>>>>>>>>',
                                  discretization: 10.0},
                                  Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 direct --boundary lower'))
  end

  def test_process_custom_thresholds
    assert_similarity_info_output({similarity: 0.28505023241865346,
                                   words_recognized_by_both: 1901.0,
                                   words_recognized_by_first: 4348.0,
                                   words_recognized_by_second: 4222.0,
                                   threshold_first: 4.7,
                                   threshold_second: 4.6},
                                   Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 direct --first-threshold 4.7 --second-threshold 4.6'))
  end
  def test_process_not_optimal_alignment
    assert_similarity_info_output({similarity: 0.004517983923018248,
                                  length: 12,
                                  words_recognized_by_both: 77.0,
                                  words_recognized_by_first: 8416.0,
                                  words_recognized_by_second: 8704.0,
                                  matrix_first_alignment:  '>>>>>>>>>>..',
                                  matrix_second_alignment: '.>>>>>>>>>>>',
                                  shift: 1,
                                  orientation: 'direct'},
                                  Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm 1 direct'))
  end

  def test_process_at_optimal_alignment_reversed
    assert_similarity_info_output({similarity: 0.0,
                                  words_recognized_by_both: 0.0,
                                  length: 11,
                                  matrix_first_alignment: '.>>>>>>>>>>',
                                  matrix_second_alignment:'<<<<<<<<<<<',
                                  shift: -1,
                                  orientation: 'revcomp'},
                                  Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 revcomp'))
  end

  def test_process_pcm_files
    assert_equal( Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm -1 direct'),
                  Helpers.eval_alignment_output('KLF4_f2.pcm SP1_f1.pcm -1 direct --pcm'))
  end

  def test_process_alignment_first_motif_from_stdin
    result = Helpers.provide_stdin(File.read('KLF4_f2.pwm')) {
      Helpers.eval_alignment_output('.stdin SP1_f1.pwm 0 direct') }
    assert_equal( Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm 0 direct'),
                  result )
  end

  def test_process_alignment_second_motif_from_stdin
    result = Helpers.provide_stdin(File.read('SP1_f1.pwm')) {
      Helpers.eval_alignment_output('KLF4_f2.pwm .stdin 0 direct') }
    assert_equal( Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm 0 direct'),
                  result )
  end

  def test_process_alignment_both_motifs_from_stdin
    result = Helpers.provide_stdin(File.read('KLF4_f2.pwm') + File.read('SP1_f1.pwm')) {
      Helpers.eval_alignment_output('.stdin .stdin 0 direct') }
    assert_equal( Helpers.eval_alignment_output('KLF4_f2.pwm SP1_f1.pwm 0 direct'),
                  result )
  end
end