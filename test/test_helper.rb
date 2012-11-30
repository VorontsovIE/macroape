$bioinform_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bioinform', 'lib'))
$LOAD_PATH.unshift $bioinform_folder

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

  # aaa\tbbb\nccc\tddd  ==>  [['aaa','bbb'],['ccc','ddd']]
  def self.split_on_lines(str)
    str.lines.map{|line| line.strip.split("\t")}
  end

  def self.obtain_pvalue_by_threshold(args)
    find_pvalue_output(args).last.last
  end
  def self.exec_cmd(executable, param_list)
    "ruby -I #{$lib_folder} #{$lib_folder}/../bin/#{executable} #{param_list}"
  end
  def self.find_threshold_output(param_list)
    capture_output{ Macroape::CLI::FindThreshold.main(param_list.shellsplit) }
  end
  def self.align_motifs_output(param_list)
    split_on_lines( capture_output{ Macroape::CLI::AlignMotifs.main(param_list.shellsplit)} )
  end
  def self.find_pvalue_output(param_list)
    capture_output{ Macroape::CLI::FindPValue.main(param_list.shellsplit)} .lines.to_a.map(&:strip).reject{|line| line.start_with? '#' }.reject(&:empty?).map{|line|line.split("\t")}
  end
  def self.eval_similarity_output(param_list)
    capture_output{ Macroape::CLI::EvalSimilarity.main(param_list.shellsplit)}
  end
  def self.eval_alignment_output(param_list)
    capture_output{ Macroape::CLI::EvalAlignment.main(param_list.shellsplit)}
  end
  def self.scan_collection_output(param_list)
    capture_output{ Macroape::CLI::ScanCollection.main(param_list.shellsplit) }.lines.to_a.map(&:strip).reject{|line| line.start_with? '#' }.reject(&:empty?).join("\n")
  end
  def self.scan_collection_stderr(param_list)
    capture_stderr{ Macroape::CLI::ScanCollection.main(param_list.shellsplit) }
  end
  def self.run_preprocess_collection(param_list)
    Macroape::CLI::PreprocessCollection.main(param_list.shellsplit)
  end

  def parse_similarity_infos_string(info_string)
    infos = {}
    info_string.lines.map(&:strip).reject{|line| line.start_with?('#')}.reject(&:empty?).each do |line|
      key, value = line.split
      case key
        when 'S'  then infos[:similarity] = value
        when 'D'  then infos[:distance] = value
        when 'L'  then infos[:length] = value
        when 'SH'  then infos[:shift] = value
        when 'OR'  then infos[:orientation] = value
        when 'W'  then infos[:words_recognized_by_both] = value

        when 'W1' then infos[:words_recognized_by_first] = value
        when 'P1' then infos[:pvalue_recognized_by_first] = value
        when 'T1' then infos[:threshold_first] = value

        when 'W2' then infos[:words_recognized_by_second] = value
        when 'P2' then infos[:pvalue_recognized_by_second] = value
        when 'T2' then infos[:threshold_second] = value

        when 'A1'  then infos[:matrix_first_alignment] = value
        when 'A2'  then infos[:matrix_second_alignment] = value

        when 'V' then infos[:discretization] = value
      end
    end
    infos
  end

  def assert_similarity_info_output(expected_info, info_string)
    infos = parse_similarity_infos_string(info_string)
    expected_info.each do |key, value|
      assert_equal value.to_s, infos[key]
    end
  end

  def parse_threshold_infos_string(infos_string)
    infos = []
    infos_string.lines.map(&:strip).reject{|line| line.start_with?('#')}.reject(&:empty?).each do |line|
      info_data = line.split
      if info_data.size == 4
        requested_pvalue, real_pvalue, number_of_recognized_words, threshold = info_data
        info = {requested_pvalue: requested_pvalue,
                real_pvalue: real_pvalue,
                number_of_recognized_words: number_of_recognized_words,
                threshold: threshold }
      elsif info_data.size == 3
        requested_pvalue, real_pvalue, threshold = info_data
        info = {requested_pvalue: requested_pvalue,
                real_pvalue: real_pvalue,
                threshold: threshold }
      else
        raise 'can\'t parse threshold infos table'
      end
      infos << info
    end
    infos
  end

  def assert_threshold_info_output(*expected_infos, info_string)
    infos = parse_threshold_infos_string(info_string)
    expected_infos.zip(infos).each do |expected_info, info|
      assert_not_nil info
      expected_info.each do |key, value|
        assert_equal value.to_s, info[key]
      end
    end
  end

end
