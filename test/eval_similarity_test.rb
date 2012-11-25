require_relative 'test_helper'

class TestEvalSimilarity < Test::Unit::TestCase
  include Helpers
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end

  def test_process_strong_thresholds
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
                                  matrix_second_alignment: '>>>>>>>>>>>'},
                                  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm --strong-threshold'))
  end

  def test_process_weak_thresholds
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
                                  matrix_second_alignment: '>>>>>>>>>>>'},
                                  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm'))
  end
  def test_process_custom_threshold
    assert_similarity_info_output({similarity: 0.28505023241865346,
                                  words_recognized_by_both: 1901.0,
                                  words_recognized_by_first: 4348.0,
                                  words_recognized_by_second: 4222.0,
                                  threshold_first: 4.7,
                                  threshold_second: 4.6},
                                  Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm --first-threshold 4.7 --second-threshold 4.6'))
  end

  def test_process_dissimilar_pair_of_pwms
    assert_similarity_info_output({similarity: 0.0037332005973120955,
                                  words_recognized_by_both: 15.0,
                                  words_recognized_by_first: 2033.0,
                                  words_recognized_by_second: 2000.0,
                                  length: 11,
                                  matrix_first_alignment:  '>>>>>>>>>>>',
                                  matrix_second_alignment: '.>>>>>>>>>.',
                                  shift: 1,
                                  orientation: 'direct'},
                                  Helpers.eval_similarity_output('SP1_f1.pwm AHR_si.pwm --strong-threshold'))
  end

  def test_recognize_orientation_of_alignment
    assert_similarity_info_output({similarity: 1.0,
                                  words_recognized_by_both: 2176.0,
                                  words_recognized_by_first: 2176.0,
                                  words_recognized_by_second: 2176.0,
                                  length: 11,
                                  matrix_first_alignment:  '>>>>>>>>>>>',
                                  matrix_second_alignment: '<<<<<<<<<<<',
                                  shift: 0,
                                  orientation: 'revcomp'},
                                  Helpers.eval_similarity_output('SP1_f1_revcomp.pwm SP1_f1.pwm'))
  end

  def test_process_custom_discretization
    assert_similarity_info_output({similarity: 0.2580456407255705,
                                  words_recognized_by_both: 1323.0,
                                  words_recognized_by_first: 3554.0,
                                  words_recognized_by_second: 2896.0,
                                  length: 11,
                                  matrix_first_alignment:  '>>>>>>>>>>>',
                                  matrix_second_alignment: '.>>>>>>>>>>',
                                  shift: 1,
                                  orientation: 'direct'},
                                  Helpers.eval_similarity_output('SP1_f1.pwm KLF4_f2.pwm -d 1'))
  end

  def test_process_pcm_files
    assert_equal( Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm'),
                  Helpers.eval_similarity_output('KLF4_f2.pcm SP1_f1.pcm --pcm'))
  end

  def test_process_first_motif_from_stdin
    result = Helpers.provide_stdin(File.read('KLF4_f2.pwm')){
      Helpers.eval_similarity_output('.stdin SP1_f1.pwm') }
    assert_equal(Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm'), result)
  end

  def test_process_second_motif_from_stdin
    result = Helpers.provide_stdin(File.read('SP1_f1.pwm')){
      Helpers.eval_similarity_output('KLF4_f2.pwm .stdin') }
    assert_equal(Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm'), result)
  end

  def test_process_both_motifs_from_stdin
    result = Helpers.provide_stdin(File.read('KLF4_f2.pwm') + File.read('SP1_f1.pwm')){
      Helpers.eval_similarity_output('.stdin .stdin') }
    assert_equal(Helpers.eval_similarity_output('KLF4_f2.pwm SP1_f1.pwm'), result)
  end
end
