# functions

splitVector <- function(x, chunk) {
  i <- 1
  n <- 1
  res <- list()
  while (length(x) >= n) {
  tmp <- x[n:(n+chunk-1)]
  res[[i]] <- tmp[!is.na(tmp)]
  n <- n+chunk
  i <- i+1
  }
  return(res)
}

# get price data for a list of tickers over a json call.
getSymbolsJSON <-
  function(tickers, url = "http://localhost:3000/entities", env=.GlobalEnv) {
  n = length(tickers)
  i = 1
  while(i <= n) {
    try (sym <- fromJSON(paste(url,"/",tickers[i],"/prices.json", sep="")), silent=T)
#    try (json_data <- fromJSON(readLines(paste(url,"/",tickers[i],"/prices.json", sep=""))), silent=T)
#    sym <- do.call("rbind", lapply(json_data, data.frame))
    if(length(sym) != 0) {
      sym <- sym[c("date","open","high","low","close","volume")]
      sym$open = sym$open/1000 
      sym$close = sym$close/1000 
      sym$low = sym$low/1000 
      sym$high = sym$high/1000 
      if(NROW(sym) > 130) {
      assign(tickers[i], as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format="%Y-%m-%d", tz="UTC"))), envir=env)
      }
    }
    i = i+1
  }
}

getMultiSymbolsJSON <-
  function(x, url = "http://localhost:3000/prices?", env=.GlobalEnv) {
  tickers_params <- paste("entity_id[]=", x, "&", sep="", collapse="")
  dframe <- fromJSON(paste(url, tickers_params, "format=json", sep="" ), flatten = TRUE)
  for(i in 1:nrow(dframe)){
    if(length(dframe$prices[i]) != 0) {
      sym <- do.call("rbind", lapply(dframe$prices[i], data.frame))
      sym$open = sym$open/1000
      sym$close = sym$close/1000
      sym$low = sym$low/1000
      sym$high = sym$high/1000
      if(NROW(sym) > 130) {
        assign(dframe$ticker[i], as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format="%Y-%m-%d"))), envir=env)
      }
    }
  }
}

getOneSymbolJSON <-
  function(ticker, url = "http://localhost:3000/entities", env=.GlobalEnv) {
  try (sym <- fromJSON(paste(url,"/",ticker,"/prices.json", sep="")), silent=T)
  if(length(sym) != 0) {
    sym <- sym[c("date","open","high","low","close","volume")]
    sym$open = sym$open/1000
    sym$close = sym$close/1000
    sym$low = sym$low/1000
    sym$high = sym$high/1000
    xts <- as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format="%Y-%m-%d", tz="UTC")))
  }
  return(xts)
}


getSymbolsCSV <-
  function(tickers, url = "http://localhost:3000/entities", env=.GlobalEnv) {
  fmt <- "%Y-%m-%d %H:%M:%S UTC"
  n = length(tickers)
  i = 1
  while(i <= n) {
#    print(tickers[i])
    try ( sym <- read.csv(url(paste(url,"/",tickers[i],"/prices.csv", sep=""))), silent=T)
    if(length(sym) != 0) {
    #if(!is.null(sym)) {
      sym <- subset(sym, select = -c(X_id, company_id))
      #sym <- subset(sym, select = -c(X_type, X_id, company_id))
      sym$open = sym$open/1000
      sym$close = sym$close/1000
      sym$low = sym$low/1000
      sym$high = sym$high/1000
      assign(tickers[i], as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format=fmt))), envir=env)
    }
    i = i+1
  }
}

getSymbolsXML <-
  function(tickers, url = "http://localhost:3000/entities", env=.GlobalEnv) {
  fmt <- "%Y-%m-%d"
  n = length(tickers)
  i = 1
  while(i <= n) {
#    print(tickers[i])
    #try ( data <- xmlParse(url(paste(url,"/",tickers[i],"/prices.xml", sep=""))), silent=T)
    data <- xmlParse(paste(url,"/",tickers[i],"/prices.xml", sep=""))
    if(length(data) != 0) {
      sym <- xmlToDataFrame(data, 
        c("numeric","character","numeric","numeric","numeric","numeric"),
        stringsAsFactors=FALSE)
      #sym <- xmlToDataFrame(data, 
      #  stringsAsFactors=FALSE)
      sym <- sym[c("date","open","high","low","close","volume")]
      sym$open = sym$open/1000
      sym$close = sym$close/1000
      sym$low = sym$low/1000
      sym$high = sym$high/1000
      if(NROW(sym) > 130) {
        assign(tickers[i], 
          as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format=fmt, tz='UTC'))), envir=env)
      }
    }
    i = i+1
  }
}

