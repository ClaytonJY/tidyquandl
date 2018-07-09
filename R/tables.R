#' Retrieve data from a Quandl Tables API Endpoint
#'
#' This is a replacementfor [Quandl::Quandl.datatable] which allows for multiple
#' attempts, batches long parameters into multiple requests, always fetches all
#' results, and always returns a tibble.
#'
#' Results are requested in CSV form and converted to a tibble via [readr::read_csv()].
#'
#' @param code <`character(1)`> datatable code on Quandl
#' @param ... filters and options to pass as parameters
#' @param .batch <`integer(1)`> maximum length of any parameter in a single
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
quandl_datatable <- function(code, ..., .batch = 50L) {

  if (!rlang::is_string(code)) {
    stop("`code` must be a single string")
  }
  if (!rlang::is_scalar_integerish(.batch) | rlang::is_null(.batch)) {
    stop("`.batch` must be a single integerish value")
  }

  # build API path from code
  path <- glue::glue("datatables/{code}")

  # split parameters into a list of batches
  param_batches <- batch_parameters(list(...), .batch)

  # get results from all batches
  # flatten to single-depth list
  responses <- rlang::flatten(purrr::map(param_batches, fetch_all_results, path))

  # extract text from each response
  contents <- purrr::map(responses, httr::content, as = "text", encoding = "UTF-8")

  # append multiple CSV's together
  if (length(contents) > 1) {
    contents <- purrr::modify_at(contents, 2:length(contents), ~sub("^.+?\n", "", .x))
    contents <- paste(contents, collapse = "\n")
  } else {
    contents <- contents[[1]]
  }

  # read all at once
  readr::read_csv(contents)
}
