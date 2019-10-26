if(file.exists("ConvergenceMetricsCpp.R")) {
  source("ConvergenceMetricsCpp.R")
} else {
  source("Research/Convergence/ConvergenceMetricsCpp.R")
}

ConvergenceSummary <- function(x, days, thresholds) {
#
# cs <- ConvergenceSummary(CLF3.G3.H3.J3$WMP, c(1, 5, 10, 25), seq(0.03, 0.06, 0.01))
  
  res <- expand.grid(perf.period = days, threshold = thresholds)
  
  for(i in 1:nrow(res)) {
    message(paste("Working on perf.period =", res$perf.period[i], "and threshold =", res$threshold[i]))
    
    # Data goes from 6:00-15:30 everyday -> (1 + 2 * 60 * 9.5) bars per day
    cm <- ConvergenceMetricsCpp(x, 
                                threshold  = res$threshold[i], 
                                perfPeriod = (1 + 2 * 60 * 9.5) * res$perf.period[i],
                                step       = 10)
    
    res$obs[i]           <- nrow(cm)
    res$mean[i]          <- mean(cm$WMP)
    res$std.dev[i]       <- sd(cm$WMP)
    res$min[i]           <- min(cm$WMP)
    res$max[i]           <- max(cm$WMP)
    res$disjoint.obs[i]  <- length(na.omit(cm$disjoint))
    res$disjoint.pct[i]  <- res$disjoint.obs[i] / res$obs[i]
    res$converged.obs[i] <- sum(na.omit(cm$cm1))
    res$converged.pct[i] <- res$converged.obs[i] / res$disjoint.obs[i]
    res$avg.reversion[i] <- mean(na.omit(cm$cm3))
    res$avg.shortfall[i] <- mean(abs(na.omit(cm$disjoint)))
    #res$reversion.p.value[i] <- t.test(cm$cm3, alternative = "greater")$p.value
    #res$disjoint.adj.r2[i]   <- summary(lm(cm2 ~ disjoint + 0, data = cm))$adj.r.squared
  }
  
  return(res)
}