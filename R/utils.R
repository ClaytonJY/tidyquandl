#' Make a request to Quandl
#'
#' Responses returned as text to be parsed further.
#' Automatically retries up to 3 times.
#' Errors are parsed and returned nicely.
#'
#' @return <`response`>
#'
#' @noRd
#' @keywords internal
quandl_api <- function(
  path,
  type    = c("csv", "json", "xml"),
  query   = NULL,
  api_key = quandl_api_key(),
  ...
) {

  type   <- rlang::arg_match(type)
  if (type == "xml") stop("Type `xml` currently unsupported.")

  # set API and client info as headers
  headers <- c(
    `Request-Source`         = 'R',
    `Request-Source-Version` = paste0("tidyquandl_", utils::packageVersion("tidyquandl")),
    `X-Api-Token`            = api_key
  )

  # collapse multi-value paramters
  if (!is.null(query)) query <- lapply(query, paste, collapse = ",")

  # fetch result from Quandl
  # will retry for HTTP errors (400+)
  response <- httr::RETRY(
    "GET",
    url   = glue::glue("https://www.quandl.com/api/v3/{path}.{type}"),
    query = query,
    httr::add_headers(.headers = headers),
    ...
  )

  # error on http codes 400+
  if (httr::http_error(response)) {
    stop(build_error_message(
      httr::content(response, as = "text"),
      httr::http_type(response),
      httr::status_code(response)
    ))
  }

  response
}


#' Build error message by parsing content
#'
#' @noRd
#' @keywords internal
build_error_message <- function(content, type = c("text/csv", "application/json"), status_code) {

  type <- rlang::arg_match(type)

  # parse error into list/tibble with names "code", "message"
  quandl <- switch(
    type,
    "text/csv"         = readr::read_csv(content, col_types = "cc"),
    "application/json" = jsonlite::fromJSON(content)[[1]]
  )

  msg <- glue::glue(
    "{quandl$message}",
    "Quandl Error Code: {quandl$code}",
    "HTTP Status Code: {status_code}",
    .sep = "\n"
  )

  msg
}


#' Split a set of parameters into batches
#'
#' @noRd
#' @keywords internal
batch_parameters <- function(params, batch_size) {

  # if not batching, wrap in list
  if (is.null(batch_size) || all(lengths(params) <= batch_size)) {
    return(list(params))
  }

  # separate into short / long groups of paramters
  short_params <- params[lengths(params) <= batch_size]
  long_params <- params[lengths(params) > batch_size]

  if (length(long_params) > 1) {
    stop("Batching over multiple parameters not yet supported.")
  }

  # split long parameter
  long_param <- long_params[[1]]
  long_param_batches <- rlang::set_names(split(long_param, ceiling(seq_along(long_param) / batch_size)), NULL)

  # return list of batches
  purrr::map(long_param_batches, ~ c(short_params, rlang::set_names(list(.x), names(long_params))))
}

#' Fetch all results by following cursor_id in response header
#'
#' @noRd
#' @keywords internal
fetch_all_results <- function(params, path) {
  responses = list()

  while (TRUE) {
    response <- quandl_api(path, "csv", params)
    responses <- c(responses, list(response))

    cursor_id <- httr::headers(response)$cursor_id

    if (rlang::is_null(cursor_id)) break

    params$qopts.cursor_id <- cursor_id
  }

  responses
}
