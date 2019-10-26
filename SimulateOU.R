library(xts)

# Simulate an OU process
n       <- 252 * 10 # number of observations
t       <- 10       # time period in years
mu      <- 0        # long-run mean
lambda  <- 0.75     # speed of mean reversion
sigma   <- 0.1      # volatility

dt      <- t / n
dw      <- rnorm(n, 0, sqrt(dt))
x       <- c(mu)

for (i in 2:n) {
  x[i]  <-  x[i - 1] + lambda * (mu - x[i - 1]) * dt + sigma * dw[i - 1]
}

x <- xts(x, Sys.Date() + 1:n)

plot(x)