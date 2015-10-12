require 'rails_helper'

RSpec.describe "entities/edit", type: :view do
  before(:each) do
    @entity = assign(:entity, Entity.create!(
      :ticker => "MyString",
      :name => "MyString",
      :roar => 1.5
    ))
  end

  it "renders the edit entity form" do
    render

    assert_select "form[action=?][method=?]", entity_path(@entity), "post" do

      assert_select "input#entity_ticker[name=?]", "entity[ticker]"

      assert_select "input#entity_name[name=?]", "entity[name]"

      assert_select "input#entity_roar[name=?]", "entity[roar]"
    end
  end
end
