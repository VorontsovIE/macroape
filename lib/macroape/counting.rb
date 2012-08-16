module Bioinform
  class PWM
    def max_hash_size!(new_max_hash_size)
      @max_hash_size = new_max_hash_size
      self
    end
    
    def max_hash_size(*args)
      case args.size
      when 0 then @max_hash_size
      when 1 then max_hash_size!(args.first)
      else raise ArgumentError, '#max_hash_size method can get 0 or 1 argument'
      end
    end
    
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
      cnt_distribution = {}
      look_for_count = max_pvalue * vocabulary_volume
      until cnt_distribution.inject(0.0){|sum,(score,count)| sum + count} >= look_for_count
        cnt_distribution = count_distribution_after_threshold(threshold_gauss_estimation(max_pvalue))
        max_pvalue *=2 # if estimation counted too small amount of words - try to lower threshold estimation by doubling pvalue
      end

      cnt_distribution
    end


    # ret-value: hash {pvalue => [thresholds, counts]}
    # thresholds = left_threshold .. right_threshold  (left_threshold < right_threshold)
    # counts = left_count .. right_count  (left_count > right_count)
    def thresholds_by_pvalues(*pvalues)
      sorted_scores = count_distribution_under_pvalue(pvalues.max).sort.reverse
      scores = sorted_scores.map{|score,count| score}
      counts = sorted_scores.map{|score,count| count}
      partial_sums = counts.partial_sums

      results = {}

      pvalue_counts = pvalues.sort.collect_hash{|pvalue| [pvalue, pvalue * vocabulary_volume] }
      pvalue_counts.map do |pvalue,look_for_count|
        ind = partial_sums.index{|sum| sum >= look_for_count}
        minscore, count_at_minscore = scores[ind], partial_sums[ind]
        maxscore, count_at_maxscore = ind > 0  ?  [ scores[ind-1],  partial_sums[ind-1] ]  :  [ best_score + 1.0, 0.0 ]
        results[pvalue] = [(minscore .. maxscore), (count_at_minscore .. count_at_maxscore)]
      end

      results
    end

    def count_distribution_after_threshold(threshold)
      return @count_distribution.select{|score, count| score >= threshold}  if @count_distribution
      scores = { 0 => 1 }
      length.times do |column|
        scores.replace recalc_score_hash(scores, @matrix[column], threshold - best_suffix(column + 1))
        raise 'Hash overflow in PWM::ThresholdByPvalue#count_distribution_after_threshold'  if max_hash_size && scores.size > max_hash_size
      end
      scores
    end

    def count_distribution
      @count_distribution ||= count_distribution_after_threshold(worst_score)
    end

    def recalc_score_hash(scores, column, least_sufficient)
      new_scores = Hash.new(0)
      scores.each do |score, count|
        4.times do |letter|
          new_score = score + column[letter]
          if new_score >= least_sufficient
            new_scores[new_score] += count * @background[letter]
          end
        end
      end
      new_scores
    end

    def counts_by_thresholds(*thresholds)
      scores = count_distribution_after_threshold(thresholds.min)
      thresholds.map{ |threshold|
        scores.inject(0.0){|sum,(score,count)|  (score >= threshold) ? sum + count : sum}
      }
    end

    def pvalue_by_threshold(threshold)
      counts_by_thresholds(threshold).first / vocabulary_volume
    end
  end
end