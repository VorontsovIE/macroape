require 'test/unit'

module Helpers
  def self.obtain_pvalue_by_threshold(args)
    IO.popen("find_pvalue #{args}",&:read).strip.split.last
  end
  def self.exec_cmd(executable, param_list)
    "ruby #{File.dirname(File.absolute_path __FILE__)}/../lib/macroape/exec/#{executable}.rb #{param_list}"
  end
end

class FindThresholdTest < Test::Unit::TestCase
  def test_process_several_pvalues
    pvalues = []
    IO.popen(Helpers.exec_cmd('find_threshold', 'test/data/KLF4_f2.pat -p 0.001 0.0005'), &:read).lines.each{|line| 
      pvalue, threshold, real_pvalue = line.strip.split("\t")
      pvalues << pvalue
      assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
    }
    assert_equal pvalues, ['0.0005', '0.001']
  end
  def test_process_one_pvalue
    pvalue, threshold, real_pvalue = IO.popen(Helpers.exec_cmd('find_threshold', 'test/data/KLF4_f2.pat -p 0.001'), &:read).strip.split("\t")
    assert_equal '0.001', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
  end
  def test_process_default_pvalue
    pvalue, threshold, real_pvalue = IO.popen(Helpers.exec_cmd('find_threshold','test/data/KLF4_f2.pat'), &:read).strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold}"), real_pvalue
  end
  def test_custom_discretization
    pvalue, threshold, real_pvalue = IO.popen(Helpers.exec_cmd('find_threshold','test/data/KLF4_f2.pat -d 100'), &:read).strip.split("\t")
    assert_equal '0.0005', pvalue
    assert_equal Helpers.obtain_pvalue_by_threshold("test/data/KLF4_f2.pat #{threshold} -d 100"), real_pvalue
  end
end

class FindPvalueTest < Test::Unit::TestCase
  def test_process_one_threshold
    IO.popen(Helpers.exec_cmd('find_pvalue', 'test/data/KLF4_f2.pat 4.1719')){|f|
      assert_equal "4.1719\t1048.0\t0.00099945068359375\n", f.read
    }
  end
  def test_process_several_thresholds
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 4.1719 5.2403')){|f|
      assert_equal "4.1719\t1048.0\t0.00099945068359375\n5.2403\t524.0\t0.000499725341796875\n", f.read
    }
  end
  def test_process_several_thresholds_result_is_ordered
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 5.2403 4.1719')){|f|
      assert_equal "5.2403\t524.0\t0.000499725341796875\n4.1719\t1048.0\t0.00099945068359375\n", f.read
    }
  end
  def test_custom_discretization
    IO.popen(Helpers.exec_cmd('find_pvalue','test/data/KLF4_f2.pat 5.2403 -d 100')){|f|
      assert_equal "5.2403\t527.0\t0.0005025863647460938\n", f.read
    }
  end
end


class TestEvalSimilarity < Test::Unit::TestCase
  def test_process_pair_of_pwms
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/KLF4_f2.pat test/data/SP1_f1.pat')){|f|
      assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", f.read
    }
  end
  def test_process_another_pair_of_pwms
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1.pat test/data/AHR_si.pat')){|f|
      assert_equal "0.0037332005973120955\n15.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>.\n1\tdirect\n", f.read
    }
  end
  
  def test_recognize_orientation_of_alignment
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1_revcomp.pat test/data/SP1_f1.pat')){|f|
      assert_equal "1.0\n2033.0\t11\n>>>>>>>>>>>\n<<<<<<<<<<<\n0\trevcomp\n", f.read
    }
  end

  def test_process_custom_discretization
    IO.popen(Helpers.exec_cmd('eval_similarity','test/data/SP1_f1.pat test/data/KLF4_f2.pat -d 1')){|f|
      assert_equal "0.22754919499105544\n636.0\t11\n>>>>>>>>>>>\n.>>>>>>>>>>\n1\tdirect\n", f.read
    }
  end
end

class TestEvalAlignmentSimilarity < Test::Unit::TestCase
  def test_process_at_optimal_alignment
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 direct')){|f|
      assert_equal "0.2420758234928527\n779.0\t11\n.>>>>>>>>>>\n>>>>>>>>>>>\n-1\tdirect\n", f.read
    }
  end
  def test_process_not_optimal_alignment
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat 0 direct')){|f|
      assert_equal "0.0017543859649122807\n7.0\t11\n>>>>>>>>>>.\n>>>>>>>>>>>\n0\tdirect\n", f.read
    }
  end
  def test_process_at_optimal_alignment_reversed
    IO.popen(Helpers.exec_cmd('eval_alignment','test/data/KLF4_f2.pat test/data/SP1_f1.pat -1 revcomp')){|f|
      assert_equal "0.0\n0.0\t11\n.>>>>>>>>>>\n<<<<<<<<<<<\n-1\trevcomp\n", f.read
    }
  end
end

class TestPreprocessCollection < Test::Unit::TestCase
  def test_multipvalue_preproceessing
    system(Helpers.exec_cmd('preprocess_collection','./test/data/test_collection -o test/data/test_collection.yaml.tmp -p 0.0005 0.0001 0.00005 --silent'))
    assert_equal File.read('test/data/test_collection.yaml'), File.read('test/data/test_collection.yaml.tmp')
    File.delete 'test/data/test_collection.yaml.tmp'
  end
end

class TestScanCollection < Test::Unit::TestCase
  def test_scan_default_cutoff
    assert_equal File.read('test/data/KLF4_f2_scan_results_default_cutoff.txt'), 
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --silent'), &:read)
  end
  def test_scan_and_output_all_results
    assert_equal File.read('test/data/KLF4_f2_scan_results_all.txt'), 
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --all --silent'), &:read)
      
  end
  def test_scan_precise_mode
    assert_equal File.read('test/data/KLF4_f2_scan_results_precise_mode.txt'),
                 IO.popen(Helpers.exec_cmd('scan_collection','test/data/KLF4_f2.pat test/data/test_collection.yaml --precise --all --silent'), &:read)
  end
end
