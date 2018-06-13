context("Test utility functions")

describe("batch_params", {
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
