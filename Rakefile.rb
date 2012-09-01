#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'rake/testtask'

namespace :spec do
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
  end  
  RSpec::Core::RakeTask.new
end

desc 'Test all functionality of gem executables'
task :spec => ['spec:test', 'spec:spec']

namespace :benchmark do
  task :run do
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
  task :show do
    puts File.read('benchmark/benchmark.log')
  end
end

task :benchmark => 'benchmark:run'