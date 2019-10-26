library(ggplot2)

CLExpiration <- function(Contract, Date){
  Decade <- (floor((as.POSIXlt(Date)$year + 1900) / 10) * 10)
  Year <- as.numeric(substr(Contract, 4, 4)) + Decade
  
  if((as.POSIXlt(Date)$year + 1900) - Year > 5){
    Year <- Year + 10
  }else if((as.POSIXlt(Date)$year + 1900) - Year < -5){
    Year <- Year - 10
  }
  
  MonthSymbols <- c('G','H','J','K','M','N','Q','U','V','X','Z','F')
  Month <- which(MonthSymbols == substr(Contract, 3, 3))
  
  if(substr(Contract, 3, 3) == "F"){
    Year <- Year - 1
  }
  
  D25 <- as.Date(paste(Year, Month, 25, sep="-"))
  
  BusinessDays <- 0
  i<-1
  while(BusinessDays < 3){
    if(as.POSIXlt(D25 - i)$wday != 0 && as.POSIXlt(D25 - i)$wday != 6){
      BusinessDays <- BusinessDays + 1
    }
    
    if(BusinessDays < 3){
      i <- i + 1
    }
  }
  
  Expiration <- as.Date(D25 - i)
  return(Expiration)
}


days       <- c(1, seq(5, 60, 5))
thresholds <- seq(0.02, 0.3, 0.02)
files      <- list.files("/data/shared/CL/DF")
res        <- data.frame()
df.stats   <- data.frame()

start <- Sys.time()
for (file in files[0:3]) {
  message(paste("Working on", file))
  
  series       <- gsub(".RData", "", file)
  front.spread <- substr(series, 0, nchar(series) - 6)
  front.spread <- paste0(substr(front.spread, 0, nchar(front.spread) - 5), substr(front.spread, nchar(front.spread) - 4, nchar(front.spread)))
  expiry       <- CLExpiration(substr(front.spread, 0, 4), Sys.Date())
  
  load(paste0("/data/shared/CL/DF/", file))
  
  temp <- subset(get(series), select = "WMP")
  temp$TimeLeft <- as.POSIXct(expiry) - index(temp)
  
  res <- rbind(res, data.frame(Series = temp$WMP^2, TimeLeft = as.numeric(as.POSIXct(expiry) - index(temp))))
  
  rm(temp, list = series)
}

qplot(data = res[seq(nrow(res)) %% 1000 == 1 & res$WMP < 0.03,], x=WMP, y=TimeLeft)
