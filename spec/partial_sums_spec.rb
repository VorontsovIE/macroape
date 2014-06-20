require_relative 'spec_helper'
require 'macroape/support/partial_sums'

describe 'Array#partial_sums' do
  context 'when no initial value given' do
    it 'should return an array of the same size with partial sums of elements 0..ind inclusive with float elements' do
      expect([2,3,4,5].partial_sums).to eq [2, 5, 9, 14]
      expect([2,3,4,5].partial_sums.last).to be_kind_of(Float)
    end
  end
  it 'should start counting from argument when it\'s given. Type of values depends on type of initial value' do
    expect([2,3,4,5].partial_sums(100)).to eq [102,105,109,114]
    expect([2,3,4,5].partial_sums(100).last).to be_kind_of(Integer)
  end
end

describe 'Hash#partial_sums' do
  context 'when no initial value given' do
    it 'should return a hash with float values of the same size with partial sums of elements that has keys <= than argument' do
      expect({1 => 5, 4 => 3, 3 => 2}.partial_sums).to eq({1=>5, 3=>7, 4=>10})
      expect({1 => 5, 4 => 3, 3 => 2}.partial_sums.values.last).to be_kind_of(Float)
    end
  end
  it 'should start counting from argument when it\'s given. Type of values depends on type of initial value' do
    expect({1 => 5, 4 => 3, 3 => 2}.partial_sums(100)).to eq({1=>105, 3=>107, 4=>110})
    expect({1 => 5, 4 => 3, 3 => 2}.partial_sums(100).values.last).to be_kind_of(Integer)
  end
end
