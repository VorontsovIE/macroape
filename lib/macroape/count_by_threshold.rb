module Macroape
  module CountByThreshold
    def counts_by_thresholds(*thresholds)
      scores = calculate_count_distribution_after_threshold(thresholds.min)
=begin
       thresholds.map{ |threshold|
       #scores.select{|score,count| score >= threshold}.map{|score,count| count}.inject(0){|sum,val|sum+val}
        scores.inject(0){|sum,(score,count)|  (score >= threshold) ? sum + count : sum}
      }
=end
      s_thr= thresholds.map.with_index{|threshold,index|[threshold,index]}.sort_by{|threshold,index| threshold}
      
      cnt = 0
      thr_cnts=[]
      
      scores.sort.reverse.each do |score,count|
        while !s_thr.empty? and score < s_thr.last[0]
          thr_cnts.push(cnt)
          s_thr.pop
        end
        cnt += count
      end
      s_thr = thresholds.map.with_index{|threshold,index|[threshold,index]}.sort_by{|threshold,index| threshold}
      while thr_cnts.size < s_thr.size
        thr_cnts.push(cnt)
      end
      s_thr.reverse.zip(thr_cnts).sort_by{|(threshold,index), count| index}.map{|(threshold,index), count| count.to_f}
    end

    def pvalue_by_threshold(threshold)
      counts_by_thresholds(threshold).first / number_of_words
    end
  end
end