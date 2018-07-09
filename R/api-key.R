#' Set your Quandl API key
#'
#' If no key is provided, will look in the environment variable
#' "QUANDL_API_KEY". If none found, will error.
#'
#' Setting a key is necessary for almost all calls to Quandl. All registered
#' accounts get a key, even those not subscribing to paid bundles. Find your key
#' in your [account settings](https://www.quandl.com/account/api).
#'
#' @references [API documentation](https://docs.quandl.com/docs#section-authentication)
#'
#' @param api_key <character(1)> Quandl-provided API key for a registered account.
#'
#' @return <`character(1)`> the key, invisibly.
#'
#' @export
#'
#' @examples
#' quandl_key_set("this-ismykey")
#'
#' # if you set your key in the "QUANDL_API_KEY environment variable, that will
#' # be used automatically
#' quandl_key_set()
quandl_key_set <- function(api_key = NULL) {

  if (rlang::is_null(api_key)) {
    if (Sys.getenv("QUANDL_API_KEY") != "") {
      api_key <- Sys.getenv("QUANDL_API_KEY")
    } else {
      stop('No key to set; either pass a string to `quandl_key_set()` or set the "QUANDL_API_KEY" environment variable.')
    }
  }

  if (!rlang::is_string(api_key)) {
    stop("`api_key` must be a single string")
  }

  options(Quandl.api_key = api_key)

  invisible(getOption("Quandl.api_key"))
}


#' Return an already-set API key.
#'
#' @noRd
#' @keywords internal
quandl_key_get <- function() {
  api_key <- getOption("Quandl.api_key")

  if (rlang::is_null(api_key)) {
    stop("No key has been set; use `quandl_key_set()` to set one.")
  }

  api_key
}
