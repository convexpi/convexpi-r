\name{run_agent}
\alias{run_agent}
\title{Trade live on the ConvexPi Arena over WebSocket}
\usage{
run_agent(on_tick, agent_id, server = "wss://arena-production-e3f1.up.railway.app",
  max_ticks = 200, on_fill = NULL)
}
\arguments{
\item{on_tick}{Function of one argument (the market state) returning a list of orders.}
\item{agent_id}{Your unique name on the Arena leaderboard.}
\item{server}{Arena WebSocket URL.}
\item{max_ticks}{How many ticks to run before disconnecting.}
\item{on_fill}{Optional function \code{(tick, price, qty, side)} called when your order trades.}
}
\value{
A data frame of per-tick telemetry: \code{tick}, \code{pnl} (dollars), \code{position},
\code{mid} (dollars), \code{last_price} (dollars).
}
\description{
Connect to the Arena and trade a limit-order book. Each tick, \code{on_tick(state)} receives a market
snapshot (\code{best_bid}, \code{best_ask}, \code{last_price}, \code{mid}, \code{spread},
\code{depth}, \code{recent_trades}, \code{position}, \code{cash}, \code{pnl}, \code{my_open_orders};
prices in cents) and returns orders from \code{\link{arena_limit}} / \code{\link{arena_market_order}}
/ \code{\link{arena_cancel}} (empty \code{list()} = do nothing). Requires the \pkg{websocket} and
\pkg{later} packages. Reconnect with the same \code{agent_id} to keep your position and cash.
}
\examples{
\dontrun{
naive_mm <- function(state) {
  if (is.null(state$best_bid) || is.null(state$best_ask)) return(list())
  mid <- (state$best_bid + state$best_ask) \%/\% 2
  c(lapply(state$my_open_orders, function(o) arena_cancel(o$order_id)),
    list(arena_limit("buy", mid - 5, 10), arena_limit("sell", mid + 5, 10)))
}
run_agent(naive_mm, agent_id = "mm_demo", max_ticks = 200)
}
}
