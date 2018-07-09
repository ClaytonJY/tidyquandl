context("Test setting and getting API keys")

describe("quandl_key_get()", {

  it("errors when no key is set", {
    expect_error(tidyquandl:::quandl_key_get())
  })
})

describe("quandl_key_set()", {

  it("returns set value, invisbly", {
    expect_identical(quandl_key_set("foobar"), "foobar")
  })

  it("validates input", {
    expect_error(quandl_key_set(1))
  })

  it("sets what is passed in", {
    expect_identical(tidyquandl:::quandl_key_get(), "foobar")
  })

  it("can set key from environment variable", {
    quandl_key_set()
    expect_identical(tidyquandl:::quandl_key_get(), Sys.getenv("QUANDL_API_KEY"))
  })

  it("is compatible with Quandl package", {
    expect_identical(tidyquandl:::quandl_key_get(), Quandl::Quandl.api_key())
  })
})
