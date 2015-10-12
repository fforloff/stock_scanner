class Price
  include Mongoid::Document
  field :date, type: Date
  field :open, type: Integer
  field :high, type: Integer
  field :low, type: Integer
  field :close, type: Integer
  field :volume, type: Integer

  index({date: 1, entity_id: 1})
  belongs_to :entity

  def self.to_to_csv(options = {})
    CSV.generate(options) do |csv|
      columns = Price.fields.keys
      csv << columns
      all.each do |price|
        csv << price.attributes.values_at(*columns)
      end
    end
  end
end
