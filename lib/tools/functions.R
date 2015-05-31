# functions
# get price data for a list of tickers over a json call.
getSymbolsJSON <-
  function(tickers, url = "http://localhost:3000/companies", env=.GlobalEnv) {
  n = length(tickers)
  i = 1
  while(i <= n) {
#    print(tickers[i])
#    print(paste(url,"/",tickers[i],"/prices.json", sep=""))
    try (json_data <- fromJSON(readLines(paste(url,"/",tickers[i],"/prices.json", sep=""))), silent=T)
#    print(json_data)
    sym <- do.call("rbind", lapply(json_data, data.frame))
    sym <- sym[c("date","open","high","low","close","volume")]
    if(!is.null(sym)) {
      sym$open = sym$open/1000 
      sym$close = sym$close/1000 
      sym$low = sym$low/1000 
      sym$high = sym$high/1000 
      assign(tickers[i], as.xts(sym[,-1],as.Date(as.POSIXct(sym$date,format="%Y-%m-%d", tz="UTC"))), envir=env)
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
