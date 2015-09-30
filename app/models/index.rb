class Index
  include Mongoid::Document
  field :ticker, type: String
  field :name, type: String
  field :exchange, type: String
  field :roar, type: Float
  field :_id, type: String , default: ->{ticker}

  index({ticker: 1}, { unique: true })

  has_many :prices
end
