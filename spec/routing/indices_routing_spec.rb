require "rails_helper"

RSpec.describe IndicesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/indices").to route_to("indices#index")
    end

    it "routes to #new" do
      expect(:get => "/indices/new").to route_to("indices#new")
    end

    it "routes to #show" do
      expect(:get => "/indices/1").to route_to("indices#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/indices/1/edit").to route_to("indices#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/indices").to route_to("indices#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/indices/1").to route_to("indices#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/indices/1").to route_to("indices#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/indices/1").to route_to("indices#destroy", :id => "1")
    end

  end
end
