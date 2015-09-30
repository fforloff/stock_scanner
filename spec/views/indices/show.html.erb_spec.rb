require 'rails_helper'

RSpec.describe "indices/show", type: :view do
  before(:each) do
    @index = assign(:index, Index.create!(
      :ticker => "Ticker",
      :name => "Name",
      :exchange => "Exchange",
      :roar => 1.5,
      :_id => "Id"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Ticker/)
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Exchange/)
    expect(rendered).to match(/1.5/)
    expect(rendered).to match(/Id/)
  end
end
