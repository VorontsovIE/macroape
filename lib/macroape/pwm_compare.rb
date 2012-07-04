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
        cmp = PWMCompareAligned.new(first, (orientation == :direct ? second : second_rc), shift, orientation)
       
        yield(cmp,
              text: "#{cmp.first_pwm_alignment}\n#{cmp.second_pwm_alignment}",
              shift: cmp.shift,
              orientation: orientation,
              overlap: cmp.overlap,
              alignment_length: cmp.alignment_length
              )
      end
    end
    include Enumerable
    alias :each_align :each
    alias :map_each_align :map
    
  end
end