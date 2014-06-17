module Macroape
  class MotifWithThresholds
    attr_accessor :model
    attr_accessor :rough, :precise

    def initialize(model, options = {})
      @model = model
      @rough = options[:rough]
      @precise = options[:precise]
    end

    def ==(other)
        (model == other.model) &&
        (rough == other.rough) &&
        (precise == other.precise)
    end
  end
end
