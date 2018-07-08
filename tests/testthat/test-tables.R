context("Test Tables API")

describe("quandl_datatable", {
  it("works as expected", {
    expect_tibble(
      quandl_datatable("WIKI/PRICES", ticker = "AAPL", date = "2018-01-02"),
      all.missing = FALSE,
      nrows = 1
    )

    expect_tibble(
      quandl_datatable("WIKI/PRICES", ticker = "AAPL", date = "2018-01-02", qopts.columns = c("ticker", "date", "close")),
      any.missing = FALSE,
      nrows = 1,
      ncols = 3
    )
  })

  it("automatically fetches all results", {

    # function template
    f <- purrr::partial(
      quandl_datatable,
      "WIKI/PRICES",
      ticker = "AAPL",
      date.gte = "2018-01-01",
      date.lte = "2018-03-01"
    )

    normal <- f()
    paged  <- f(qopts.per_page = 20)  # 3 pages

    expect_tibble(paged)
    expect_identical(normal, paged)
  })

  it("shows error from Quandl", {

    # bad code
    expect_error(
      quandl_datatable("WIKI/FOOBAR"),
      "datatable 'WIKI/FOOBAR' does not exist"
    )

    # bad filter
    expect_error(
      quandl_datatable("WIKI/PRICES", split_ratio = "1"),
      "cannot use split_ratio column as a filter"
    )
  })

  it("allows for control over retry loop", {

    # max_attempts; number should be printed in error message
    expect_error(
      quandl_datatable("WIKI/FOOBAR", max_attempts = 1),
      "1 attempts"
    )
    expect_error(
      quandl_datatable("WIKI/FOOBAR", max_attempts = 5),
      "5 attempts"
    )

    # delay; two failed calls are quite fast aside from delay
    time <- system.time(purrr::safely(quandl_datatable)("WIKI/FOOBAR", max_attempts = 2, delay = 2))
    expect_true(time["elapsed"] > 2)
  })

  it("can be batched without changing result", {
    tickers <- c("AA", "AAPL", "ABBV", "ABC", "AGN")

    expect_identical(
      quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02"),
      quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02", batch_size = 2L)
    )
  })
})
