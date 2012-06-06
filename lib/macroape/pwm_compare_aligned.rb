module Macroape
  class PWMCompareAligned
    attr_reader :first, :second, :length
    def initialize(first, second)
      @length = [first.length, second.length].max
      @first = first.right_augment(@length - first.length)
      @second = second.right_augment(@length - second.length)
    end
    
    include AlignedPairTransformations, AlignedPairMetrics, AlignedPairIntersection
    
  end
end