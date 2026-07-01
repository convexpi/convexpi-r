# convexpi (R)

Write quant strategies in **R** and submit them to [ConvexPi](https://www.convexpi.ai) — scored by
the same hidden-holdout engine as Python and Julia.

```r
# install from GitHub (R-universe / CRAN pending):
# install.packages("remotes"); remotes::install_github("convexpi/convexpi-r")
library(convexpi)

m <- synthetic_market("train")          # the exact market the grader uses
str(m$features)

code <- 'on_day <- function(day, features, prices, portfolio) {
  s <- features[["mom_1m"]]; s[!is.finite(s)] <- 0
  g <- sum(abs(s)); if (g > 0) s / g else s   # long winners / short losers
}'

Sys.setenv(CONVEXPI_API_KEY = "cpk_...")  # from /settings/api-keys
submit("my-r-momentum", code)
```

Market data comes from the published Python `convexpi-lab` via `reticulate` (deterministic, matches
the grader). Your `on_day` is run natively in R by the grader.
