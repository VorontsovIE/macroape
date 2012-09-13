require_relative 'test_helper'

class TestAlignmotifs < Test::Unit::TestCase
  def test_align_motifs
    assert_equal "test/data/KLF4_f2.pat\t0\tdirect\ntest/data/KLF3_f1.pat\t-4\tdirect\ntest/data/SP1_f1_revcomp.pat\t-1\trevcomp\n", 
      Helpers.align_motifs_output('test/data/KLF4_f2.pat  test/data/KLF3_f1.pat  test/data/SP1_f1_revcomp.pat')
  end
  def test_align_pcm_motifs
    assert_equal "test/data/KLF4_f2.pcm\t0\tdirect\ntest/data/KLF3_f1.pcm\t-4\tdirect\ntest/data/SP1_f1_revcomp.pcm\t-1\trevcomp\n", 
      Helpers.align_motifs_output('--pcm test/data/KLF4_f2.pcm  test/data/KLF3_f1.pcm  test/data/SP1_f1_revcomp.pcm')
  end
end