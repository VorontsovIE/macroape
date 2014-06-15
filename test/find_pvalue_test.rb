require_relative 'test_helper'

class FindPvalueTest < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end
  def test_process_pcm
    assert_equal [%w[4.1719 1048.0 0.00099945068359375]], Helpers.find_pvalue_output('KLF4_f2.pcm 4.1719 --pcm')
  end
  def test_process_one_threshold
    assert_equal [%w[4.1719 1048.0 0.00099945068359375]], Helpers.find_pvalue_output('KLF4_f2.pwm 4.1719')
  end
  def test_process_several_thresholds
    assert_equal [%w[4.1719 1048.0 0.00099945068359375],
                  %w[5.2403 524.0 0.000499725341796875]], Helpers.find_pvalue_output('KLF4_f2.pwm 4.1719 5.2403')
  end
  def test_process_several_thresholds_result_is_ordered
    assert_equal [%w[5.2403 524.0 0.000499725341796875],
                  %w[4.1719 1048.0 0.00099945068359375]], Helpers.find_pvalue_output('KLF4_f2.pwm 5.2403 4.1719')
  end
  def test_custom_discretization
    assert_equal [%w[5.2403 527.0 0.0005025863647460938]], Helpers.find_pvalue_output('KLF4_f2.pwm 5.2403 -d 100')
  end
  def test_probability_wise_backgrond
    assert_equal [%w[5.2403 0.0005025863647460938]], Helpers.find_pvalue_output('KLF4_f2.pwm 5.2403 -d 100 -b 0.25,0.25,0.25,0.25')
  end
  def test_custom_background
    assert_equal [%w[5.2403 6.815000000000001e-06]], Helpers.find_pvalue_output('KLF4_f2.pwm 5.2403 -b 0.4,0.1,0.1,0.4')
  end
  def test_process_pwm_from_stdin
    assert_equal Helpers.find_pvalue_output('KLF4_f2.pwm 1'),
                Helpers.provide_stdin(File.read 'KLF4_f2.pwm'){  Helpers.find_pvalue_output('.stdin 1') }
  end
end
