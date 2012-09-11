require 'ostruct'

module Macroape
  class Collection
    attr_reader :parameters, :collection
    def initialize(rough_discretization, precise_discretization, background, pvalues)
      @collection = []
      @parameters = OpenStruct.new(rough_discretization: rough_discretization, 
                                    precise_discretization: precise_discretization,
                                    background: background,
                                    pvalues: pvalues)
    end
    def <<(pm)
      collection << [pm, OpenStruct.new]
    end
    def add_pm(pm, info)
      collection << [pm, info]
    end
    
    def ==(other)
      (parameters == other.parameters) && (collection == other.collection)
    end
    
    def each
      if block_given?
        collection.each{|pm, infos| yield [pm, infos]}
      else
        Enumerator.new(self, :each)
      end
    end
    
    def each_pm
      if block_given?
        collection.each_key{|pm| yield pm}
      else
        Enumerator.new(self, :each_pm)
      end
    end

    include Enumerable

    %w[pcm ppm pwm].each do |data_model|
      method_name = "each_#{data_model}".to_sym       #
      converter_method = "to_#{data_model}".to_sym    #
      define_method method_name do |&block|           # define_method :each_pcm do |&block|
        if block                                      #   if block
          each do |pm, infos|                         #     each do |pm, infos|
            block.call pm.send(converter_method)      #       block.call pm.send(:to_pcm)
          end                                         #     end
        else                                          #   else
          Enumerator.new(self, method_name)           #     Enumerator.new(self, :each_pcm)
        end                                           #   end
      end                                             # end
    end

    
  end
end