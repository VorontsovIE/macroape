module Macroape
  module AlignedPairTransformations
  
    #def discrete(rate)
    #  PWMCompareAligned.new(first.discrete(rate), second.discrete(rate))
    #end

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
  
  end
end