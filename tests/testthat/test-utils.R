context("Test utility functions")

quandl_key_set()

describe("quandl_api()", {

  path <- "datatables/WIKI/PRICES"

  it("returns expected text for simple queries", {

    params <- list(
      ticker        = "AAPL",
      date          = "2018-01-02",
      qopts.columns = c("ticker", "date", "close")
    )

    # CSV
    response <- tidyquandl:::quandl_api(path, "csv", params)
    expect_class(response, "response")
    expect_identical(httr::http_type(response), "text/csv")
    expect_string(
      httr::content(response, as = "text"),
      pattern = "^ticker,date,close\nAAPL,2018-01-02,[0-9]+\\.[0-9]{2}\n$"
    )

    # JSON
    response <- tidyquandl:::quandl_api(path, "json", params)
    expect_class(response, "response")
    expect_identical(httr::http_type(response), "application/json")
    expect_string(
      httr::content(response, as = "text"),
      pattern = '"data":.+"AAPL","2018-01-02",[0-9]+\\.[0-9]{2}.+"columns":.+"ticker".+"date".+"close"'
    )
  })

  it("handles vector inputs", {

    params <- list(
      ticker        = c("AAPL", "GOOGL"),
      date          = "2018-01-02",
      qopts.columns = c("ticker", "date", "close")
    )

    # 3 lines: 1 header, 2 results
    expect_string(
      httr::content(tidyquandl:::quandl_api(path, "csv", params), as = "text"),
      pattern = "^(.+\n){3}$"
    )
  })

  it("handles Date inputs", {
    expect_identical(
      httr::content(tidyquandl:::quandl_api(path, "csv", list(ticker = "AAPL", date = "2018-01-02")),          as = "text"),
      httr::content(tidyquandl:::quandl_api(path, "csv", list(ticker = "AAPL", date = as.Date("2018-01-02"))), as = "text")
    )
  })

  it("errors gracefully", {

    # pre-fill some arguments
    f <- purrr::partial(
      tidyquandl:::quandl_api,
      path = "datatables/WIKI/FOOBAR",
      times = 1
    )

    expect_error(
      f(type = "csv"),
      "following datatable .+ does not exist.+404"
    )

    # different types of content should be parsed to identical error messages
    expect_identical(
      purrr::safely(f)(type = "csv")$error,
      purrr::safely(f)(type = "json")$error
    )
  })

  it("doesn't implement `type = 'xml'`", {

    expect_error(tidyquandl:::quandl_api(path, "xml", list(ticker = "AAPL", date = "2018-01-02")))
  })
})


describe("batch_params()", {
  params <- list(
    a = 1,
    b = 3:4,
    c = c(letters, LETTERS),
    d = 5:20
  )

  it("splits up parameters appropriately", {
    batch_size <- 20L
    n_batches <- ceiling(max(lengths(params)) / batch_size)

    batches <- tidyquandl:::batch_parameters(params, batch_size)

    expect_equal(length(batches), n_batches)
    expect_equivalent(lengths(batches), rep(length(params), n_batches))

    batches <- tidyquandl:::batch_parameters(params, 100)

    expect_equal(length(batches), 1L)
    expect_identical(batches, list(params))
    expect_identical(batches, tidyquandl:::batch_parameters(params, NULL))

    batches <- tidyquandl:::batch_parameters(params, max(lengths(params)))

    expect_equal(length(batches), 1L)
    expect_identical(batches, tidyquandl:::batch_parameters(params, NULL))
  })

  it("errors instead of batching over multiple inputs", {
    expect_error(tidyquandl:::batch_parameters(params, 10L), "not yet supported")
  })
})
