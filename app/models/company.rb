class Company
    include Mongoid::Document
    field :ticker, type: String
    field :name, type: String
    field :industry, type: String
    field :active, type: Boolean
    field :ignore, type: Boolean, default: false
    field :roar, type: Float
    field :_id, type: String, default: ->{ticker}
    
    index({ticker: 1}, { unique: true })

    default_scope  ->{ where(ignore: false) }

    belongs_to :exchange
    has_many :prices
end
