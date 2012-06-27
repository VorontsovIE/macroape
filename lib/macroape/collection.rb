module Macroape
  class Collection
    attr_reader :rough_discretization, :precise_discretization, :background, :pvalues, :pwms, :infos
    def initialize(rough_discretization, precise_discretization, background, pvalues)
      @rough_discretization, @precise_discretization, @background, @pvalues = rough_discretization, precise_discretization, background, pvalues
      @pwms={}
      @infos={}
    end
    def add_pwm(pwm,info)
      @pwms[pwm.name] = pwm
      @infos[pwm.name] = info
    end
    def ==(other)
      @rough_discretization == other.rough_discretization && 
      @precise_discretization == other.precise_discretization && 
      @background == other.background && 
      @pvalues == other.pvalues && 
      @pwms == other.pwms &&
      @infos == other.infos
    end
  end
end