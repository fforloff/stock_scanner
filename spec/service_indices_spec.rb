require_relative './rails_helper'
require_relative '../lib/tools/indices'
require 'pp'

describe ServiceIndices do
  it 'new should retrn indices' do
    expect(ServiceIndices.load).to eq(true)
    #expect(res = @si).not_to eq(nil)
    #pp res
  end
end
