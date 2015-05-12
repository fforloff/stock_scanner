class Exchange
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :suffix, type: String

  has_many :companies    
end
