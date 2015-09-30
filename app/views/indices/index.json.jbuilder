json.array!(@indices) do |index|
  json.extract! index, :id, :ticker, :name, :exchange, :roar, :_id
  json.url index_url(index, format: :json)
end
