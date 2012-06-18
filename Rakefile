#!/usr/bin/env rake
require "bundler/gem_tasks"

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
  task :all => [:find_threshold, :find_pvalue, :eval_similarity,
                :eval_alignment_similarity, :scan_collection, :preprocess_collection]
end

desc 'Test all functionality of gem executables'
task :spec => ['spec:all']