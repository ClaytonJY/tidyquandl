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
  long_param_batches <- split(long_param, ceiling(seq_along(long_param) / batch_size))

  # return list of batches
  purrr::map(long_param_batches, ~ c(short_params, rlang::set_names(list(.x), names(long_params))))
}
