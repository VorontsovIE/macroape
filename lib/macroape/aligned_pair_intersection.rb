module Macroape
  class PWMCompareAligned

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
        raise 'Hash overflow in Macroape::AlignedPairIntersection#counts_for_two_matrices_with_different_probabilities' if new_scores.inject(0){|sum,hsh|sum+hsh.size} > MaxHashSizeDouble
        scores = new_scores
      end
      [result_first, result_second]
    end
    
    def counts_for_two_matrices_with_same_probabilities(threshold_first, threshold_second)
      scores = { 0 => {0 => 1} } # scores_on_first_pwm, scores_on_second_pwm --> count_on_first_probabilities, count_on_second_probabilities
      result = 0.0
      background = first.background
      length.times do |column|    
        ending_weight =  first.background_sum ** (length - column - 1)
        already_enough_first  = threshold_first  - first.worst_suffix[column + 1]
        already_enough_second = threshold_second - second.worst_suffix[column + 1]
        least_sufficient_first  = threshold_first  - first.best_suffix[column + 1]
        least_sufficient_second = threshold_second - second.best_suffix[column + 1]

        new_scores = Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]=0} }
        scores.each do |score_first, second_scores|
          second_scores.each do |score_second, count|
            4.times do |letter|          
              new_score_first = score_first + first.matrix[column][letter]
              if new_score_first >= already_enough_first 
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= already_enough_second
                  result += count * background[letter] * ending_weight
                elsif new_score_second >= least_sufficient_second 
                  new_scores[new_score_first][new_score_second] += count * background[letter]
                end
              elsif new_score_first >= least_sufficient_first
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= least_sufficient_second
                  new_scores[new_score_first][new_score_second] += count * background[letter]
                end
              end
            end
          end
        end
        raise 'Hash overflow in Macroape::AlignedPairIntersection#counts_for_two_matrices_with_same_probabilities' if new_scores.inject(0){|sum,hsh|sum+hsh.size} > MaxHashSizeDouble
        scores = new_scores
      end
      [result, result]
    end
    
    
    def common_words_for_two_matrices(threshold_first, threshold_second)
      scores = { 0 => {0 => 1} } # scores_on_first_pwm, scores_on_second_pwm --> count_on_first_probabilities, count_on_second_probabilities
      result = 0
      length.times do |column|
        ending_weight =  4 ** (length - column - 1)
        already_enough_first  = threshold_first  - first.worst_suffix[column + 1]
        already_enough_second = threshold_second - second.worst_suffix[column + 1]
        least_sufficient_first  = threshold_first  - first.best_suffix[column + 1]
        least_sufficient_second = threshold_second - second.best_suffix[column + 1]

        new_scores = Hash.new{|h,k| h[k]=Hash.new{|h2,k2| h2[k2]=0} }
        scores.each do |score_first, second_scores|
          second_scores.each do |score_second, count|
            4.times do |letter|
              new_score_first = score_first + first.matrix[column][letter]
              if new_score_first >= already_enough_first
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= already_enough_second
                  result += count * ending_weight
                elsif new_score_second >= least_sufficient_second
                  new_scores[new_score_first][new_score_second] += count
                end
              elsif new_score_first >= least_sufficient_first
                new_score_second = score_second + second.matrix[column][letter]
                if new_score_second >= least_sufficient_second
                  new_scores[new_score_first][new_score_second] += count
                end
              end
            end
          end
        end
        
        raise 'Hash overflow in Macroape::AlignedPairIntersection#common_words_for_two_matrices' if defined? MaxHashSizeDouble and new_scores.inject(0){|sum,hsh|sum+hsh.size} > MaxHashSizeDouble
        scores = new_scores
      end
      [result, result]
    end
    
  end
end