getOneSymbolRmongodb <- function (host='localhost',database,collection,ticker) {
  m <- mongo.create(db=database)
  coll <- paste(database, ".", collection, sep="")
  query <- paste('{"company_id": "', ticker, '"}', sep="")
   prices <- mongo.find.all(m, coll, query)
   if(length(prices) != 0) {
    sym <- do.call("rbind", lapply(prices, data.frame))
    sym <- sym[c("date","open","high","low","close","volume")]
    sym$open = sym$open/1000
    sym$close = sym$close/1000
    sym$low = sym$low/1000
    sym$high = sym$high/1000
    fmt <- "%Y-%m-%d %H:%M:%S UTC"
    xts <- as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format=fmt)))
  }
  return(xts)
}

getSymbolsCont <-
  function(tickers, from=seq(Sys.Date(), length=2, by='-2 years')[2], to=Sys.Date(), src="yahoo", env=.GlobalEnv) {
    n = length(tickers)
    i = 1
    while(i <= n ) {
      #print(tickers[i])
      sym = NULL
      try ( sym <- getSymbols(tickers[i], from=from, to=to, src=src,
                              auto.assign=FALSE, ), silent=T)

      if(!is.null(sym)) {
        assign(tickers[i], sym, envir=env)
      }
      i = i+1
    }
}

# Hull Moving Average
HMA <- function(x, n=10){
  hma <- WMA(2*WMA(x, as.integer(n/2)) - WMA(x, n), as.integer(sqrt(n)))
  hma <- reclass(hma, x)
  if (!is.null(dim(hma))) {
    colnames(hma) <- paste(colnames(x), "HMA", n, sep = ".")
  }
  return(hma)
}
# add Hull Moving Average indicator to a chart
addHMA <- newTA(HMA, preFUN=Cl, on=1, legend.name="HMA", col = 'yellow')

# Rate of annual return
ROAR <- function(x, hma_n=26, lag=13){
  hma <- HMA(x, n=hma_n)
  lagged <- Lag(hma, k = lag)
  roar = ((52/lag)*100*(hma-lagged))/hma
  if (!is.null(dim(roar))) {
    colnames(roar) <- paste(colnames(x), "ROAR", hma_n, sep = ".")
  }
  return(roar)
}

# add ROAR indicator to a chart
addROAR <- newTA(ROAR, preFUN=Cl, legend.name="ROAR", col = 'brown')

# add Gupy Multiple Moving averages to a chart
addGMMA <- function(x, short=c(3,5,7,9,11,13), long=c(21,24,27,30,33,36), short_col='blue', long_col='red') {
  l <- length(Cl(x))
  short <- short[short<l]
  long <- long[long<l]
  cc_s <- rep(short_col, length(short))
  cc_l <- rep(long_col, length(long))
  addEMA(n = c(short, long), wilder = FALSE, ratio = NULL, col = c(cc_s, cc_l))
}

# Stop losses and take profit.
Range <- function (x, n_hma=8, n_atr_lower=4, n_atr_upper=8, up_steps=2, down_steps=3, sl_steps=5){
  central <- HMA(Cl(x), n_hma)
  atr_lower <- ATR(x, n_atr_lower, maType="WMA")
  atr_upper <- ATR(x, n_atr_upper, maType="WMA")
  upper <- central+up_steps*atr_upper$atr
  lower <- central-down_steps*atr_lower$atr
  sl <- central-sl_steps*atr_lower$atr
  central <-central[!is.na(central)]
  upper <- upper[!is.na(upper)]
  lower <- lower[!is.na(lower)]
  sl <- sl[!is.na(sl)]
  ll <- min(length(central), length(lower), length(upper), length(sl))
  central <- tail(central, ll)
  lower <- tail(lower, ll)
  upper <- tail(upper, ll)
  sl <- tail(sl, ll)
  for(i in 2:length(lower)){
    if(as.vector(lower[i]) < as.vector(lower[i-1])) 
           ifelse(as.vector(central[i]) >= as.vector(lower[i-1]),
                  lower[i] <- lower[i-1],
                  lower[i] <- central[i])
           
    if(as.vector(sl[i]) < as.vector(sl[i-1]))
           ifelse(as.vector(central[i]) >= as.vector(sl[i-1]),
                  sl[i] <- sl[i-1],
                  sl[i] <- central[i])
  }  
  names(sl) <- "Cond SL"
  names(lower) <- "SL"
  names(upper) <- "TP"
  range <- merge(upper,lower,sl)
  #range <- merge(lower,central,upper)
}

