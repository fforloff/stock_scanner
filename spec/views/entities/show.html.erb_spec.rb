require 'rails_helper'

RSpec.describe "entities/show", type: :view do
  before(:each) do
    @entity = assign(:entity, Entity.create!(
      :ticker => "Ticker",
      :name => "Name",
      :roar => 1.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Ticker/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1.5/)
  end
end
