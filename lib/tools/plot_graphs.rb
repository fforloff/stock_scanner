def plot_graphs(url,images_dir,mma_months,per_batch)
    require "rinruby"
    require "rgraph"
    require 'progress_bar'
    require 'benchmark'
#    company_count = Company.any_of(ticker: /^A/).count
    company_count = Company.count
    env = 'data'
    bar = ProgressBar.new(company_count)
    #per_batch = 5
    roars_hash = Hash.new
    myr = Rgraphs.new
    updates = Array.new
    0.step(company_count, per_batch) do |offset|
#    Benchmark.bm(8) do |bmark|
        cc_array = Array.new
#    bmark.report("c_list") {
        Company.asc(:ticker).limit(per_batch).skip(offset).each do |c|
#        Company.any_of(ticker: /^A/).limit(per_batch).skip(offset).each do |c|
            cc_array.push("#{c.ticker}")
        end
#    }
#    bmark.report("draw_charts") {
        roars_hash = myr.draw_charts_par(cc_array,url,"#{images_dir}")
#    }

#    bmark.report("json") {
#        myr.get_json(env,url,cc_array)
#    }
#    bmark.report("csv") {
#        myr.get_csv(env,url,cc_array)
#    }
#    bmark.report("xml") {
#        myr.get_xml(env,url,cc_array)
#    }
#    bmark.report("roar") {
#        roars_hash = myr.draw_mma_roar(env,"#{images_dir}")
#    }
#    bmark.report("range") {
#        myr.draw_range_volume(env,"#{images_dir}")
#    }
#    bmark.report("r_update") {
##        unless roars_hash.nil? then 
##          roars_hash.each do |t,roar|
##              company = Company.where(ticker: t).first
##              company.roar = ((roar)*100).to_i.to_f/100 unless roar.nan?
##              company.save
##          end
##        end
#    }
# preparing for bulk upsert
        unless roars_hash.nil? then 
          roars_hash.each do |t,roar|
            updates.push({'q' => {'ticker' => t}, 'u' => {'$set' => {'roar' => roar.to_i}}})
          end
        end
                
        for cc in cc_array do
            bar.increment!
        end
#    end # Benchmark 
    end
    # execute bulk upsert
    session = Mongoid.default_session
    session.command({update: Company.collection_name.to_s, updates: updates, ordered: false})

end
