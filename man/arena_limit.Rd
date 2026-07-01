\name{arena_limit}
\alias{arena_limit}
\alias{arena_market_order}
\alias{arena_cancel}
\title{Build Arena orders}
\usage{
arena_limit(side, price, qty)
arena_market_order(side, qty)
arena_cancel(order_id)
}
\arguments{
\item{side}{"buy" or "sell".}
\item{price}{Limit price in integer cents.}
\item{qty}{Quantity in shares.}
\item{order_id}{The resting order's id (from \code{state$my_open_orders}).}
}
\value{A list describing the order, to return from your \code{on_tick}.}
\description{
Constructors for the three Arena order types: a resting \code{arena_limit} order, an immediate
\code{arena_market_order}, and \code{arena_cancel} to pull a resting order.
}
