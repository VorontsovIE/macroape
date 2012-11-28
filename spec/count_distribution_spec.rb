require_relative 'spec_helper'
require_relative '../lib/macroape/counting'

describe Bioinform::PWM do
  let :matrix_first do [[1,2,3,4],[10,20,30,40],[100,200,300,400]] end
  let :matrix_second do [[1,2,3,4],[2,3,4,5]] end
  let :pwm_first do Bioinform::PWM.new(matrix_first) end
  let :pwm_second do Bioinform::PWM.new(matrix_second) end

  context '#count_distribution_after_threshold' do

    it 'should return hash of score => count for all scores >= threshold' do
      distribution_first = pwm_first.count_distribution_after_threshold(0)
      distribution_first.keys.should == Array.product(*matrix_first).map{|score_row| score_row.inject(&:+)}
      distribution_first.values.uniq.should == [1]

      distribution_second = pwm_second.count_distribution_after_threshold(0)
      distribution_second.should == { 3=>1, 4=>2, 5=>3, 6=>4, 7=>3, 8=>2, 9=>1 }

      distribution_second = pwm_second.count_distribution_after_threshold(5)
      distribution_second.should == { 5=>3, 6=>4, 7=>3, 8=>2, 9=>1 }
    end

    it 'should use existing precalculated hash @count_distribution if it exists' do
      pwm = pwm_second;
      pwm.instance_variable_set :@count_distribution, { 3=>10, 4=>20, 5=>30, 6=>40, 7=>30, 8=>20, 9=>10 }

      distribution_second = pwm.count_distribution_after_threshold(0)
      distribution_second.should == { 3=>10, 4=>20, 5=>30, 6=>40, 7=>30, 8=>20, 9=>10 }

      distribution_second = pwm.count_distribution_after_threshold(5)
      distribution_second.should == { 5=>30, 6=>40, 7=>30, 8=>20, 9=>10 }
    end
  end

  context '#count_distribution' do
    it 'should return hash of score => count for all available scores' do
      pwm_second.count_distribution.should == { 3=>1, 4=>2, 5=>3, 6=>4, 7=>3, 8=>2, 9=>1 }
    end

    it 'should cache calculation in @count_distribution' do
      pwm = pwm_second;
      pwm.instance_variable_set :@count_distribution, { 3=>10, 4=>20, 5=>30, 6=>40, 7=>30, 8=>20, 9=>10 }
      pwm.count_distribution.should == { 3=>10, 4=>20, 5=>30, 6=>40, 7=>30, 8=>20, 9=>10 }

      pwm.instance_variable_set :@count_distribution, nil
      pwm.count_distribution.should == { 3=>1, 4=>2, 5=>3, 6=>4, 7=>3, 8=>2, 9=>1 }
    end
  end

end