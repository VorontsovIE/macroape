#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

namespace :spec do
  task :find_threshold do
    system("ruby -I ./test test/find_threshold_test.rb")
  end
  task :find_pvalue do
    system("ruby -I ./test test/find_pvalue_test.rb")
  end
  task :eval_similarity do
    system("ruby -I ./test test/eval_similarity_test.rb")
  end
  task :eval_alignment_similarity do
    system("ruby -I ./test test/eval_alignment_similarity_test.rb")
  end
  task :preprocess_collection do
    system("ruby -I ./test test/preprocess_collection_test.rb")
  end
  task :scan_collection do
    system("ruby -I ./test test/scan_collection_test.rb")
  end
  task :tests => [:find_threshold, :find_pvalue, :eval_similarity,
                :eval_alignment_similarity, :scan_collection, :preprocess_collection]
  
  RSpec::Core::RakeTask.new
end

desc 'Test all functionality of gem executables'
task :spec => ['spec:tests', 'spec:spec']

task :benchmark do
  require 'open3'
  time = Time.now.strftime("%d-%m-%Y, %H:%M:%S sec")
  File.open('benchmark/benchmark.log','a') do |f| 
    f.puts "=========================================================\n#{time}\n"  
    Dir.glob('benchmark/*_benchmark.rb') do |benchmark_filename|
      Open3.popen3("ruby -I ./benchmark #{benchmark_filename}") do |inp, out, err, wait_thr|
        benchmark_name = File.basename(benchmark_filename)
        out_str = out.read
        err_str = err.read
        
        benchmark_infos =  "-------------------\n#{benchmark_name}:\n#{out_str}\n"
        benchmark_infos_to_file = benchmark_infos
        puts benchmark_infos
        
        if err_str && !err_str.empty?
          STDERR.puts(err_str)
          benchmark_infos_to_file = benchmark_infos + "\n!!!\nError:\n#{err_str}\n"
        end
        
        # add info about git commit (if everything is commited, otherwise to commit one should use special option -c)
        f.puts benchmark_infos_to_file
      end
    end
  end
end