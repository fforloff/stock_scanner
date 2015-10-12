require 'rails_helper'

RSpec.describe "indices/edit", type: :view do
  before(:each) do
    @index = assign(:index, Index.create!())
  end

  it "renders the edit index form" do
    render

    assert_select "form[action=?][method=?]", index_path(@index), "post" do
    end
  end
end
