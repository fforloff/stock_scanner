require 'rails_helper'

RSpec.describe "indices/show", type: :view do
  before(:each) do
    @index = assign(:index, Index.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