drawChartsParallel <- function(ticker, url = "http://localhost:3000/entities", path, min_weeks = 26,  env=.GlobalEnv) {
  roar = NA
  try(xts <- getOneSymbolJSON(ticker, url, env), silent=T)
  if(length(xts) != 0) {
    weekly <- to.weekly(xts)  
      if(NROW(weekly) > min_weeks) {
      roar <- ROAR(Cl(weekly))
      img_path <- paste(path,'/',ticker,'_mma.png', sep='')
      png(filename=paste(path,'/',ticker,'_mma.png', sep=''), width=400, height=300)
      #print(img_path)
      try(chartSeries(last(weekly, "24 months"),
        type = c("line"),
        name = "",
        subset = "last 12 months",
        theme = chartTheme("white", up.col = "green"), TA = NULL),silent=TRUE)
      plot(addGMMA(weekly))
      roar = ROAR(Cl(weekly))
      plot(addTA(roar, col = 'brown'))
      dev.off()
      png(filename=paste(path,'/',ticker,'_range.png', sep=''), width=400, height=300)
      chartSeries(last(weekly, "24 months"),
        type = c("candlesticks"),
        name = "",
        subset = "last 12 months",
        theme = chartTheme("white", up.col = "green", dn.col = "red"), TA = 'addVo()')
      #print(paste(path,'/',ticker,'_range', sep=''))
      rr <- Range(weekly)
      plot(addTA(rr, on=1, col=c('blue','brown','black')))
      dev.off()
    }
  }
  #return <- c(ticker,as.vector(last(roar)))
  return <- data.frame(tickers = ticker, roars = as.vector(last(roar)))
}

drawChartsParallelMulti <- function(tickers, path, url="http://localhost:3000/prices?",  env=.GlobalEnv) {
  tmpEnv <- new.env()
  tt <- character()
  roars <- numeric()
#  print(path)
#  print(tickers)
  getMultiSymbolsJSON(tickers, url, env=tmpEnv)
  for (t in ls(tmpEnv)) {
#    print(NROW(tmpEnv[[t]]))
    roar = NA
    if(NROW(tmpEnv[[t]]) != 0) {
      weekly <- to.weekly(tmpEnv[[t]])
#      if(NROW(weekly) > min_weeks) {
      roar <- ROAR(Cl(weekly))
      if(!is.na(last(roar))) {  
        png(filename=paste(path,'/',t,'_mma.png', sep=''), width=400, height=300)
        try(chartSeries(last(weekly, "24 months"),
                        type = c("line"),
                        name = "",
                        subset = "last 12 months",
                        theme = chartTheme("white", up.col = "green"), TA = NULL),silent=TRUE)
        plot(addGMMA(weekly))
        roar = ROAR(Cl(weekly))
        plot(addTA(roar, col = 'brown'))
        dev.off()
        png(filename=paste(path,'/',t,'_range.png', sep=''), width=400, height=300)
        chartSeries(last(weekly, "24 months"),
                    type = c("candlesticks"),
                    name = "",
                    subset = "last 12 months",
                    theme = chartTheme("white", up.col = "green", dn.col = "red"), TA = 'addVo()')

        rr <- Range(weekly)
        plot(addTA(rr, on=1, col=c('blue','brown','black')))
        dev.off()
        tt <- c(tt, t)
        roars <- c(roars, last(roar))
      }
    }
  }
  #return <- c(ticker,as.vector(last(roar)))
  #print(tt)
  #print(roars)
  return <- data.frame(tickers = tt, roars = roars)
}

