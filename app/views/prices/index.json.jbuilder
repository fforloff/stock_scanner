json.array!(@prices) do |price|
  json.extract! price, :id, :date, :open, :high, :low, :close, :volume
  json.url price_url(price, format: :json)
end
