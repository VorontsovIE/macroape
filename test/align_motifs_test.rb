require_relative 'test_helper'

class TestAlignmotifs < Test::Unit::TestCase
  def setup
    @start_dir = Dir.pwd
    Dir.chdir File.join(File.dirname(__FILE__), 'data')
  end
  def teardown
    Dir.chdir(@start_dir)
  end

  def test_align_motifs
    assert_equal [%w[KLF4_f2.pwm 0 direct],
                  %w[KLF3_f1.pwm -4 direct],
                  %w[SP1_f1_revcomp.pwm -1 revcomp]],
      Helpers.align_motifs_output('KLF4_f2.pwm  KLF3_f1.pwm  SP1_f1_revcomp.pwm')
  end
  def test_align_pcm_motifs
    assert_equal [%w[KLF4_f2.pcm 0 direct],
                  %w[KLF3_f1.pcm -4 direct],
                  %w[SP1_f1_revcomp.pcm -1 revcomp]],
      Helpers.align_motifs_output('--pcm KLF4_f2.pcm  KLF3_f1.pcm  SP1_f1_revcomp.pcm')
  end
  def test_names_from_stdin_leader_specified
    assert_equal [%w[KLF4_f2.pwm 0 direct],
                  %w[KLF3_f1.pwm -4 direct],
                  %w[SP1_f1_revcomp.pwm -1 revcomp]],
      Helpers.provide_stdin('KLF3_f1.pwm  SP1_f1_revcomp.pwm'){ Helpers.align_motifs_output('KLF4_f2.pwm') }
  end
  def test_names_from_stdin_leader_not_specified
    assert_equal [%w[KLF4_f2.pwm 0 direct],
                  %w[KLF3_f1.pwm -4 direct],
                  %w[SP1_f1_revcomp.pwm -1 revcomp]],
      Helpers.provide_stdin('KLF4_f2.pwm  KLF3_f1.pwm  SP1_f1_revcomp.pwm'){ Helpers.align_motifs_output('') }
  end
  def test_names_from_stdin_duplicate_leader
    assert_equal [%w[KLF4_f2.pwm 0 direct],
                  %w[KLF3_f1.pwm -4 direct],
                  %w[SP1_f1_revcomp.pwm -1 revcomp]],
      Helpers.provide_stdin('KLF3_f1.pwm KLF4_f2.pwm SP1_f1_revcomp.pwm'){ Helpers.align_motifs_output('KLF4_f2.pwm') }
  end
end
