module Macroape
  class PWMCompareAligned
    
    # unoptimized version of this and related methods
    def counts_for_two_matrices(threshold_first, threshold_second)
      return counts_for_two_matrices_with_different_probabilities(threshold_first, threshold_second)  unless first.background == second.background
      if first.background == [1,1,1,1]
        unoptimized_get_counts(threshold_first, threshold_second,:unoptimized_recalc_score_hash_common_words)
      else
        unoptimized_get_counts(threshold_first, threshold_second, :unoptimized_recalc_score_hash_same_background)
      end
    end
  
    def unoptimized_get_counts(threshold_first, threshold_second, meth = :unoptimized_recalc_score_hash_different_probabilities)
      # scores_on_first_pwm, scores_on_second_pwm --> count
      scores = { 0 => {0 => 1} }
      length.times do |column|
        scores.replace(send(meth, scores,
                            @first.matrix[column], @second.matrix[column],
                            threshold_first - first.best_suffix[column + 1],
                            threshold_second - second.best_suffix[column + 1]))
        if defined?(MaxHashSizeDouble) && scores.inject(0){|sum,hsh|sum + hsh.size} > MaxHashSizeDouble
          raise 'Hash overflow in Macroape::AlignedPairIntersection#counts_for_two_matrices_with_different_probabilities'
        end
      end
      result = scores.inject(0.0){|sum,(score_first, hsh)| sum + hsh.inject(0.0){|sum,(score_second, count)| sum + count }}
      [result, result]
    end

  
    def unoptimized_recalc_score_hash_same_background(scores, first_column, second_column, least_sufficient_first, least_sufficient_second)
      new_scores = Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2] = 0}}
      scores.each do |score_first, second_scores|
        second_scores.each do |score_second, count|

          4.times do |letter|
            new_score_first = score_first + first_column[letter]
            if new_score_first >= least_sufficient_first
              new_score_second = score_second + second_column[letter]
              if new_score_second >= least_sufficient_second
                new_scores[new_score_first][new_score_second] += count * first.background[letter]
              end
            end
          end
          
        end
      end
      new_scores
    end
    
    def unoptimized_recalc_score_hash_common_words(scores, first_column, second_column, least_sufficient_first, least_sufficient_second)
      new_scores = Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2] = 0}}
      scores.each do |score_first, second_scores|
        second_scores.each do |score_second, count|

          4.times do |letter|
            new_score_first = score_first + first_column[letter]
            if new_score_first >= least_sufficient_first
              new_score_second = score_second + second_column[letter]
              if new_score_second >= least_sufficient_second
                new_scores[new_score_first][new_score_second] += count
              end
            end
          end
          
        end
      end
      new_scores
    end
    
=begin
  # another version of counting methods
    def counts_for_two_matrices(threshold_first, threshold_second)
      if first.background == second.background
        if first.background == [1,1,1,1]
          common_words_for_two_matrices(threshold_first, threshold_second)
        else
          counts_for_two_matrices_with_same_probabilities(threshold_first, threshold_second)
        end
      else
        counts_for_two_matrices_with_different_probabilities(threshold_first, threshold_second)
      end
    end
=end
    def counts_for_two_matrices_with_different_probabilities(threshold_first, threshold_second)
      scores = { 0 => {0 => [1,1]} } # scores_on_first_pwm, scores_on_second_pwm --> count_on_first_probabilities, count_on_second_probabilities
      result_first = 0.0
      result_second = 0.0
      length.times do |column|
        ending_weight_first =  first.background_sum ** (length - column - 1)
        ending_weight_second = second.background_sum ** (length - column - 1)
        already_enough_first  = threshold_first  - first.worst_suffix[column + 1]
        already_enough_second = threshold_second - second.worst_suffix[column + 1]
        least_sufficient_first  = threshold_first  - first.best_suffix[column + 1]
        least_sufficient_second = threshold_second - second.best_suffix[column + 1]

        new_scores = Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]=[0,0]}}
        scores.each do |score_first, second_scores|
          second_scores.each do |score_second, count|
            4.times do |letter|
              new_score_first = score_first + first.matrix[column][letter]
              if new_score_first >= already_enough_first
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= already_enough_second
                  result_first += count[0] * first.background[letter] * ending_weight_first
                  result_second += count[1] * second.background[letter] * ending_weight_second
                elsif new_score_second >= least_sufficient_second
                  new_scores[new_score_first][new_score_second][0] += count[0] * first.background[letter]
                  new_scores[new_score_first][new_score_second][1] += count[1] * second.background[letter]
                end
              elsif new_score_first >= least_sufficient_first
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= least_sufficient_second
                  new_scores[new_score_first][new_score_second][0] += count[0] * first.background[letter]
                  new_scores[new_score_first][new_score_second][1] += count[1] * second.background[letter]
                end
              end
            end
          end
        end
        raise 'Hash overflow in Macroape::AlignedPairIntersection#counts_for_two_matrices_with_different_probabilities' if defined?(MaxHashSizeDouble) &&new_scores.inject(0){|sum,hsh|sum+hsh.size} > MaxHashSizeDouble
        scores = new_scores
      end
      [result_first, result_second]
    end

  end
end