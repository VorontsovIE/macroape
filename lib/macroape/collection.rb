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
  end
end