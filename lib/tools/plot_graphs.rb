def plot_graphs(url,images_dir,mma_months)
    require "rinruby"
    require "rgraph"
    require 'progress_bar'
    company_count = Company.count
    env = 'data'
    bar = ProgressBar.new(company_count)
    per_batch = 5
    myr = Rgraphs.new
    0.step(company_count, per_batch) do |offset|
        cc_array = Array.new
        Company.asc(:ticker).limit(per_batch).skip(offset).each do |c|
            cc_array.push("#{c.ticker}")
        end
        myr.get_json(env,url,cc_array)
        roars_hash = myr.draw_mma_roar(env,"#{images_dir}")
        myr.draw_range_volume(env,"#{images_dir}")
        roars_hash.each do |t,roar|
            company = Company.where(ticker: t).first
            company.roar = ((roar)*100).to_i.to_f/100 unless roar.nan?
            company.save
        end
        for cc in cc_array do
            bar.increment!
        end
    end
end
