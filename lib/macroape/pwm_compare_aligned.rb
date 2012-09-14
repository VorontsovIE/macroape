require 'ostruct'
require_relative './aligned_pair_intersection'

module Macroape
  class PWMCompareAligned
    attr_reader :first, :second, :length, :shift, :orientation, :first_length, :second_length, :parameters
    
    def initialize(first_unaligned, second_unaligned, shift, orientation)
      @parameters = OpenStruct.new
      @shift, @orientation = shift, orientation

      @first_length, @second_length = first_unaligned.length, second_unaligned.length
      @length = self.class.calculate_alignment_length(@first_length, @second_length, @shift)

      first, second = first_unaligned, second_unaligned
      second = second.reverse_complement  if revcomp?
      
      if shift > 0
        second = second.left_augment(shift)
      else
        first = first.left_augment(-shift)
      end

      @first = first.right_augment(@length - first.length)
      @second = second.right_augment(@length - second.length)
    end
    
    def max_pair_hash_size=(new_max_pair_hash_size); parameters.max_pair_hash_size = new_max_pair_hash_size; end
    def max_pair_hash_size; parameters.max_pair_hash_size; end
    def set_parameters(hsh)
      hsh.each{|k,v| send("#{k}=", v) }
      self
    end

    def direct?
      orientation == :direct
    end
    def revcomp?
      orientation == :revcomp
    end

    def overlap
      length.times.count{|pos| first_overlaps?(pos) && second_overlaps?(pos) }
    end

    def first_pwm_alignment
      length.times.map do |pos|
        if first_overlaps?(pos)
          '>'
        else
          '.'
        end
      end.join
    end

    def second_pwm_alignment
      length.times.map do |pos|
        if second_overlaps?(pos)
          direct? ? '>' : '<'
        else
          '.'
        end
      end.join
    end

    def alignment_infos
      {shift: shift,
      orientation: orientation,
      text: "#{first_pwm_alignment}\n#{second_pwm_alignment}",
      overlap: overlap,
      alignment_length: length}
    end

    # whether first matrix overlap specified position of alignment
    def first_overlaps?(pos)
      return false unless pos >= 0 && pos < length
      if shift > 0
        pos < first_length
      else
        pos >= -shift && pos < -shift + first_length
      end
    end

    def second_overlaps?(pos)
      return false unless pos >= 0 && pos < length
      if shift > 0
        pos >= shift && pos < shift + second_length
      else
        pos < second_length
      end
    end

=begin
    def discrete(rate)
      PWMCompareAligned.new(first.discrete(rate), second.discrete(rate))
    end

    def sort_pair_of_matrices_by(&block)
      mat = first.pwm.zip(second.pwm).sort_by(&block).transpose
      PWMCompareAligned.new(SinglePWM(mat[0],first.probabilities), SinglePWM(mat[1], second.probabilities))
    end
    def sort_decreasing_max
      PWMCompareAligned.new(*sort_pair_of_matrices_by{|col_pair| -col_pair[0].max} )
    end
    def sort_increasing_min
      PWMCompareAligned.new(*sort_pair_of_matrices_by{|col_pair| col_pair[0].min} )
    end
    def permute_columns(permutation_index)
      PWMCompareAligned.new(first.permute(permutation_index), second.permute(permutation_index))
    end
=end

    def jaccard(first_threshold, second_threshold)
      f = first.counts_by_thresholds(first_threshold).first
      s = second.counts_by_thresholds(second_threshold).first
      if f == 0 || s == 0
        return {similarity: -1, tanimoto: -1, recognized_by_both: 0,
              recognized_by_first: f,
              recognized_by_second: s,
            }
      end

      intersect = counts_for_two_matrices(first_threshold, second_threshold)
      intersect = Math.sqrt(intersect[0] * intersect[1])
      union = f + s - intersect
      similarity = intersect.to_f / union
      { similarity: similarity,  tanimoto: 1.0 - similarity,  recognized_by_both: intersect,
        recognized_by_first: f,  recognized_by_second: s }
    end
    
    def jaccard_by_pvalue(pvalue)
      threshold_first = first.threshold(pvalue)
      threshold_second = second.threshold(pvalue)
      jaccard(threshold_first, threshold_second)
    end

    def self.calculate_alignment_length(first_len, second_len, shift)
      if shift > 0
        [first_len, second_len + shift].max
      else
        [first_len - shift, second_len].max
      end
    end
  end

end