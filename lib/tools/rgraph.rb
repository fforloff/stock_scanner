class Rgraphs
    def initialize
        @myr = RinRuby.new
        @myr.echo
#        @myr = RinRuby.new(echo = false)
#        @myr.echo(enable=false, stderr=false)
        #@myr.eval "library('quantmod')"
        @myr.eval "suppressPackageStartupMessages(library('quantmod', quietly=TRUE, verbose=FALSE))"
        @myr.eval "source('#{File.expand_path('lib/tools/functions.R')}')"
        @myr.eval "library('jsonlite')"
        @myr.eval "library('curl')"
#        @myr.eval "library('XML')"
        @myr.eval "library('rmongodb')"
        
    end
    def get_json(env,url,companies)
        @c_vector = companies.map {|c| "'#{c}'"}.join(',')
        @myr.eval "#{env} <- new.env()"
        @myr.eval "getSymbolsJSON(c(#{@c_vector}), url='#{url}',  env=#{env})"
    end
    def get_csv(env,url,companies)
        @companies = companies
        @c_vector = companies.map {|c| "'#{c}'"}.join(',')
        @myr.eval "#{env} <- new.env()"
        @myr.eval "getSymbolsCSV(c(#{@c_vector}), url='#{url}',  env=#{env})"
    end
    def get_xml(env,url,companies)
        @companies = companies
        @c_vector = companies.map {|c| "'#{c}'"}.join(',')
        @myr.eval "#{env} <- new.env()"
        @myr.eval "getSymbolsXML(c(#{@c_vector}), url='#{url}',  env=#{env})"
    end
    def draw_mma_roar(env,path)
        @result_hash = Hash.new
        @myr.eval <<EOF
        tickers <- character()
        roars <- numeric()
        left <- 0
        for (t in ls(#{env})) {
            weekly <- to.weekly(#{env}[[t]])
            if(NROW(weekly)<50){
                do.call("rm", list(t), envir=#{env})
                next
            }

            roar <- ROAR(Cl(weekly))
            png(paste('#{path}','/',t,'_mma.png', sep=''), width=400, height=300)
            chartSeries(last(weekly, "24 months"),
                type = c("line"),
                name = "",
                subset = "last 12 months",
                theme = chartTheme("white", up.col = "green"), TA = NULL)
            plot(addGMMA(weekly))
            roar = ROAR(Cl(weekly))
            plot(addTA(roar, col = 'brown'))
            dev.off()
            tickers <- c(tickers, t)
            roars <- c(roars, last(roar))
        }
        left <- length(tickers)
EOF
        @left = 0
        @left = @myr.pull("left")
        puts "left is #{@left}"
        if (@left > 0) then 
          @tickers = @myr.pull("tickers", singleton=true)
          @tickers = [@tickers] if @tickers.is_a?(String)
          @roars = @myr.pull("roars", singleton=true)
          @tickers.each_with_index do |t, i|
            @result_hash.merge!(t => @roars[i]) unless @roars[i].nan?
          end
        end
        @result_hash
    end
    def draw_charts_par(companies,url,path,chunk)
      @myr.eval "library('doParallel')"
      @myr.eval "library('foreach')"
      @myr.eval "registerDoParallel(cores=2)"
      @result_hash = Hash.new
      @c_vector = companies.map {|c| "'#{c}'"}.join(',')
      @myr.eval <<EOF
      chunked <- splitVector(c(#{@c_vector}), chunk=#{chunk})
      res <- foreach (cc=chunked, .combine=rbind, .packages=c('quantmod','jsonlite','curl','xts','zoo'), .errorhandling='remove') %dopar% {
        drawChartsParallelMulti(cc,  path='#{path}', url = '#{url}')
        }
      res <- na.omit(res) 
      tickers <- as.vector(res[,1])
      roars <- as.vector(res[,2])
EOF
      @tickers = @myr.pull("tickers", singleton=true)
      @tickers = [@tickers] if @tickers.is_a?(String)
      @roars = @myr.pull("roars", singleton=true)
      @tickers.each_with_index do |t, i|
          @result_hash.merge!(t => @roars[i]) unless @roars[i].nan?
      end
      @result_hash
    end

    def draw_range_volume(env,path)
        @myr.eval <<EOF
        for (t in ls(#{env})) {
            png(paste('#{path}','/',t,'_range.png', sep=''), width=400, height=300)
            weekly <- to.weekly(#{env}[[t]])
            chartSeries(last(weekly, "24 months"),
                type = c("candlesticks"),
                name = "",
                subset = "last 12 months",
                theme = chartTheme("white", up.col = "green", dn.col = "red"), TA = 'addVo()')
            rr <- Range(weekly)
            plot(addTA(rr, on=1, col=c('blue','brown','black')))
            dev.off()
        }
EOF
    end
    def draw_fast_slow_ma(env,slow,fast,path)
        @myr.eval <<EOF
        for (t in ls(#{env})) {
            tt <- sub('\\\\^','',t)
            png(paste('#{path}','/',tt,'_ma.png', sep=''), width=400, height=300)
            weekly <- to.weekly(#{env}[[t]])
            chartSeries(last(weekly, "24 months"),
                type = c("line"),
                name = "",
                subset = "last 12 months",
                theme = chartTheme("white", up.col = "green"), TA = NULL)
            addEMA(c(#{slow},#{fast}), col=c('blue','red'))
        }
EOF
    end
end
