require_relative 'test_helper'

class FindThresholdTest < Test::Unit::TestCase
  include Helpers
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end

  def test_process_one_pvalue_weak_thresold
    assert_threshold_info_output({requested_pvalue: 0.001,
                                  real_pvalue: 0.0010004043579101562,
                                  number_of_recognized_words: 1049.0,
                                  threshold: 4.1718},
                                  Helpers.find_threshold_output("KLF4_f2.pwm 0.001 --boundary upper") )
    # additional consistency checks
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm 4.1718"), '0.0010004043579101562'
  end

  def test_process_one_pvalue_strong_thresold
    assert_threshold_info_output({requested_pvalue: 0.001,
                                  real_pvalue: 0.00099945068359375,
                                  number_of_recognized_words: 1048.0,
                                  threshold: 4.17189},
                                  Helpers.find_threshold_output("KLF4_f2.pwm 0.001") )
    # additional consistency checks
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm 4.17189"), '0.00099945068359375'
  end

  def test_process_several_pvalues
    pvalues = []
    assert_threshold_info_output({requested_pvalue: 0.0005,
                                  real_pvalue: 0.000499725341796875,
                                  number_of_recognized_words: 524.0,
                                  threshold: 5.24071},
                                  {requested_pvalue: 0.001,
                                  real_pvalue: 0.00099945068359375,
                                  number_of_recognized_words: 1048.0,
                                  threshold: 4.17189},
                                  Helpers.find_threshold_output('KLF4_f2.pwm 0.001 0.0005') )
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm 4.17189"), '0.00099945068359375'
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm 5.24071"), '0.000499725341796875'
  end

  def test_process_pcm
    assert_equal( Helpers.find_threshold_output("KLF4_f2.pwm"),
                  Helpers.find_threshold_output("KLF4_f2.pcm --pcm"))
  end

  def test_process_default_pvalue
    assert_equal( Helpers.find_threshold_output("KLF4_f2.pwm 0.0005"),
                  Helpers.find_threshold_output("KLF4_f2.pwm"))
  end
  def test_custom_discretization
    assert_threshold_info_output({requested_pvalue: 0.0005,
                                  real_pvalue: 0.0004978179931640625,
                                  number_of_recognized_words: 522.0,
                                  threshold: 5.281000000000001},
                                  Helpers.find_threshold_output("KLF4_f2.pwm -d 100") )
    # additional consistency checks
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm 5.281000000000001 -d 100"), '0.0004978179931640625'
  end
  def test_custom_background
    assert_threshold_info_output({requested_pvalue: 0.0005,
                                  real_pvalue: '0.00049964290000001',
                                  threshold: '-0.10449000000000001'},
                                  Helpers.find_threshold_output("KLF4_f2.pwm -b 0.4,0.1,0.1,0.4") )
    # additional consistency checks
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm -0.10449000000000001 -b 0.4,0.1,0.1,0.4"), '0.0004996429000000166' # here real pvalue differs at last digits =\
  end
  def test_process_pwm_from_stdin
    assert_equal Helpers.find_threshold_output('KLF4_f2.pwm'),
                Helpers.provide_stdin(File.read('KLF4_f2.pwm')){ Helpers.find_threshold_output('.stdin') }
  end

  # TODO: it should be rewritten as a spec for count_distribution_under_pvalue - not to raise an error(log out of domain) and return a value
  def test_process_large_pvalue
    assert_nothing_raised do
      # discretization is set not to take very long time calculation
      assert_threshold_info_output({requested_pvalue: 0.8,
                                  real_pvalue: 0.7996518611907959,
                                  number_of_recognized_words: 3353983.0,
                                  threshold: -17.89},
                                  Helpers.find_threshold_output('SP1_f1.pwm 0.8 -d 10') )
    end
    assert_equal Helpers.obtain_pvalue_by_threshold("SP1_f1.pwm -17.89 -d 10"), '0.7996518611907959'
  end
end