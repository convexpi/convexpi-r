#' Default Arena WebSocket server.
#' @keywords internal
ARENA_DEFAULT_SERVER <- "wss://arena-production-e3f1.up.railway.app"

#' Build an Arena limit order.
#'
#' @param side "buy" or "sell".
#' @param price Limit price in integer cents.
#' @param qty Quantity (shares).
#' @param reconnect_token Private credential from a previous welcome; required to resume an account.
#' @param on_welcome Optional callback to persist the welcome credential securely.
#' @return A list describing the order, for return from \code{on_tick}.
#' @export
arena_limit <- function(side, price, qty) {
  list(order_type = "limit", side = side, price = as.integer(round(price)), qty = as.integer(qty))
}

#' Build an Arena market order (takes the best available price immediately).
#' @param side "buy" or "sell".
#' @param qty Quantity (shares).
#' @param reconnect_token Private credential from a previous welcome; required to resume an account.
#' @param on_welcome Optional callback to persist the welcome credential securely.
#' @return A list describing the order.
#' @export
arena_market_order <- function(side, qty) {
  list(order_type = "market", side = side, qty = as.integer(qty))
}

#' Cancel a resting Arena order by id (from \code{state$my_open_orders}).
#' @param order_id The resting order's id.
#' @param reconnect_token Private credential from a previous welcome; required to resume an account.
#' @param on_welcome Optional callback to persist the welcome credential securely.
#' @return A list describing the cancel.
#' @export
arena_cancel <- function(order_id) {
  list(order_type = "cancel", cancel_id = as.integer(order_id))
}

#' Trade live on the ConvexPi Arena over WebSocket.
#'
#' Connect to the Arena and trade a limit-order book. Each tick your \code{on_tick(state)} receives a
#' market snapshot (a list with \code{best_bid}, \code{best_ask}, \code{last_price}, \code{mid},
#' \code{spread}, \code{depth}, \code{recent_trades}, \code{position}, \code{cash}, \code{pnl},
#' \code{my_open_orders}; all prices in cents) and returns a list of orders built with
#' \code{\link{arena_limit}}, \code{\link{arena_market_order}}, \code{\link{arena_cancel}} (an empty
#' \code{list()} = do nothing). Reconnect with the same \code{agent_id} and \code{reconnect_token} to keep your position/cash.
#'
#' Requires the \code{websocket} and \code{later} packages.
#'
#' @param on_tick Function of one argument (the market state) returning a list of orders.
#' @param agent_id Your unique name on the Arena leaderboard.
#' @param server Arena WebSocket URL.
#' @param max_ticks How many ticks to run before disconnecting.
#' @param on_fill Optional function \code{(tick, price, qty, side)} called when your order trades.
#' @param reconnect_token Private credential from a previous welcome; required to resume an account.
#' @param on_welcome Optional callback to persist the welcome credential securely.
#' @return A data frame of per-tick telemetry: \code{tick}, \code{pnl} (dollars), \code{position},
#'   \code{mid} (dollars), \code{last_price} (dollars).
#' @export
run_agent <- function(on_tick, agent_id, server = ARENA_DEFAULT_SERVER,
                      max_ticks = 200, on_fill = NULL, reconnect_token = NULL, on_welcome = NULL) {
  for (pkg in c("websocket", "later")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(sprintf("run_agent() needs the '%s' package: install.packages('%s')", pkg, pkg))
    }
  }
  telem <- list(); n <- 0L; done <- FALSE
  ws <- websocket::WebSocket$new(server, autoConnect = FALSE)

  ws$onOpen(function(event) {
    ws$send(jsonlite::toJSON(list(type = "join", agent_id = agent_id, reconnect_token = reconnect_token), auto_unbox = TRUE))
  })
  ws$onMessage(function(event) {
    msg <- jsonlite::fromJSON(event$data, simplifyVector = FALSE)
    if (identical(msg$type, "welcome")) {
      reconnect_token <<- msg$reconnect_token
      if (!is.null(on_welcome)) on_welcome(msg)
    } else if (identical(msg$type, "tick")) {
      bb <- msg$best_bid; ba <- msg$best_ask; lp <- msg$last_price
      mid    <- if (!is.null(bb) && !is.null(ba)) (bb + ba) / 2 else if (!is.null(lp)) as.numeric(lp) else NULL
      spread <- if (!is.null(bb) && !is.null(ba)) ba - bb else NULL
      pnl    <- if (!is.null(mid)) (msg$cash + msg$position * mid) / 100 else NULL
      state <- list(tick = msg$tick, best_bid = bb, best_ask = ba, last_price = lp,
                    mid = mid, spread = spread, depth = msg$depth,
                    recent_trades = msg$recent_trades, position = msg$position,
                    cash = msg$cash, pnl = pnl, my_open_orders = msg$my_open_orders)
      orders <- tryCatch(on_tick(state),
                         error = function(e) { message("on_tick error: ", conditionMessage(e)); list() })
      if (is.null(orders)) orders <- list()
      ws$send(jsonlite::toJSON(list(type = "orders", tick = msg$tick, orders = orders), auto_unbox = TRUE))
      telem[[length(telem) + 1L]] <<- data.frame(
        tick = msg$tick,
        pnl = if (is.null(pnl)) NA_real_ else pnl,
        position = msg$position,
        mid = if (is.null(mid)) NA_real_ else mid / 100,
        last_price = if (is.null(lp)) NA_real_ else lp / 100)
      n <<- n + 1L
      if (n >= max_ticks) { done <<- TRUE; ws$close() }
    } else if (identical(msg$type, "fill") && !is.null(on_fill)) {
      on_fill(msg$tick, msg$price, msg$qty, msg$side)
    }
  })
  ws$onClose(function(event) done <<- TRUE)
  ws$onError(function(event) { message("Arena WS error: ", event$message); done <<- TRUE })

  ws$connect()
  while (!done) later::run_now(timeout = 0.25)
  result <- if (length(telem) == 0) data.frame() else do.call(rbind, telem)
  attr(result, "reconnect_token") <- reconnect_token
  result
}
