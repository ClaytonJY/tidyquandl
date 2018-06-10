#' Retrieve data from a Quandl Tables API Endpoint
#'
#' This is a wrapper around [Quandl::Quandl.datatable] which allows for multiple
#' attempts, always fetches all results (`paginate = TRUE`), and converts the
#' result to a tibble.
#'
#' Will throw error if empty table returned.
#'
#' @param code <`character(1)`> Datatable code on Quandl, specified as a string;
#'   see [Quandl::Quandl.datatable]
#' @param ... Additional arguments passed to [Quandl::Quandl.datatable]
#' @param max_attempts <`integer(1)`> Maximum number of times to attempt query.
#' @param delay <`integer(1)`> Number of seconds to wait between retries.
#'
#' @return <`tbl_df`> Results from Quandl in tibble form.
#' @export
#'
#' @examples
#' Quandl::Quandl.api_key(Sys.getenv("QUANDL_API_KEY"))
#'
#' # get metadata on Apple from Zack's Master Table
#' quandl_datatable("ZACKS/MT", ticker = "AAPL")
#'
#' # get stock splits from Apple
#' quandl_datatable("ZACKS/HDM", m_ticker = "AAPL", action_type = 6)
quandl_datatable <- function(code, ..., max_attempts = 3L, delay = 1L) {

  checkmate::assert_string(code)
  checkmate::assert_count(max_attempts, positive = TRUE)
  checkmate::assert_count(delay,   positive = TRUE)

  # API key is NULL if unset
  checkmate::assert_string(Quandl::Quandl.api_key())

  func <- purrr::safely(Quandl::Quandl.datatable)

  response <- list(result = NULL)
  attempts <- 0L

  while (is.null(response$result) && (attempts < max_attempts)) {

    if (attempts > 0L) Sys.sleep(delay)

    response <- func(code, paginate = TRUE, ...)

    attempts <- attempts + 1L
  }

  # error if no results
  if (is.null(response$result))   stop("No result from Quandl after ", attempts, " attempts. Last error:\n\t\t\t\t", response$error)
  if (nrow(response$result) == 0) stop("Quandl returned empty table.")

  tibble::as_tibble(response$result)
}
