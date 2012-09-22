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
    assert_equal [%w[KLF4_f2.pat 0 direct],
                  %w[KLF3_f1.pat -4 direct],
                  %w[SP1_f1_revcomp.pat -1 revcomp]],
      Helpers.align_motifs_output('KLF4_f2.pat  KLF3_f1.pat  SP1_f1_revcomp.pat')
  end
  def test_align_pcm_motifs
    assert_equal [%w[KLF4_f2.pcm 0 direct],
                  %w[KLF3_f1.pcm -4 direct],
                  %w[SP1_f1_revcomp.pcm -1 revcomp]],
      Helpers.align_motifs_output('--pcm KLF4_f2.pcm  KLF3_f1.pcm  SP1_f1_revcomp.pcm')
  end
end