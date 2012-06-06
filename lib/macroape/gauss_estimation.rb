module Macroape
  module GaussEstimation
    def score_mean
      bckgr = probabilities.map{|v| v.to_f / sum_of_probabilities}
      matrix.inject(0.0){ |mean, col| mean + 4.times.inject(0.0){|sum,letter| sum + col[letter] * bckgr[letter]} }
    end
    def score_variance
      bckgr = probabilities.map{|v| v.to_f / sum_of_probabilities}
      matrix.inject(0.0) do |variance, col|
        variance  + 4.times.inject(0.0) { |sum,letter| sum + col[letter]**2 * bckgr[letter] } -
                    4.times.inject(0.0) { |sum,letter| sum + col[letter]    * bckgr[letter] }**2
      end
    end
    def threshold_gauss_estimation(pvalue)
      sigma = Math.sqrt(score_variance)
      n_ = inverf2(1 - 2 * pvalue) * Math.sqrt(2)
      score_mean + n_ * sigma
    end
    def inverf2(x)
      sign = x < 0 ? -1 : 1
      x = x.abs
      a = 8 / (3*Math::PI) * (Math::PI-3) / (4-Math::PI)
      part0 = ( 2/(Math::PI*a) + (Math.log(1-x*x)) / 2 )**2
      part = -2 / (Math::PI * a) - Math.log(1-x*x)/2 + Math.sqrt(-1/a *
      Math.log(1-x*x) + part0)
      sign * Math.sqrt(part)
    end   
  end
  
end