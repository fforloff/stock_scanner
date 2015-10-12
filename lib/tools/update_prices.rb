module Update_prices

  require 'csv'
  require 'progress_bar'
  @entity_count = Entity.count
  @bar = ProgressBar.new(@entity_count)

  class Dat <
      Struct.new(:entity, :body)
  end

  def Update_prices.finance_yahoo_url(ticker, start_date, end_date)
      url = "http://ichart.finance.yahoo.com"
      url << "/table.csv?s=#{ticker}&g=d"
      url << "&a=#{start_date.month - 1}"
      url << "&b=#{start_date.mday}"
      url << "&c=#{start_date.year}"
      url << "&d=#{end_date.month - 1}"
      url << "&e=#{end_date.mday}"
      url << "&f=#{end_date.year.to_s}"
      url.gsub('^','%5E')
  end

  def Update_prices.get_prices(max_days)
      per_batch = 20
      0.step(@entity_count, per_batch) do |offset|
          response = Array.new
          prices_array = Array.new
          hydra = Typhoeus::Hydra.new(:max_concurrency => 20)
          Entity.asc(:ticker).limit(per_batch).skip(offset).each do |e|
              ticker = e.ticker
              @bar.increment!
              end_date = Date.today
              prices = e.prices.asc(:date)
              if prices.empty?
                  start_date = end_date - max_days
              else
                  last_record = prices.last
                  start_date = last_record.date + 1
              end
              next if start_date > end_date
              url = Update_prices.finance_yahoo_url(ticker,start_date,end_date)
              request = Typhoeus::Request.new(url, :method => :get)
              request.on_complete do |resp|
                  next if resp.code != 200
                  next if resp.body[0..40] != "Date,Open,High,Low,Close,Volume,Adj Close"
                  dat = Dat.new
                  dat.entity = e
                  dat.body = resp.body
                  response.push(dat)
              end
              hydra.queue(request)
          end
          hydra.run
          response.each do |dat|
              prices_array.concat Update_prices.update_entity(dat)
          end
          Price.collection.insert_many(prices_array.map(&:as_document)) unless prices_array.size == 0
          response = []
          prices_array = []
      end
      Price.create_indexes
  end

  def Update_prices.update_entity(dat)
          entity = dat.entity
          res_array = Array.new 
          CSV.new(dat.body, :headers => true).reverse_each do |line|
              date = line[0]
              open = (line[1].to_f * 1000).to_i
              high = (line[2].to_f * 1000).to_i
              low = (line[3].to_f * 1000).to_i
              close = (line[4].to_f * 1000).to_i
              volume = line[5].to_i
              day = entity.prices.new({
                  :date => date,
                  :open => open,
                  :high => high,
                  :low => low,
                  :close => close,
                  :volume => volume
              })
              res_array.push(day)
              day = {}
          end
           return res_array
  end
end
