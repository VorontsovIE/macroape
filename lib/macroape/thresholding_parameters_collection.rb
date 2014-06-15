module Macroape
  class ThresholdingParametersCollection < Bioinform::Collection
    attr_accessor :rough_discretization, :precise_discretization, :background, :pvalues

    def initialize(options = {})
      super
      @rough_discretization = options[:rough_discretization]
      @precise_discretization = options[:precise_discretization]
      @background = options[:background]
      @pvalues = options[:pvalues]
    end

    def ==(other)
      super &&
        (rough_discretization == other.rough_discretization) &&
        (precise_discretization == other.precise_discretization) &&
        (background == other.background) &&
        (pvalues == other.pvalues)
    end

    def add_pm(pm, info)
      container << Macroape::MotifWithThresholds.new(info.merge(pm: pm))
      self
    end
  end
end
