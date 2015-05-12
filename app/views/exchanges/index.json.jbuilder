json.array!(@exchanges) do |exchange|
  json.extract! exchange, :id, :name, :description, :suffix
  json.url exchange_url(exchange, format: :json)
end
