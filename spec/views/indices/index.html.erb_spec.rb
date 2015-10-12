require 'rails_helper'

RSpec.describe "indices/index", type: :view do
  before(:each) do
    assign(:indices, [
      Index.create!(),
      Index.create!()
    ])
  end

  it "renders a list of indices" do
    render
  end
end
