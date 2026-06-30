#' Submit an R strategy to a ConvexPi competition
#'
#' Your \code{code} must define \code{on_day(day, features, prices, portfolio)} returning a numeric
#' vector of target weights (one per stock). It is run natively in R by the grader and scored by the
#' same engine as Python and Julia. Create an API key at
#' \url{https://www.convexpi.ai/settings/api-keys}.
#'
#' @param name A name for your strategy.
#' @param code R source (a string) defining \code{on_day(day, features, prices, portfolio)}.
#' @param slug Competition slug. Defaults to \code{"demo-fall-2026"}.
#' @param api_key Your ConvexPi API key. Defaults to \code{Sys.getenv("CONVEXPI_API_KEY")}.
#' @param base_url API base URL. Defaults to \code{"https://www.convexpi.ai"}.
#' @return The parsed JSON response (invisibly), with the new submission id and status.
#' @examples
#' \dontrun{
#' code <- 'on_day <- function(day, features, prices, portfolio) {
#'   s <- features[["mom_1m"]]; s[!is.finite(s)] <- 0
#'   g <- sum(abs(s)); if (g > 0) s / g else s
#' }'
#' submit("my-r-momentum", code)
#' }
#' @export
submit <- function(name, code, slug = "demo-fall-2026",
                   api_key = Sys.getenv("CONVEXPI_API_KEY"),
                   base_url = "https://www.convexpi.ai") {
  if (!nzchar(api_key)) stop("Set CONVEXPI_API_KEY (or pass api_key=). Create one at /settings/api-keys.")
  body <- jsonlite::toJSON(list(slug = slug, strategyName = name, code = code, language = "r"),
                           auto_unbox = TRUE)
  resp <- httr::POST(paste0(base_url, "/api/submissions"),
                     httr::add_headers(Authorization = paste("Bearer", api_key),
                                       `Content-Type` = "application/json"),
                     body = body)
  parsed <- httr::content(resp)
  if (httr::status_code(resp) >= 300) stop(parsed$error %||% "submission failed")
  message("Submitted '", name, "' - track it at ", base_url, "/compete/", slug, "/leaderboard")
  invisible(parsed)
}

`%||%` <- function(a, b) if (is.null(a)) b else a
