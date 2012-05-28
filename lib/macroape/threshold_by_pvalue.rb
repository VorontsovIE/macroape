module PWM
  module ThresholdByPvalue
    def threshold(pvalue)
      thresholds(pvalue){|_, thresh, _| return thresh }
    end
    
    def thresholds(*pvalues)
      thresholds_by_pvalues(*pvalues).each do |pvalue,(left_threshold, left_count, right_threshold, right_count)|
        threshold = left_threshold + 0.1
        real_pvalue = right_count.to_f / number_of_words
        yield pvalue, threshold, real_pvalue
      end
    end
  
    # ret-value: hash {pvalue => [left_threshold, left_count, right_threshold, right_count]}
    def thresholds_by_pvalues(*pvalues)
      max_pvalue = pvalues.max
      max_look_for_count = max_pvalue * sum_of_probabilities ** length
      scores={}
      until scores.inject(0){|sum,(score,count)| sum + count} >= max_look_for_count
        scores = calculate_count_distribution_after_threshold(threshold_gauss_estimation(max_pvalue))
        max_pvalue *=2 # if estimation counted too small amount of words - try to lower threshold estimation by doubling pvalue
      end
      pvalue_counts = pvalues.sort.inject(Hash.new){|h, pvalue| h.merge pvalue => pvalue * sum_of_probabilities**length }
      look_for_counts = pvalue_counts.to_a
      sum_count = 0
      scores = scores.sort.reverse
      results = {}
      scores.size.times do |i|
        while !look_for_counts.empty? and sum_count + scores[i][1] > look_for_counts.first[1] # usually this 'while' works as 'if'
          cnt = look_for_counts.shift
          pval = cnt[0]
          score = cnt[1]
          
          threshold_2 = scores[i][0]
          sum_count_2 = sum_count + scores[i][1]
          if i>0
            threshold = scores[i-1][0]
            results[pval] = [threshold_2.to_f, sum_count_2, threshold.to_f, sum_count.to_f]
          else          
            results[pval] = [threshold_2.to_f, sum_count_2.to_f, best_score + 1.0, 0.0]
          end
        end
        sum_count += scores[i][1]
      end
      results
    end
    
    def calculate_count_distribution_after_threshold(threshold)
      scores = { 0 => 1 }
      length.times do |column|
        new_scores = Hash.new(0);
        scores.each do |score, count|
          4.times do |letter|
            new_score = score + matrix[column][letter]
            if new_score + best_suffix[column + 1] >= threshold
              new_scores[new_score] += count * probabilities[letter]
            end
          end
        end
        raise 'Hash overflow in PWM::ThresholdByPvalue#calculate_count_distribution_after_threshold' if defined? MaxHashSize and new_scores.size > MaxHashSize
        scores = new_scores
      end
      scores
    end
    
  end
end