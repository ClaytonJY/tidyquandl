context("Test Quandl functions")


test_that("quandl_datatable works as expected", {

  expect_tibble(
    quandl_datatable("ZACKS/HDM", m_ticker = "AAPL", action_type = 6),
    all.missing = FALSE,
    min.rows = 4  # could grow in future
  )

  expect_tibble(
    quandl_datatable("ZACKS/HDM", m_ticker = "AAPL", qopts.columns = c("m_ticker", "ticker", "action_type")),
    any.missing = FALSE,
    min.rows = 4,
    ncols = 3
  )

})


test_that("quandl_datatable shows error from Quandl", {

  # bad code
  expect_error(
    quandl_datatable("ZACKS/FOOBAR"),
    "datatable 'ZACKS/FOOBAR' does not exist"
  )

  # bad filter
  expect_error(
    quandl_datatable("ZACKS/HDM", ticker = "AAPL"),
    "cannot use ticker column as a filter"
  )

})


test_that("quandl_datatable allows for control over retry loop", {

  # max_attempts; number should be printed in error message
  expect_error(
    quandl_datatable("ZACKS/FOOBAR", max_attempts = 1),
    "1 attempts"
  )
  expect_error(
    quandl_datatable("ZACKS/FOOBAR", max_attempts = 5),
    "5 attempts"
  )

  # delay; two failed calls are quite fast aside from delay
  time <- system.time(purrr::safely(quandl_datatable)("ZACKS/FOOBAR", max_attempts = 2, delay = 3))
  expect_true(time["elapsed"] > 3)

})


test_that("quandl_datatable batching doesn't affect output", {

  tickers <- c("AA", "AAPL", "ABBV", "ABC", "AGN")

  expect_identical(
    quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02"),
    quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02", batch_size = 2L)
  )
})
