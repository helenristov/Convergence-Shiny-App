## @knitr preparation

library(xts)
library(ggplot2)
library(gridExtra)
library(knitr)

# Load the data whether report is being generated or the script is being run manually
if(file.exists("ConvergenceSummary.R")) {
  source("ConvergenceSummary.R")
} else {
  source("Research/Convergence/ConvergenceSummary.R")
}

days       <- c(1, seq(5, 60, 5))
thresholds <- seq(0.02, 0.3, 0.02)
files      <- list.files("/data/shared/CL/DF")
res        <- data.frame()
df.stats   <- data.frame()

start <- Sys.time()
for (file in files) {
  message(paste("Working on", file))
  
  series       <- gsub(".RData", "", file)
  front.spread <- substr(series, 0, nchar(series) - 6)
  front.spread <- paste0(substr(front.spread, 0, nchar(front.spread) - 5), substr(front.spread, nchar(front.spread) - 4, nchar(front.spread)))
  expiry       <- CLExpiration(substr(front.spread, 0, 4), Sys.Date())
    
#   load(paste0("/data/shared/CL/DF/", file))
#   
#   temp <- subset(get(series), select = "WMP")
#   
#   df.stats <- rbind(df.stats,
#                     data.frame(
#                       series = series,
#                       obs    = length(temp),
#                       mean   = mean(temp),
#                       median = median(temp),
#                       q.5    = quantile(temp, probs = 0.05)[[1]],
#                       q.95   = quantile(temp, probs = 0.95)[[1]],
#                       sd     = sd(temp),
#                       skew   = skewness(temp),
#                       kurt   = kurtosis(temp),
#                       min    = min(temp),
#                       max    = max(temp)))
  
  #res <- rbind(res, data.frame(Series = series, ConvergenceSummary(temp, days, thresholds)))
  
  #rm(temp, get(series))
  print(paste(series, expiry))
}
save(res, df.stats, file = "~/Research/Convergence/PreprocessedConvergenceNew.RData")
print(Sys.time() - start)



ggplot(data = res, aes(x = perf.period, color = factor(threshold))) +
  geom_line(aes(y = converged.pct)) +
  facet_wrap(~ Series, ncol = 1) +
  labs(color = "Threshold")


grid.arrange(
  qplot(cm3, data = cm[cm$disjoint > 0,], binwidth = 0.0025, xlab = "Reversion", main = "Reversion Histogram for Disjoint > 0"),
  qplot(cm3, data = cm[cm$disjoint < 0,], binwidth = 0.0025, xlab = "Reversion", main = "Reversion Histogram for Disjoint < 0"),
  main = "Reversion Distributions for CLF4.G4.H4.J4 w/Fixed Thresholds",
  ncol = 2)