module Macroape
  class MatrixOnBackground < SingleMatrix
    attr_reader :probabilities
    def initialize(matrix,background)
      super(matrix)
      @probabilities = background
    end
    def sum_of_probabilities
      @sum_of_probabilities ||= probabilities.inject(0.0, &:+)
    end
    def number_of_words
      sum_of_probabilities ** length
    end
    include GaussEstimation, ThresholdByPvalue, CountByThreshold
  end
end