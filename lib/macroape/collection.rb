require 'ostruct'

module Macroape
  class Collection
    attr_reader :parameters, :pwms, :infos
    def initialize(rough_discretization, precise_discretization, background, pvalues)
      @parameters = OpenStruct.new(rough_discretization: rough_discretization, 
                                    precise_discretization: precise_discretization,
                                    background: background,
                                    pvalues: pvalues)
      @pwms={}
      @infos={}
    end
    def add_pwm(pwm,info)
      pwms[pwm.name] = pwm
      infos[pwm.name] = info
    end
    def ==(other)
      (parameters == other.parameters) && (pwms == other.pwms) && (infos == other.infos)
    end
  end
end