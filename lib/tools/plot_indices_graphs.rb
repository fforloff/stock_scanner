def plot_indices_graphs(mma_months,url)
    images_dir = 'app/assets/images'
    require "rinruby"
    require "rgraph"
    require 'progress_bar'
    index_count = Index.count
    env = 'data'
    #url = 'http://172.31.177.2/indices'
    bar = ProgressBar.new(index_count)
    per_batch = 5
    myr = Rgraphs.new
    0.step(index_count, per_batch) do |offset|
        cc_array = Array.new
        Index.asc(:ticker).limit(per_batch).skip(offset).each do |c|
            cc_array.push("#{c.ticker}")
        end
        myr.get_csv(env,url,cc_array)
        myr.draw_fast_slow_ma(env,10,30,"#{images_dir}")
        for cc in cc_array do
            bar.increment!
        end
    end
end
