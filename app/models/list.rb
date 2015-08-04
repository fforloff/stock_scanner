class List
  include Mongoid::Document
  field :name, type: String

  has_and_belongs_to_many :companies, inverse_of: nil
end
