class Array
  def partial_sums(initial = 0.0)
    sums = initial
    map{|el| sums+=el}
  end
end

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
  
    # ret-value: hash {pvalue => [thresholds, counts]}
    # thresholds = left_threshold .. right_threshold  (left_threshold < right_threshold)
    # counts = right_count .. left_count  (left_count > right_count)
    def thresholds_by_pvalues(*pvalues)
      max_pvalue = pvalues.max
      max_look_for_count = max_pvalue * vocabulary_volume
      scores={}
      until scores.inject(0.0){|sum,(score,count)| sum + count} >= max_look_for_count
        scores = count_distribution_after_threshold(threshold_gauss_estimation(max_pvalue))
        max_pvalue *=2 # if estimation counted too small amount of words - try to lower threshold estimation by doubling pvalue
      end
      
      pvalue_counts = pvalues.sort.collect_hash{|pvalue| [pvalue, pvalue * vocabulary_volume] }
      look_for_counts = pvalue_counts.to_a
      sum_count = 0.0
      scores = scores.sort.reverse
      results = {}
      scores.size.times do |i|
        while !look_for_counts.empty? and sum_count + scores[i][1] > look_for_counts.first[1] # usually this 'while' works as 'if'
          pval, score = look_for_counts.shift
          threshold_2, sum_count_2  =  scores[i][0].to_f, (sum_count + scores[i][1]).to_f
          if i > 0
            threshold = scores[i-1][0].to_f
            results[pval] = [threshold_2..threshold, sum_count_2..sum_count]
          else          
            results[pval] = [(threshold_2..best_score + 1.0), (0.0..sum_count_2)]
          end
        end
        
        sum_count += scores[i][1]
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