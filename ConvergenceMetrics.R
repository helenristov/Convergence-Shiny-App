ConvergenceMetrics <- function(x, limit, epsilon, threshold, perf.period) {
  # ConvergenceMetrics returns a dataframe of metrics to test if the prices series
  #  converges to the 'convergence zone' of limit+/-epsilon when outside of this
  #  zone.
  #
  # PARAMETERS
  #  x:           xts object of series to be tested for convergence (must be nx1)
  #  limit:       value at which the series converges to
  #  epsilon:     distance from limit which sets the convergence zone
  #  perf.period: number of bars to test for convergence
  #
  # RETURNS
  #  Dataframe of each disjoint instance with the following columns
  #   -disjoint: distance above/below the convergence zone
  #   -cm1:      boolean to signal if the series converged at any point during the 
  #              performance period
  #   -cm2:      % change from the start of the performance period to the end
  #   -cm3:      defined as (Open-Low)/(High-Low) for disjoint > 0 and 
  #              (High-Open)/(High-Low) for disjoint < 0. This gives an idea of the
  #              reward/risk for a given disjoint level (1=best risk/reward, 
  #              0=worst risk/reward)
  
  library(xts)
  
  # Check inputs
  if(ncol(x) != 1) {
    stop("prices must be an nx1 vector.")
  } 
  else if(perf.period < 1) {
    stop("perf.period must be >= 1")
  }
  
  highs <- rollmaxr(x, perf.period)
  lows  <- rollmaxr(-x, perf.period)
  
  # Preallocate vectors
  disjoint <- ifelse(x > limit + threshold, 
                     x - (limit + threshold), 
                     ifelse(x < limit - threshold, x - (limit - threshold), 0))
  cm1      <- ifelse(disjoint > 0, lows <= limit + threshold,
                     ifelse(disjoint < 0, highs >= limit - threshold, NA))
  
  res <- xts(data.frame(x, disjoint, cm1, highs, lows), index(x))
  
  return(res)
}