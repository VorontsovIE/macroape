module Macroape
  class PWMCompare
    attr_reader :first, :second
    def initialize(first, second)
      @first = first
      @second = second
    end

    def jaccard(threshold_first, threshold_second)
      self.map_each_alignment do |alignment|
        alignment.alignment_infos.merge( alignment.jaccard(threshold_first, threshold_second) )
      end.max_by {|alignment_infos| alignment_infos[:similarity] }
    end

    def each_alignment
      second_rc = second.reverse_complement
      (-second.length..first.length).to_a.product([:direct,:revcomp]) do |shift, orientation|
        yield PWMCompareAligned.new(first, (orientation == :direct ? second : second_rc), shift, orientation)
      end
    end
    
    include Enumerable
    alias_method :each, :each_alignment
    alias_method :map_each_alignment, :map
  end
end