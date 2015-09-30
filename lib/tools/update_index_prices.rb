module Update_index_prices

  require 'csv'
  require 'progress_bar'
  @indices_count = Index.count
  @bar = ProgressBar.new(@indices_count)

  class Dat <
      Struct.new(:index, :last_record, :body)
  end

  def Update_index_prices.finance_yahoo_url(ticker, start_date, end_date)
      #ticker = "#{ticker}.#{suffix}" unless suffix.empty?
      #url = "http://chart.yahoo.com"
      url = "http://ichart.finance.yahoo.com"
      #url = "http://itable.finance.yahoo.com"
      url << "/table.csv?s=#{ticker}&g=d"
      url << "&a=#{start_date.month - 1}"
      url << "&b=#{start_date.mday}"
      url << "&c=#{start_date.year}"
      url << "&d=#{end_date.month - 1}"
      url << "&e=#{end_date.mday}"
      url << "&f=#{end_date.year.to_s}"
     url.gsub('^','%5E')
  end

  def Update_index_prices.get_prices(max_days)
  #    Typhoeus::Config.verbose = true
      per_batch = 20
      0.step(@indices_count, per_batch) do |offset| #vo
          response = Array.new
          prices_array = Array.new
          hydra = Typhoeus::Hydra.new(:max_concurrency => 20)
  #        [Company.unscoped.where(ticker: "MFG.AX").first].each do |company| #vo
          Index.asc(:ticker).limit(per_batch).skip(offset).each do |index| #vo
              p ticker = index.ticker
              @bar.increment!
              #suffix = company.suffix
              end_date = Date.today
              prices = index.prices.asc(:date)
              if prices.empty?
                  start_date = end_date - max_days
              else
                  last_record = prices.last
                  start_date = last_record.date + 1
              end
              #p start_date
              next if start_date > end_date
              url = Update_index_prices.finance_yahoo_url("^#{ticker}",start_date,end_date)
              request = Typhoeus::Request.new(url, :method => :get)
              request.on_complete do |resp|
                  next if resp.code != 200
                  next if resp.body[0..40] != "Date,Open,High,Low,Close,Volume,Adj Close"
                  dat = Dat.new
                  dat.index = index
                  dat.last_record = last_record
                  dat.body = resp.body
                  response.push(dat)
              end
              hydra.queue(request)
          end
          hydra.run
          response.each do |dat|
              prices_array.concat Update_index_prices.update_indices(dat)
          end
          p 'booooo'
         p  Price.collection.methods
         p 'after booooo'
          Price.collection.insert_many(prices_array.map(&:as_document)) unless prices_array.size == 0
          response = []
          prices_array = []
      end #vo
      Price.create_indexes
  end

  def Update_index_prices.update_indices(dat)
          index = dat.index
          last_record = dat.last_record
          res_array = Array.new #vo
  #        p company.ticker
          CSV.new(dat.body, :headers => true).reverse_each do |line|
              date = line[0]
              open = (line[1].to_f * 1000).to_i
              high = (line[2].to_f * 1000).to_i
              low = (line[3].to_f * 1000).to_i
              close = (line[4].to_f * 1000).to_i
              day = index.prices.new({
                  :date => date,
                  :open => open,
                  :high => high,
                  :low => low,
                  :close => close
              })
              line[5].to_i == 0 ? next : day.volume = line[5].to_i
              res_array.push(day)
              day = {}
          end
  #        company.prices << prices_array #vo
  #        p '-----------------'
#           p res_array
           return res_array
  end
end
