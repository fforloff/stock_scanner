json.array!(@entities) do |entity|
  json.extract! entity, :id, :ticker, :name, :roar
  json.url entity_url(entity, format: :json)
end
