# -*- encoding: utf-8 -*-
require File.expand_path('../lib/macroape/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ilya Vorontsov"]
  gem.email         = ["prijutme4ty@gmail.com"]
  gem.description   = %q{Macroape is an abbreviation for MAtrix CompaRisOn by Approximate P-value Estimation. It's a bioinformatic tool for evaluating similarity measure and best alignment between a pair of Position Weight Matrices(PWM), finding thresholds by P-values and inside out and even searching a collection of motifs for the most similar ones. Used approach and application described in manual at https://docs.google.com/document/pub?id=1_jsxhMNzMzy4d2d_byAd3n6Szg5gEcqG_Sf7w9tEqWw}
  gem.summary       = %q{PWM comparison tool using MACROAPE approach}
  gem.homepage      = "http://autosome.ru/macroape/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "macroape"
  gem.require_paths = ["lib"]
  gem.version       = Macroape::VERSION
  
  gem.add_dependency('bioinform', '= 0.1.8')
end
