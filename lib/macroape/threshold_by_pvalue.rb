module Bioinform
  class PM
    def threshold(pvalue)
      thresholds(pvalue){|_, thresh, _| return thresh }
    end
    
    def thresholds(*pvalues)
      thresholds_by_pvalues(*pvalues).each do |pvalue,(thresholds, counts)|
        threshold = thresholds.begin + 0.1 * (thresholds.end - thresholds.begin)
        real_pvalue = counts.end.to_f / vocabulary_volume
        yield pvalue, threshold, real_pvalue
      end
    end
  
    def count_distribution_under_pvalue(max_pvalue)
      count_distribution={}
      look_for_count = max_pvalue * vocabulary_volume
      until count_distribution.inject(0.0){|sum,(score,count)| sum + count} >= look_for_count
        count_distribution = count_distribution_after_threshold(threshold_gauss_estimation(max_pvalue))
        max_pvalue *=2 # if estimation counted too small amount of words - try to lower threshold estimation by doubling pvalue
      end
      
      count_distribution
    end
  
  
    # ret-value: hash {pvalue => [thresholds, counts]}
    # thresholds = left_threshold .. right_threshold  (left_threshold < right_threshold)
    # counts = left_count .. right_count  (left_count > right_count)
    def thresholds_by_pvalues(*pvalues)
      
      count_distribution = count_distribution_under_pvalue(pvalues.max)
      
      pvalue_counts = pvalues.sort.collect_hash{|pvalue| [pvalue, pvalue * vocabulary_volume] }
      look_for_counts = pvalue_counts.to_a
      
      sorted_scores = count_distribution.sort.reverse
      scores = sorted_scores.map{|score,count| score}
      counts = sorted_scores.map{|score,count| count}
      
      partial_sums = counts.partial_sums
      results = {}      
      pvalue_counts.map do |pv,look_for_count|
        ind = partial_sums.index{|sum| sum >= look_for_count}
        if ind > 0
          results[pv] = [ (scores[ind] .. scores[ind-1]), (partial_sums[ind] .. partial_sums[ind-1]) ]
        else
          results[pv] = [(scores[ind] .. best_score+1.0), (partial_sums[ind] .. 0.0)]
        end
      end

      results
    end
    
    def count_distribution_after_threshold(threshold)
      scores = { 0 => 1 }
      length.times do |column|
        new_scores = Hash.new(0);
        scores.each do |score, count|
          4.times do |letter|
            new_score = score + @matrix[column][letter]
            if new_score + best_suffix[column + 1] >= threshold
              new_scores[new_score] += count * background[letter]
            end
          end
        end
        raise 'Hash overflow in PWM::ThresholdByPvalue#count_distribution_after_threshold' if defined? MaxHashSizeSingle and new_scores.size > MaxHashSizeSingle
        scores = new_scores
      end
      scores
    end
    
  end
end