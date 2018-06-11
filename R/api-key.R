#' Get and Set an API key for Quandl
#'
#' Setting a key is necessary for almost all calls to Quandl. All registered
#' accounts get a key, even those not subscribing to paid bundles. Find your key
#' in your [account settings](https://www.quandl.com/account/api).
#'
#' @references [API documentation](https://docs.quandl.com/docs#section-authentication)
#'
#' @param api_key <character(1)> Quandl-provided API key for a registered account.
#'
#' @return If no input given, the currently set key. Note this will be NULL if
#'   no key has been set yet. When setting a key, the key will be returned
#'   invisibly.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' quandl_api_key("this-ismykey")
#' }
quandl_api_key <- function(api_key = NULL) {

  # set key if one is provided
  if (!is.null(api_key)) {
    stopifnot(rlang::is_string(api_key) && nchar(api_key) > 0)

    options(Quandl.api_key = api_key)

    return(invisible(getOption("Quandl.api_key")))
  }

  getOption("Quandl.api_key")
}
