require 'rails_helper'

RSpec.describe "indices/edit", type: :view do
  before(:each) do
    @index = assign(:index, Index.create!(
      :ticker => "MyString",
      :name => "MyString",
      :exchange => "MyString",
      :roar => 1.5,
      :_id => "MyString"
    ))
  end

  it "renders the edit index form" do
    render

    assert_select "form[action=?][method=?]", index_path(@index), "post" do

      assert_select "input#index_ticker[name=?]", "index[ticker]"

      assert_select "input#index_name[name=?]", "index[name]"

      assert_select "input#index_exchange[name=?]", "index[exchange]"

      assert_select "input#index_roar[name=?]", "index[roar]"

      assert_select "input#index__id[name=?]", "index[_id]"
    end
  end
end
