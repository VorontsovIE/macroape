# Macroape

Macroape is abbreviation for MAtrix CompaRisOn by Approximate P-value Estimation. It's a bioinformatic tool for evaluating similarity measure between a pair of Position Weight Matrices. Used approach and application described in manual at https://docs.google.com/document/pub?id=1_jsxhMNzMzy4d2d_byAd3n6Szg5gEcqG_Sf7w9tEqWw

## Installation

Add this line to your application's Gemfile:

    gem 'macroape'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install macroape

## Usage
  For more information read manual at https://docs.google.com/document/pub?id=1_jsxhMNzMzy4d2d_byAd3n6Szg5gEcqG_Sf7w9tEqWw (not last version but comprehensive description of approach)

## Basic usage as a command-line tool
  MacroAPE have 6 command line tools:
  
### Tools for calculating thresholds and pvalues:
  * find_threshold \<PWM file\> [-p \<pvalue\> (by default: 0.0005)]
  * find_pvalue \<PWM file\> \<threshold\>
  
### Tools for evaluating Jaccard similarity measure in the best alignment and in certain alignment:
  * eval_similarity \<first PWM file\> \<second PWM file\>
  * eval_alignment \<first PWM file\> \<second PWM file\> \<shift of second matrix\> \<orientation of second matrix(direct|revcomp)\>
  
### Tools for looking through collection for the motifs most similar to a query motif
  * preprocess_collection \<folder with motif files\> [-o \<collection output file\>]
  * scan_collection \<query PWM file\> \<collection file\>
  
  Also you can use -h option to print help for a tool in console.
  There are lots of different command line options. Most useful option is -d <discretization=1|10|100|1000>. You can vary precision/speed rate by specifing a discretization. For more information look through a manual.

## Basic usage in your code
    require 'macroape'
    background = [1,1,1,1]
    discretization = 10
    first_pwm_matrix = [[1,2,3,4], [1,2,3,4], [4,1,2,3,], [5,3,2,4], [4,1,2,3], [7,8,9,11]]
    pwm_first = PWM::SingleMatrix.new(first_pwm_matrix).with_background(background).discrete(discretization)
    pwm_second = PWM::SingleMatrix.load_pat('another_pwm.pat').with_background(background).discrete(discretization)
    cmp = PWMCompare::PWMCompare.new(pwm_first, pwm_second)
    first_threshold = pwm_first.threshold(pvalue)
    second_threshold = pwm_second.threshold(pvalue)
    similarity_info = cmp.jaccard(first_threshold, second_threshold)
    puts "Jaccard similarity: #{similarity_info[:similarity]}"

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright (c) 2011-2012 Ilya Vorontsov, Ivan Kulakovskiy, Vsevolod Makeev