require 'rails_helper'

RSpec.describe "entities/index", type: :view do
  before(:each) do
    assign(:entities, [
      Entity.create!(
        :ticker => "Ticker",
        :name => "Name",
        :roar => 1.5
      ),
      Entity.create!(
        :ticker => "Ticker",
        :name => "Name",
        :roar => 1.5
      )
    ])
  end

  it "renders a list of entities" do
    render
    assert_select "tr>td", :text => "Ticker".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
  end
end
