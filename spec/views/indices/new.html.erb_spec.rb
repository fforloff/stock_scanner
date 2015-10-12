require 'rails_helper'

RSpec.describe "indices/new", type: :view do
  before(:each) do
    assign(:index, Index.new())
  end

  it "renders new index form" do
    render

    assert_select "form[action=?][method=?]", indices_path, "post" do
    end
  end
end
