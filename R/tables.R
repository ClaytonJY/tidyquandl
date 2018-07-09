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
#' quandl_key_set()
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

  # process batches
  csv <- batch_parameters(list(...), .batch) %>%
    purrr::map(fetch_all_results, path = paste0("datatables/", code)) %>%      # make requests
    rlang::flatten() %>%
    purrr::map_chr(httr::content, as = "text", encoding = "UTF-8") %>%         # extract text
    purrr::map_at(seq(length(.))[-1], stringr::str_replace, "^.+?\n", "") %>%  # strip headers
    stringr::str_c(collapse = "\n")                                            # collapse to single string

  # read all at once
  readr::read_csv(csv)
}
