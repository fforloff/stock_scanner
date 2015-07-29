#json.array!(@prices) do |price|
#  #json.extract! price, :date, :open, :high, :low, :close, :volume
#end

h = {} 

@prices.each do |p|
  h[p.company_id] = [] unless h.has_key?(p.company_id)
  h[p.company_id] = h[p.company_id].push(p)
end

json.array! @c_ids do |t|
  json.ticker t
  json.prices h[t] do |p|
    json.extract! p, :date, :open, :high, :low, :close, :volume
  end
end
#json.array! @c_ids do |t|
#  json.ticker t
#  json.prices @prices do |p|
#    if p.company_id == t then
#      json.extract! p, :date, :open, :high, :low, :close, :volume
#    end
#  end
#end
