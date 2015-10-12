require 'rails_helper'

RSpec.describe "entities/new", type: :view do
  before(:each) do
    assign(:entity, Entity.new(
      :ticker => "MyString",
      :name => "MyString",
      :roar => 1.5
    ))
  end

  it "renders new entity form" do
    render

    assert_select "form[action=?][method=?]", entities_path, "post" do

      assert_select "input#entity_ticker[name=?]", "entity[ticker]"

      assert_select "input#entity_name[name=?]", "entity[name]"

      assert_select "input#entity_roar[name=?]", "entity[roar]"
    end
  end
end
