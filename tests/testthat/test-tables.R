context("Test Tables API")

quandl_key_set()

describe("quandl_datatable()", {
  it("works as expected on simple cases", {

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

  it("validates input", {

    expect_error(quandl_datatable(code = 10))
    expect_error(quandl_datatable(code = "WIKI/PRICES", .batch = 1.2))
  })

  it("automatically fetches all results", {

    expect_identical(
      quandl_datatable("WIKI/PRICES", ticker = "AAPL", date.gte = "2018-01-01", date.lt = "2018-02-01"),
      quandl_datatable("WIKI/PRICES", ticker = "AAPL", date.gte = "2018-01-01", date.lt = "2018-02-01", qopts.per_page = 10L)
    )
  })

  it("can be batched without affecting results", {
    tickers <- c("AAPL", "GOOGL", "MSFT")

    expect_equal(
      quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02"),
      quandl_datatable("WIKI/PRICES", ticker = tickers, date = "2018-01-02", .batch = 2L)
    )
  })

  it("can batch and page simultaneously", {
    tickers <- c("AAPL", "GOOGL", "MSFT")

    # > 100 results
    expect_equal(
      quandl_datatable("WIKI/PRICES", ticker = tickers, date.gte = "2018-01-01", date.lt = "2018-02-01"),
      quandl_datatable("WIKI/PRICES", ticker = tickers, date.gte = "2018-01-01", date.lt = "2018-02-01", qopts.per_page = 20, .batch = 2L)
    )
  })

  it("shows errors from Quandl", {

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

  it("is roughly equivalent to Quandl::Quandl.datatable", {

    params <- list("WIKI/PRICES", ticker = "AAPL", date.gte = "2018-01-01", date.lte = "2018-02-01")

    # types can differ, so only dims are checked
    expect_identical(
      dim(do.call(quandl_datatable,         params)),
      dim(do.call(Quandl::Quandl.datatable, params))
    )

    # both can fetch multiple pages
    expect_identical(
      dim(do.call(quandl_datatable,         c(params, list(qopts.per_page = 10)))),
      dim(do.call(Quandl::Quandl.datatable, c(params, list(qopts.per_page = 10, paginate = TRUE))))
    )
  })
})


describe("quandl_datatable_meta()", {

  it("validates input", {
    expect_error(quandl_datatable_meta(123))
  })

  it("returns a list", {
    expect_list(
      quandl_datatable_meta("WIKI/PRICES"),
      all.missing = FALSE, names = "named"
    )
  })
})
