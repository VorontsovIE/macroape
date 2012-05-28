module PWM
  module MatrixTransformations
    def reverse_complement
      clone_and_transform( matrix.reverse.map(&:reverse) ).refresh_infos
    end
    def left_augment(n)
      clone_and_transform( [[0.0]*4]* n + matrix ).refresh_infos
    end
    def right_augment(n)
      clone_and_transform( matrix + [[0.0]*4]* n ).refresh_infos
    end
    def shift_to_zero # make worst score == 0 by shifting scores of each column
      clone_and_transform( matrix.map{|col| col.map{|letter| letter - col.min}} ).refresh_infos
    end
    def discrete(rate)
      clone_and_transform( matrix.map{|col| col.map{|letter| (letter * rate).ceil}} ).refresh_infos
    end
    def split(length_of_first_part)
      [clone_and_transform( matrix.first(length_of_first_part)).refresh_infos, clone_and_transform(matrix.last(length - length_of_first_part)).refresh_infos]
    end
    def permute_columns(permutation_index)
      clone_and_transform( permutation_index.map{|col| matrix[col]} ).refresh_infos
    end
    
    def clone_and_transform(new_matrix)
      self.dup.instance_eval{ @matrix = new_matrix; self }
    end
  end
end