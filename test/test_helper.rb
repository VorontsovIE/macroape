$lib_folder = File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift $lib_folder
require 'test/unit'
require 'stringio'
require 'shellwords'

require_relative '../lib/macroape/cli/find_threshold'
require_relative '../lib/macroape/cli/find_pvalue'
require_relative '../lib/macroape/cli/eval_similarity'
require_relative '../lib/macroape/cli/eval_alignment'
require_relative '../lib/macroape/cli/preprocess_collection'
require_relative '../lib/macroape/cli/scan_collection'
require_relative '../lib/macroape/cli/align_motifs'
 
module Helpers
  # from minitest
  def self.capture_io(&block)
    orig_stdout, orig_stderr = $stdout, $stderr
    captured_stdout, captured_stderr = StringIO.new, StringIO.new
    $stdout, $stderr = captured_stdout, captured_stderr
    yield
    return {stdout: captured_stdout.string, stderr: captured_stderr.string}
  ensure
    $stdout = orig_stdout
    $stderr = orig_stderr
  end
  
  # Method stubs $stdin not STDIN !
  def self.provide_stdin(input, &block)
    orig_stdin = $stdin
    $stdin = StringIO.new(input)
    yield
  ensure  
    $stdin = orig_stdin
  end
  
  def self.capture_output(&block)
    capture_io(&block)[:stdout]
  end
  def self.capture_stderr(&block)
    capture_io(&block)[:stderr]
  end
  
  def self.obtain_pvalue_by_threshold(args)
    find_pvalue_output(args).strip.split.last
  end
  def self.exec_cmd(executable, param_list)
    "ruby -I #{$lib_folder} #{$lib_folder}/../bin/#{executable} #{param_list}"
  end
  def self.find_threshold_output(param_list)
    capture_output{ Macroape::CLI::FindThreshold.main(param_list.shellsplit) }
  end
  def self.align_motifs_output(param_list)
    capture_output{ Macroape::CLI::AlignMotifs.main(param_list.shellsplit) }
  end
  def self.find_pvalue_output(param_list)
    capture_output{ Macroape::CLI::FindPValue.main(param_list.shellsplit) }
  end
  def self.eval_similarity_output(param_list)
    capture_output{ Macroape::CLI::EvalSimilarity.main(param_list.shellsplit) }
  end
  def self.eval_alignment_output(param_list)
    capture_output{ Macroape::CLI::EvalAlignment.main(param_list.shellsplit) }
  end
  def self.scan_collection_output(param_list)
    capture_output{ Macroape::CLI::ScanCollection.main(param_list.shellsplit) }
  end
  def self.scan_collection_stderr(param_list)
    capture_stderr{ Macroape::CLI::ScanCollection.main(param_list.shellsplit) }
  end
  def self.run_preprocess_collection(param_list)
    Macroape::CLI::PreprocessCollection.main(param_list.shellsplit)
  end

end
