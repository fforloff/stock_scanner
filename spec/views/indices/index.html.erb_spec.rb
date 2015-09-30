require 'rails_helper'

RSpec.describe "indices/index", type: :view do
  before(:each) do
    assign(:indices, [
      Index.create!(
        :ticker => "Ticker",
        :name => "Name",
        :exchange => "Exchange",
        :roar => 1.5,
        :_id => "Id"
      ),
      Index.create!(
        :ticker => "Ticker",
        :name => "Name",
        :exchange => "Exchange",
        :roar => 1.5,
        :_id => "Id"
      )
    ])
  end

  it "renders a list of indices" do
    render
    assert_select "tr>td", :text => "Ticker".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Exchange".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "Id".to_s, :count => 2
  end
end
