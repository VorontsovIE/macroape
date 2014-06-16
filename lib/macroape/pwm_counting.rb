require 'bioinform'

module Macroape
  class PWMCounting
    attr_accessor :pwm, :max_hash_size, :background

    def initialize(pwm, background: Bioinform::Background::Wordwise, max_hash_size: nil)
      @pwm = pwm
      @background = background
      @max_hash_size = max_hash_size
    end

    def matrix
      pwm.matrix
    end

    def vocabulary_volume
      background.volume ** length
    end

    def threshold_gauss_estimation(max_pvalue)
      pwm.threshold_gauss_estimation(max_pvalue)
    end

    def length
      pwm.length
    end

    def best_score
      best_suffix(0)
    end

    def worst_score
      worst_suffix(0)
    end

    # best score of suffix s[i..l]
    def best_suffix(i)
      matrix[i...length].map(&:max).inject(0.0, &:+)
    end

    def worst_suffix(i)
      matrix[i...length].map(&:min).inject(0.0, &:+)
    end

    def score_mean
      pwm.each_position.inject(0.0){|mean, position| mean + background.mean(position) }
    end

    def score_variance
      pwm.each_position.inject(0.0){|variance, position| variance + background.mean_square(position) - background.mean(position) **2 }
    end

    def threshold_gauss_estimation(pvalue)
      sigma = Math.sqrt(score_variance)
      n_ = Math.inverf(1 - 2 * pvalue) * Math.sqrt(2)
      score_mean + n_ * sigma
    end

    def threshold(pvalue)
      thresholds(pvalue){|_, thresh, _| return thresh }
    end
    def threshold_and_real_pvalue(pvalue)
      thresholds(pvalue){|_, thresh, real_pv| return thresh, real_pv }
    end
    def weak_threshold(pvalue)
      weak_thresholds(pvalue){|_, thresh, _| return thresh }
    end
    def weak_threshold_and_real_pvalue(pvalue)
      weak_thresholds(pvalue){|_, thresh, real_pv| return thresh, real_pv }
    end

    def thresholds(*pvalues)
      thresholds_by_pvalues(*pvalues).each do |pvalue,(thresholds, counts)|
        threshold = thresholds.begin + 0.1 * (thresholds.end - thresholds.begin)
        real_pvalue = counts.end.to_f / vocabulary_volume
        yield pvalue, threshold, real_pvalue
      end
    end

    # "weak" means that threshold has real pvalue not less than given pvalue, while usual threshold not greater
    def weak_thresholds(*pvalues)
      thresholds_by_pvalues(*pvalues).each do |pvalue,(thresholds, counts)|
        threshold = thresholds.begin.to_f
        real_pvalue = counts.begin.to_f / vocabulary_volume
        yield pvalue, threshold, real_pvalue
      end
    end


    def count_distribution_under_pvalue(max_pvalue)
      cnt_distribution = {}
      look_for_count = max_pvalue * vocabulary_volume
      until cnt_distribution.inject(0.0){|sum,(score,count)| sum + count} >= look_for_count
        begin
          approximate_threshold = threshold_gauss_estimation(max_pvalue)
        rescue
          approximate_threshold = worst_score
        end
        cnt_distribution = count_distribution_after_threshold(approximate_threshold)
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
        scores.replace recalc_score_hash(scores, matrix[column], threshold - best_suffix(column + 1))
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
            new_scores[new_score] += count * background.counts[letter]
          end
        end
      end
      new_scores
    end

    def counts_by_thresholds(*thresholds)
      scores = count_distribution_after_threshold(thresholds.min)
      thresholds.inject({}){ |hsh, threshold|
        hsh[threshold] = scores.inject(0.0){|sum,(score,count)|  (score >= threshold) ? sum + count : sum}
        hsh
      }
    end

    def count_by_threshold(threshold)
      counts_by_thresholds(threshold)[threshold]
    end

    def pvalue_by_threshold(threshold)
      count_by_threshold(threshold) / vocabulary_volume
    end
  end
end
