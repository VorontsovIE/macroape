module Macroape
  class Collection
    attr_accessor :motifs, :rough_discretization, :precise_discretization, :background, :pvalues

    def initialize(options = {})
      @motifs = options[:motifs] || []
      @rough_discretization = options[:rough_discretization]
      @precise_discretization = options[:precise_discretization]
      @background = options[:background]
      @pvalues = options[:pvalues]
    end

    def ==(other)
        (motifs == other.motifs) &&
        (rough_discretization == other.rough_discretization) &&
        (precise_discretization == other.precise_discretization) &&
        (background == other.background) &&
        (pvalues == other.pvalues)
    end

    def <<(motif_with_thresholds)
      @motifs << motif_with_thresholds
    end

    def size
      motifs.size
    end
  end
end
