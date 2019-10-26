# ConvergenceMetricsCpp
#
# This scripts creates an Rcpp function to calculate convergence metrics for a data series
#
# INPUTS
# -x:          column vector of a numeric data series
# -limit:      assumed mean of the series
# -epsilon:    bands around the limit that set the convergence zone
# -threshold:  value above and below the limit which determine if an observation is disjoint
# -perfPeriod: # of bars to test ahead for convergence
# -step:       check bars at this interval for convergence (value of 1 means check every bar)
#
# OUTPUT: a dataframe with the following columns:
# -disjoint: the distance the current observation is above or below the current threshold
# -cm1:      boolean to indicate if the series converged at some point during the 
#            performance period
# -cm2:      if the series converged, the distance from the open of the performance period
#            to the threshold it converged to. If the series didn't converge, the change
#            from the open to the close.
# -cm3:      same as cm3 but signed so that positive values indicate reversion to the mean
# 

library(Rcpp)

src <- '
DataFrame ConvergenceMetricsCpp(NumericVector x, double limit = 0, double epsilon = 0.01, double threshold = 0.05, int perfPeriod = 1141, int step = 10) {
  const int n = x.size(); 
  
  DatetimeVector dates(NumericVector(x.attr("index")));
  
  NumericVector disjoints = NumericVector(n, NA_REAL);
  LogicalVector cm1       = LogicalVector(n, NA_LOGICAL);
  NumericVector cm2       = NumericVector(n, NA_REAL);
  NumericVector cm3       = NumericVector(n, NA_REAL);
  //NumericVector daysToExp = NumericVector(n, NA_REAL);

  for (int i = 0; i < n - perfPeriod; i += step) {
    const double open = x(i);
    double disjoint   = 0;

    //daysToExp(i) = n - i;
  
    if (open > limit + threshold)
      disjoint = open - (limit + threshold);
    else if (open < limit - threshold)
      disjoint = open - (limit - threshold);
    
    if (disjoint != 0) {
      const double high  = *std::max_element(x.begin() + 1 + i, x.begin() + i + perfPeriod);
      const double low   = *std::min_element(x.begin() + 1 + i, x.begin() + i + perfPeriod);
      const double close = x(i + perfPeriod);
  
      disjoints(i) = disjoint;
      cm1(i) = (disjoint > 0 ? low <= limit + epsilon : high >= limit - epsilon);
      cm2(i) = (disjoint > 0 ? 
        (low <= limit + epsilon ? limit + epsilon - open : close - open) : 
        (high >= limit - epsilon ? limit - epsilon - open : close - open));
      cm3(i) = (disjoint > 0 ? -1 : 1) * cm2(i);
    }
  }
  
  DataFrame out = DataFrame::create(
    Named("DateTime") = dates,
    Named("WMP")      = x,
    //Named("daysToExp")= daysToExp,
    Named("disjoint") = disjoints, 
    Named("cm1")      = cm1,
    Named("cm2")      = cm2,
    Named("cm3")      = cm3);

  return out;
}
'

cppFunction(src)