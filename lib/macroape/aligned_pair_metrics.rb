module Macroape
  module AlignedPairMetrics
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
      { similarity: similarity,
        tanimoto: 1.0 - similarity,
        recognized_by_both: intersect,
        recognized_by_first: f,
        recognized_by_second: s }
    end
  end
end