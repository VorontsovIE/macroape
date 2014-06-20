require_relative 'spec_helper'
require 'macroape/support/partial_sums'

describe 'Array#partial_sums' do
  context 'when no initial value given' do
    it 'should return an array of the same size with partial sums of elements 0..ind inclusive with float elements' do
      [2,3,4,5].partial_sums.should == [2, 5, 9, 14]
      [2,3,4,5].partial_sums.last.should be_kind_of(Float)
    end
  end
  it 'should start counting from argument when it\'s given. Type of values depends on type of initial value' do
    [2,3,4,5].partial_sums(100).should == [102,105,109,114]
    [2,3,4,5].partial_sums(100).last.should be_kind_of(Integer)
  end
end

{1 => 5, 4 => 3, 3 => 2}.partial_sums == {1=>5, 3=>7, 4=>10}

describe 'Hash#partial_sums' do
  context 'when no initial value given' do
    it 'should return a hash with float values of the same size with partial sums of elements that has keys <= than argument' do
      {1 => 5, 4 => 3, 3 => 2}.partial_sums.should == {1=>5, 3=>7, 4=>10}
      {1 => 5, 4 => 3, 3 => 2}.partial_sums.values.last.should be_kind_of(Float)
    end
  end
  it 'should start counting from argument when it\'s given. Type of values depends on type of initial value' do
    {1 => 5, 4 => 3, 3 => 2}.partial_sums(100).should == {1=>105, 3=>107, 4=>110}
    {1 => 5, 4 => 3, 3 => 2}.partial_sums(100).values.last.should be_kind_of(Integer)
  end
end
