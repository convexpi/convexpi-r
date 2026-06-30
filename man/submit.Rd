\name{submit}
\alias{submit}
\title{Submit an R strategy to a ConvexPi competition}
\usage{
submit(name, code, slug = "demo-fall-2026",
  api_key = Sys.getenv("CONVEXPI_API_KEY"),
  base_url = "https://www.convexpi.ai")
}
\arguments{
\item{name}{A name for your strategy.}
\item{code}{R source (a string) defining \code{on_day(day, features, prices, portfolio)}.}
\item{slug}{Competition slug. Defaults to \code{"demo-fall-2026"}.}
\item{api_key}{Your ConvexPi API key. Defaults to \code{Sys.getenv("CONVEXPI_API_KEY")}.}
\item{base_url}{API base URL. Defaults to \code{"https://www.convexpi.ai"}.}
}
\value{
The parsed JSON response (invisibly), with the new submission id and status.
}
\description{
Your \code{code} must define \code{on_day(day, features, prices, portfolio)} returning a
numeric vector of target weights. It runs natively in R in the grader and is scored by the
same engine as Python and Julia.
}
\examples{
\dontrun{
code <- 'on_day <- function(day, features, prices, portfolio) {
  s <- features[["mom_1m"]]; s[!is.finite(s)] <- 0
  g <- sum(abs(s)); if (g > 0) s / g else s
}'
submit("my-r-momentum", code)
}
}
