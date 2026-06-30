\name{synthetic_market}
\alias{synthetic_market}
\title{Load the ConvexPi synthetic market}
\usage{
synthetic_market(split = c("train", "test"), seed = 42)
}
\arguments{
\item{split}{Which split to return: \code{"train"} or \code{"test"}.}
\item{seed}{Integer market seed. Defaults to 42, the graded market.}
}
\value{
A list with \code{prices} (a days x stocks matrix) and \code{features}
(a named list of days x stocks matrices, e.g. \code{mom_1m}).
}
\description{
Returns the exact synthetic equity panel the grader scores on, generated from the
published Python \code{convexpi-lab} package via \pkg{reticulate} (deterministic from
the seed). Fit on \code{"train"}; \code{"test"} is what you are scored on.
}
\examples{
\dontrun{
m <- synthetic_market("train")
dim(m$prices)
names(m$features)
}
}
