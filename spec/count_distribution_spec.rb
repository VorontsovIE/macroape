require_relative 'spec_helper'
require_relative '../lib/macroape/counting'

describe Bioinform::PWM do
  let :matrix_first do [[1,2,3,4],[10,20,30,40],[100,200,300,400]] end
  let :matrix_second do [[1,2,3,4],[2,3,4,5]] end
  let :pwm_first do Bioinform::PWM.new(matrix_first) end
  let :pwm_second do Bioinform::PWM.new(matrix_second) end
  let :background do [0.1,0.4,0.4,0.1] end
  let :pwm_first_on_background do pwm_first.tap{|pwm| pwm.tap{|x| x.background = background }} end
  let :pwm_second_on_background do pwm_second.tap{|pwm| pwm.tap{|x| x.background = background }}  end

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

    it 'for PWMs on different background it should contain the same scores (keys of hash)' do
      pwm_first.count_distribution_after_threshold(0).keys.sort.should == pwm_first_on_background.count_distribution_after_threshold(0).keys.sort
      pwm_first.count_distribution_after_threshold(13).keys.sort.should == pwm_first_on_background.count_distribution_after_threshold(13).keys.sort
    end

    it 'should return hash of score => count for all scores >= threshold  when calculated on background' do
      distribution_second = pwm_second_on_background.count_distribution_after_threshold(0)
      distribution_second.should have_nearly_the_same_values({ 3=>0.01, 4=>0.08, 5=>0.24, 6=>0.34, 7=>0.24, 8=>0.08, 9=>0.01 }, 1e-7 )

      distribution_second = pwm_second_on_background.count_distribution_after_threshold(5)
      distribution_second.should have_nearly_the_same_values({ 5=>0.24, 6=>0.34, 7=>0.24, 8=>0.08, 9=>0.01 }, 1e-7 )
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

  context '#pvalue_by_threshold' do
    it 'should return probability to be >= than threshold' do
      pwm_second.pvalue_by_threshold(7).should be_within(1e-7).of(6.0/16)
    end
    it 'should return probability to be >= than threshold when calculated on background' do
      pwm_second_on_background.pvalue_by_threshold(7).should be_within(1e-7).of(0.33)
    end
  end
  context '#threshold' do
    it 'should return threshold such that according pvalue doesn\'t exceed requested value' do
      requested_pvalue = 6.0/16
      threshold = pwm_second.threshold(requested_pvalue)
      pwm_second.pvalue_by_threshold(threshold).should <= requested_pvalue
    end
    it 'should return threshold such that according pvalue doesn\'t exceed requested value when calculated on background' do
      requested_pvalue = 0.33
      threshold = pwm_second_on_background.threshold(requested_pvalue)
      pwm_second_on_background.pvalue_by_threshold(threshold).should <= requested_pvalue
    end
    it 'should return threshold such that according pvalue doesn\'t exceed requested value when actual pvalue isn\'t exact equal to requested' do
      requested_pvalue = 0.335
      threshold = pwm_second_on_background.threshold(requested_pvalue)
      pwm_second_on_background.pvalue_by_threshold(threshold).should <= requested_pvalue
    end
  end
  context '#weak_threshold' do
  it 'should return threshold such that according pvalue exceed requested value' do
      requested_pvalue = 6.0/16
      threshold = pwm_second.weak_threshold(requested_pvalue)
      pwm_second.pvalue_by_threshold(threshold).should >= requested_pvalue
    end
    it 'should return threshold such that according pvalue exceed requested value when calculated on background' do
      requested_pvalue = 0.33
      threshold = pwm_second_on_background.weak_threshold(requested_pvalue)
      pwm_second_on_background.pvalue_by_threshold(threshold).should >= requested_pvalue
    end
    it 'should return threshold such that according pvalue exceed requested value when actual pvalue isn\'t exact equal to requested' do
      requested_pvalue = 0.335
      threshold = pwm_second_on_background.weak_threshold(requested_pvalue)
      pwm_second_on_background.pvalue_by_threshold(threshold).should >= requested_pvalue
    end
  end
end
