require 'spec_helper'
require 'bioinform'
require 'macroape/threshold_by_pvalue'

describe Bioinform::PWM do
  context '#count_distribution_after_threshold' do
    let :matrix do [[1,2,3,4],[10,20,30,40],[100,200,300,400]] end
    let :pwm do Bioinform::PWM.new(matrix) end
    it 'should return hash of score => count for all scores >= threshold' do
      distribution = pwm.count_distribution_after_threshold(0)
      distribution.keys.should == Array.product(*matrix).map{|score_row| score_row.inject(&:+)}
      distribution.values.uniq.should == [1]
    end
    #it 'should create a hash from yielded [k,v] pairs if block not given' do
    #  %w{A C G T}.each_with_index.collect_hash.should == {"A" => 0, "C" => 1, "G" => 2, "T" => 3}
    #end
  end
end