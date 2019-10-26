load("../PreprocessedConvergence.RData")

res$threshold <- as.numeric(levels(res$threshold))[res$threshold]
res$total.reversion <- res$avg.reversion * res$disjoint.obs