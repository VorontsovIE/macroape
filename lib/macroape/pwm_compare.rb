module Macroape
  class PWMCompare
    attr_reader :first, :second
    def initialize(first, second)
      @first = first
      @second = second
    end

    def jaccard(threshold_first, threshold_second)
      self.map_each_align do |align, alignment_info|
        align.jaccard(threshold_first, threshold_second).merge(alignment_info)
      end.max_by {|alignment_info| alignment_info[:similarity]}
    end
    
    
    def each
      second_rc = second.reverse_complement
      (-second.length..first.length).to_a.product([:direct,:revcomp]) do |shift, orientation|
        first_pwm_alignment = '.' * [-shift, 0].max + '>' * first.length
        second_pwm_alignment = '.' * [shift, 0].max + (orientation == :direct ? '>' : '<') * second.length
        overlap = [first.length + [-shift,0].max, second.length + [shift,0].max].min - shift.abs
        alignment_length = [first_pwm_alignment.length, second_pwm_alignment.length].max
        (first_pwm_alignment.length...alignment_length).each{|i| first_pwm_alignment[i] = '.'}
        (second_pwm_alignment.length...alignment_length).each{|i| second_pwm_alignment[i] = '.'}
        
        yield(PWMCompareAligned.new(first.left_augment([-shift,0].max), 
                                    (orientation == :direct ? second : second_rc).left_augment([shift,0].max)),
              text: "#{first_pwm_alignment}\n#{second_pwm_alignment}",
              shift: shift,
              orientation: orientation,
              overlap: overlap,
              alignment_length: alignment_length
              )
      end
    end
    include Enumerable
    alias :each_align :each
    alias :map_each_align :map
    
  end
end