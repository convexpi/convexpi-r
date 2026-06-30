#' Load the ConvexPi synthetic market
#'
#' Returns the exact synthetic equity panel the grader scores on, generated from the published
#' Python \code{convexpi-lab} package via \pkg{reticulate} (deterministic from the seed, so it
#' always matches the grader). Fit your strategy on the \code{"train"} split; the \code{"test"}
#' split is what you are ultimately scored on.
#'
#' @param split Which split to return: \code{"train"} or \code{"test"}.
#' @param seed Integer market seed. Defaults to 42, the graded market.
#' @return A list with \code{prices} (a days x stocks matrix) and \code{features} (a named list of
#'   days x stocks matrices, e.g. \code{mom_1m}).
#' @examples
#' \dontrun{
#' m <- synthetic_market("train")
#' dim(m$prices)
#' names(m$features)
#' }
#' @export
synthetic_market <- function(split = c("train", "test"), seed = 42) {
  split <- match.arg(split)
  lab <- reticulate::import("convexpi.lab", delay_load = TRUE)
  market <- lab$SyntheticMarket(seed = as.integer(seed))
  list(prices = market$prices(split), features = market$features(split))
}
