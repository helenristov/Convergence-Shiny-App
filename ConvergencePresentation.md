Convergence Analysis
========================================================
author: Helen Ristov, Jing Song, and Ryan Ranson
date:   September 02, 2017
width:  1920
height: 1080



Introduction
========================================================

The goal of this analysis is to identify points in double fly price series where there is a high probability of mean reversion and also to determine an appropriate expected holding period for trades.

Definitions
- Limit: assumed long-term mean of the double fly price series
- Epsilon: distance above and below the limit which defines the convergence zone
- Threshold: distance above and below the limit for which we will consider an observation disjoint
- Performance Period: time period we will look at each disjoint instance to test for convergence

A disjoint observation is said to converge if it reaches the convergence zone at any point during the performance period. The reversion metric is the change in the direction of the limit of the series until either the series converges or reaches the end of the performance period.

We will look at 30 second bars of 60 CL double fly price series from CLF0.G0.H0.J0 to CLZ4.F5.G5.H5. The limit parameter is assumed to be 0 and epsilon is set at 0.01.

Data Summary
========================================================

<!-- html table generated in R 3.3.1 by xtable 1.8-2 package -->
<!-- Sat Sep  2 17:12:45 2017 -->
<table border=1>
<tr> <th> Total.Obs </th> <th> Mean </th> <th> Std.Dev </th> <th> Skewness </th> <th> Kurtosis </th> <th> Min </th> <th> Max </th>  </tr>
  <tr> <td align="right"> 20,535,553 </td> <td align="right"> -0.0069 </td> <td align="right"> 0.0513 </td> <td align="right"> -0.2407 </td> <td align="right"> 2.0486 </td> <td align="right"> -0.9003 </td> <td align="right"> 0.4555 </td> </tr>
   </table>
![plot of chunk unnamed-chunk-1](ConvergencePresentation-figure/unnamed-chunk-1-1.png)

Convergence Metrics
========================================================
left: 30%



- Convergence increases with performance period
- High convergence rates for high thresholds are largley due to small sample size (there are only 2460 disjoint observations for performance period = 30 and threshold = 0.25)
- Min for performance period = 1 occurs at threshold = 0.14
- Min for performance period = 30 occurs at threshold = 0.16

***

![plot of chunk unnamed-chunk-3](ConvergencePresentation-figure/unnamed-chunk-3-1.png)

Shortfall Metrics
========================================================
left: 30%



- Avg Shortfall indicates how far, on average, the series moves above/below the threshold value during the performance period
- Provides an indication of how far we can expect the trade to move against us if it is put on at the threshold
- Min for performance period = 1 occurs at threshold = 0.16
- Min for performance period = 30 occurs at threshold = 0.18

***

![plot of chunk unnamed-chunk-5](ConvergencePresentation-figure/unnamed-chunk-5-1.png)

Risk-Adjusted Reversion Metrics
========================================================
left: 30%

- Reversion / Avg Shortfall provides a risk-adjusted measure of how far the series is expected to revert during the performance period
- For long performance periods, the marginal improvement in this metric appears to begin falling at a threshold of 0.2

***

![plot of chunk unnamed-chunk-6](ConvergencePresentation-figure/unnamed-chunk-6-1.png)

Conclusion
========================================================



Recommendations
- Threshold values in the range of 0.14 - 0.2 appear to give the best results
    - Threshold of 0.14 results in 0.67% of observations being disjoint
    - Threshold of 0.2 results in 0.1% of observations being disjoint

Next Steps
- Determining optimal position scaling as double fly becomes more disjointed
- Taking into account time until expiration
