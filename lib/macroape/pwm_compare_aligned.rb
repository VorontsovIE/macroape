require 'macroape/aligned_pair_intersection'

module Macroape
  class PWMCompareAligned
    attr_reader :first, :second, :length
    def initialize(first, second)
      @length = [first.length, second.length].max
      @first = first.right_augment(@length - first.length)
      @second = second.right_augment(@length - second.length)
    end
    
=begin    
    def discrete(rate)
      PWMCompareAligned.new(first.discrete(rate), second.discrete(rate))
    end

    def sort_pair_of_matrices_by(&block)
      mat = first.pwm.zip(second.pwm).sort_by(&block).transpose
      PWMCompareAligned.new(SinglePWM(mat[0],first.probabilities), SinglePWM(mat[1], second.probabilities))
    end
    def sort_decreasing_max
      PWMCompareAligned.new(*sort_pair_of_matrices_by{|col_pair| -col_pair[0].max} )
    end
    def sort_increasing_min
      PWMCompareAligned.new(*sort_pair_of_matrices_by{|col_pair| col_pair[0].min} )
    end
    def permute_columns(permutation_index)
      PWMCompareAligned.new(first.permute(permutation_index), second.permute(permutation_index))
    end
=end

    def jaccard(first_threshold, second_threshold)
      f = first.counts_by_thresholds(first_threshold).first
      s = second.counts_by_thresholds(second_threshold).first
      if f == 0 or s == 0
        return {similarity: -1, tanimoto: -1, recognized_by_both: 0,
              recognized_by_first: f,
              recognized_by_second: s,
            }
      end
      
      intersect = counts_for_two_matrices(first_threshold, second_threshold)
      intersect = Math.sqrt(intersect[0] * intersect[1])
      union = f + s - intersect
      similarity = intersect.to_f / union
      { similarity: similarity,  tanimoto: 1.0 - similarity,  recognized_by_both: intersect,
        recognized_by_first: f,  recognized_by_second: s }
    end
    
  end
end