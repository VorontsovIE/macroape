module Macroape
  module MatrixInformation
    def length
      @length ||= matrix.length
    end
    def best_score
      @best_score ||= matrix.inject(0){|sum, col| sum + col.max}
    end
    def worst_score
      @worst_score ||= matrix.inject(0){|sum, col| sum + col.min}
    end
    def best_suffix
      return @best_suffix if @best_suffix
      @best_suffix = Array.new(length + 1, 0) # best score of suffix s[i..l]
      length.times{|i| @best_suffix[length - i - 1] = matrix[length - i - 1].max + @best_suffix[length - i] }
      @best_suffix
    end
    def worst_suffix
      return @worst_suffix if @worst_suffix
      @worst_suffix = Array.new(length + 1, 0)
      length.times{|i| @worst_suffix[length - i - 1] = matrix[length - i - 1].min + @worst_suffix[length - i] }
      @worst_suffix
    end
    def refresh_infos
      @length = @best_score = @worst_score = @best_suffix = @worst_suffix = nil
      self
    end
  end
end