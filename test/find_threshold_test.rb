require_relative 'test_helper'

class FindThresholdTest < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end
  def test_process_several_pvalues
    pvalues = []
    Helpers.find_threshold_output('KLF4_f2.pwm -p 0.001 0.0005').lines.each{|line|
      pvalue, threshold, real_pvalue = line.strip.split("\t")
      pvalues << pvalue
      assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold}"), real_pvalue
    }
    assert_equal pvalues, ['0.0005', '0.001']
  end
  def test_process_pcm
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('KLF4_f2.pcm -p 0.001 --pcm').strip.split("\t")
    assert_equal '0.001', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold}"), real_pvalue
  end
  def test_process_one_pvalue
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('KLF4_f2.pwm -p 0.001').strip.split("\t")
    assert_equal '0.001', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold}"), real_pvalue
    assert real_pvalue.to_f >= 0.001
  end
  def test_process_one_pvalue_strong
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('KLF4_f2.pwm -p 0.001 --strong-threshold').strip.split("\t")
    assert_equal '0.001', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold}"), real_pvalue
    assert real_pvalue.to_f <= 0.001
  end
  def test_process_default_pvalue
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('KLF4_f2.pwm').strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold}"), real_pvalue
  end
  def test_custom_discretization
    pvalue, threshold, real_pvalue = Helpers.find_threshold_output('KLF4_f2.pwm -d 100').strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("KLF4_f2.pwm #{threshold} -d 100"), real_pvalue
  end
  def test_process_pwm_from_stdin
    assert_equal Helpers.find_threshold_output('KLF4_f2.pwm'),
                Helpers.provide_stdin(File.read('KLF4_f2.pwm')){ Helpers.find_threshold_output('.stdin') }
  end

  # TODO: it should be rewritten as a spec for count_distribution_under_pvalue - not to raise an error(log out of domain) and return a value
  def test_process_large_pvalue
    pvalue, threshold, real_pvalue = nil, nil, nil
    assert_nothing_raised {
      pvalue, threshold, real_pvalue = Helpers.find_threshold_output('SP1_f1.pwm -p 0.8').strip.split("\t")
    }
    assert_equal '0.8', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("SP1_f1.pwm #{threshold}"), real_pvalue
  end
end

