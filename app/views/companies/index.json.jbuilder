json.array!(@companies) do |company|
  json.extract! company, :id, :ticker, :name, :industry, :active, :ignore, :roar, :_id
  json.url company_url(company, format: :json)
end
