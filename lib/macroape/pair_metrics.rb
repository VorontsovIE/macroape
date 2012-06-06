module Macroape
  module PairMetrics
    def jaccard(threshold_first, threshold_second)
      self.map_each_align do |align, alignment_info|
        align.jaccard(threshold_first, threshold_second).merge(alignment_info)
      end.max_by {|alignment_info| alignment_info[:similarity]}
    end
  end
end