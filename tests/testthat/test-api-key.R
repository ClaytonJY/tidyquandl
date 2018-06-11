context("Test authentication")

test_that("API key can be set and read", {

  # no key set
  expect_null(quandl_api_key())

  # set key from environment variable
  api_key <- Sys.getenv("QUANDL_API_KEY")

  # setting should return key
  expect_equal(quandl_api_key(api_key), api_key)

  # key should still be set
  expect_equal(quandl_api_key(), api_key)
})
