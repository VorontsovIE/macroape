module PWMCompare
  class PWMCompare
    attr_reader :first, :second
    def initialize(first, second)
      @first = first
      @second = second
    end
    include PairTransformations, PairMetrics
  end
end