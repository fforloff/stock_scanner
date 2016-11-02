def plot_graphs(url,images_dir,mma_months,per_batch,chunk)
    require "rinruby"
    require "rgraph"
    require 'progress_bar'
#    require 'benchmark'
#    company_count = Company.any_of(ticker: /^A/).count
    company_count = Entity.count
    env = 'data'
    bar = ProgressBar.new(company_count)
    roars_hash = Hash.new
    myr = Rgraphs.new
    updates = Array.new
    0.step(company_count, per_batch) do |offset|
        cc_array = Array.new
##        Entity.asc(:ticker).limit(per_batch).skip(offset).each do |c|
        Entity.any_of(ticker: /^C/).limit(per_batch).skip(offset).each do |c|
#        Company.any_of(ticker: /^A/).limit(per_batch).skip(offset).each do |c|
            cc_array.push("#{c.ticker}")
        end
        roars_hash = myr.draw_charts_par(cc_array,url,"#{images_dir}",chunk)

# preparing for bulk upsert
        unless roars_hash.nil? then
          roars_hash.each do |t,roar|
            updates.push({'q' => {'ticker' => t}, 'u' => {'$set' => {'roar' => roar.to_i}}})
          end
        end

        for cc in cc_array do
            bar.increment!
        end
    end
    # execute bulk upsert
    session = Mongoid.default_session
    session.command({update: Entity.collection_name.to_s, updates: updates, ordered: false})

end
