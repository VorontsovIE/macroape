module Macroape
  class MotifWithThresholds < Bioinform::Motif
    attr_accessor :rough, :precise, :background, :max_hash_size

    def initialize(options = {})
      super
      @rough = options[:rough]
      @precise = options[:precise]
      @background = options[:background]
      @max_hash_size = options[:max_hash_size]
    end

    def ==(other)
      super &&
        (rough == other.rough) &&
        (precise == other.precise) &&
        (background == other.background) &&
        (max_hash_size == other.max_hash_size)
    end
  end
end
