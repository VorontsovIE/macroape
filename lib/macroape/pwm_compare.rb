module Macroape
  class PWMCompare
    # sets or gets limit of summary size of calculation hash. It's a defence against overuse CPU resources by non-appropriate data
    def max_hash_size!(new_max_hash_size)
      @max_hash_size = new_max_hash_size
      self
    end
    
    def max_hash_size(*args)
      case args.size
      when 0 then @max_hash_size
      when 1 then max_hash_size!(args.first)
      else raise ArgumentError, '#max_hash_size method can get 0 or 1 argument'
      end
    end
  
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
      (-second.length..first.length).to_a.product([:direct,:revcomp]) do |shift, orientation|
        yield PWMCompareAligned.new(first, second, shift, orientation).max_hash_size(max_hash_size)
      end
    end

    include Enumerable
    alias_method :each, :each_alignment
    alias_method :map_each_alignment, :map
  end
end