#json.array!(@prices) do |price|
#  #json.extract! price, :date, :open, :high, :low, :close, :volume
#end

json.array! @c_ids do |t|
  json.ticker t
  json.prices @prices do |p|
    if p.company_id == t then
      json.extract! p, :date, :open, :high, :low, :close, :volume
#      json.date p.date
#      json.open p.open
#      json.high p.high
#      json.low p.low
#      json.close p.close
#      json.volume p.volume
    end
  end
end
