class Entity
  include Mongoid::Document
  field :ticker, type: String
  field :name, type: String
  field :roar, type: Float
  field :ignore, type: Boolean, default: false
  field :_id, type: String, default: ->{ticker}
  index({ticker: 1}, { unique: true })
 
  belongs_to :exchange
  has_many :prices 

  default_scope  ->{ where(ignore: false) }

end
