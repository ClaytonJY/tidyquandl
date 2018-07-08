#' Retrieve data from a Quandl Tables API Endpoint
#'
#' This is a wrapper around [Quandl::Quandl.datatable] which allows for multiple
#' attempts, batches long parameters into multiple requests, always fetches all
#' results (`paginate = TRUE`), and converts the result to a tibble.
#'
#' @param code <`character(1)`> Datatable code on Quandl, specified as a string;
#'   see [Quandl::Quandl.datatable]
#' @param ... Additional arguments passed to [Quandl::Quandl.datatable]
#' @param max_attempts <`integer(1)`> Maximum number of times to attempt query.
#' @param delay <`integer(1)`> Number of seconds to wait between retries.
#' @param batch_size <`integer(1)`> maximum length of any parameter in a single
#'   request; see Batching below
#'
#' @return <`tbl_df`> Results from Quandl in tibble form.
#'
#' @section Batching:
#' The Quandl API can only support a limited number of parameters in one call.
#' If we want to filter on e.g. 1,000 tickers, that requires multiple requests
#' to complete. This wrapper will handle this for you, automatically making
#' multiple requests to fetch the desired output. Currently, only one `...`
#' input can be longer than `batch_size`, so you can't filter on e.g. both 1000
#' tickers and 1000 dates.
#'
#' @export
#'
#' @examples
#' quandl_api_key(Sys.getenv("QUANDL_API_KEY"))
#'
#' # get one day of prices on Apple from Wiki Prices
#' quandl_datatable("WIKI/PRICES", ticker = "AAPL", date = "2018-01-02")
#'
#' # get one month of prices from two tickers
#' quandl_datatable(
#'   "WIKI/PRICES",
#'   ticker = c("AAPL", "MSFT"),
#'   date.gte = "2018-01-01",
#'   date.lt = "2018-02-01"
#' )
#'
#' # only return some columns
#' quandl_datatable(
#'   "WIKI/PRICES",
#'   ticker = "AAPL",
#'   date = "2018-01-02",
#'   qopts.columns = c("date", "ticker", "close")
#' )
quandl_datatable <- function(code, ..., max_attempts = 2L, delay = 0.5, batch_size = 50L) {
  checkmate::assert_string(code)
  checkmate::assert_count(max_attempts, positive = TRUE)
  checkmate::assert_number(delay, lower = 0)
  checkmate::assert_count(batch_size, positive = TRUE, null.ok = TRUE)

  # API key is NULL if unset
  checkmate::assert_string(Quandl::Quandl.api_key())

  param_batches <- batch_parameters(list(...), batch_size)

  quandl_func <- purrr::safely(purrr::lift_dl(purrr::partial(Quandl::Quandl.datatable, code = code, paginate = TRUE)))

  df <- purrr::map_df(param_batches, function(params) {
    response <- list(result = NULL)
    attempts <- 0L

    while (is.null(response$result) && (attempts < max_attempts)) {
      if (attempts > 0L) Sys.sleep(delay)

      response <- quandl_func(params)

      attempts <- attempts + 1L
    }

    # error if no results
    if (is.null(response$result)) {
      stop("No result from Quandl after ", attempts, " attempts. Last error:\n\t\t\t\t", response$error)
    }

    response$result
  })

  tibble::as_tibble(df)
}
