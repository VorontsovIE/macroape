require 'macroape/threshold_by_pvalue'

module Bioinform
  class PWM
    def counts_by_thresholds(*thresholds)
      scores = count_distribution_after_threshold(thresholds.min)
      thresholds.map{ |threshold|
        scores.inject(0){|sum,(score,count)|  (score >= threshold) ? sum + count : sum}
      }
    end

    def pvalue_by_threshold(threshold)
      counts_by_thresholds(threshold).first / vocabulary_volume
    end
  end
end