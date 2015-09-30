require 'rails_helper'

RSpec.describe "indices/new", type: :view do
  before(:each) do
    assign(:index, Index.new(
      :ticker => "MyString",
      :name => "MyString",
      :exchange => "MyString",
      :roar => 1.5,
      :_id => "MyString"
    ))
  end

  it "renders new index form" do
    render

    assert_select "form[action=?][method=?]", indices_path, "post" do

      assert_select "input#index_ticker[name=?]", "index[ticker]"

      assert_select "input#index_name[name=?]", "index[name]"

      assert_select "input#index_exchange[name=?]", "index[exchange]"

      assert_select "input#index_roar[name=?]", "index[roar]"

      assert_select "input#index__id[name=?]", "index[_id]"
    end
  end
end
