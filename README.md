
<!-- README.md is generated from README.Rmd. Please edit that file -->
`tidyquandl`
============

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://tidyverse.org/lifecycle/#experimental)

The goal of `tidyquandl` is to be an easy-to-use and tidy interface to the [Quandl](https://www.quandl.com/) API for financial data.

Unlike the `Quandl` package provided by the Quandl team, `tidyquandl` - always returns tibbles - always fetched all results (`paginate = TRUE`) - automatically retries failed queries - automatically splits large queries into manageable ones (batching)

Currently, it has just two user-facing functions: `quandl_api_key` and `quandl_datatable`. More will be added in the future, but the focus will remain on the Tables API rather than the Timeseries API

The main function, `quandl_datatable`, currently wraps `Quandl::Quandl.datatable`; in the future this will be rewritten to allow for better behavior, such as proper error parsing, only retrying after specific error codes, etc.

Installation
------------

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ClaytonJY/tidyquandl")
```

Usage
-----

Before doing anything with the Quandl API, you'll need an account; you can register for free at [Quandl](https://www.quandl.com/), and all examples use free datasets available to all registered users.

Then you need to obtain your API key (a string) from your account settings; here we assume it's stored in the "QUANDL\_API\_KEY" environment variable. In the future, we may support storing this in your system's credential store via the `keyring` package.

``` r
library(tidyquandl)

quandl_api_key(Sys.getenv("QUANDL_API_KEY"))
```

Now we can call `quandl_datatable` to interact with the Tables API. Here we use the [Wiki Prices database](https://www.quandl.com/databases/WIKIP) to get one day of prices on Apple and Microsoft:

``` r
quandl_datatable("WIKI/PRICES", ticker = c("AAPL", "MSFT"), date = "2018-01-02")
#> # A tibble: 2 x 14
#>   ticker date        open  high   low close   volume `ex-dividend`
#>   <chr>  <date>     <dbl> <dbl> <dbl> <dbl>    <dbl>         <dbl>
#> 1 AAPL   2018-01-02 170.  172.  169.  172.  25048048             0
#> 2 MSFT   2018-01-02  86.1  86.3  85.5  86.0 21993101             0
#> # ... with 6 more variables: split_ratio <chr>, adj_open <dbl>,
#> #   adj_high <dbl>, adj_low <dbl>, adj_close <dbl>, adj_volume <chr>
```

Unlike `Quandl::Quandl.datatable`, if an error is received the query will be retried (this can be controlled by the `max_attempts` and `delay` args). It can also accept an unlimited number of `tickers`: behind the scenes, multiple queries will be made to avoid errors from Quandl for having too many parameters.

You can pass in any of the arguments you're used to passing into `Quandl::Quandl.datatable` via the `...` args. Here we get only the closing prices for Apple over the span of a week.

``` r
quandl_datatable(
  "WIKI/PRICES",
  ticker = "AAPL",
  date.gte = "2018-01-01", date.lt = "2018-01-15",
  qopts.columns = c("ticker", "date", "close")
)
#> # A tibble: 9 x 3
#>   ticker date       close
#>   <chr>  <date>     <dbl>
#> 1 AAPL   2018-01-02  172.
#> 2 AAPL   2018-01-03  172.
#> 3 AAPL   2018-01-04  173.
#> 4 AAPL   2018-01-05  175 
#> 5 AAPL   2018-01-08  174.
#> 6 AAPL   2018-01-09  174.
#> 7 AAPL   2018-01-10  174.
#> 8 AAPL   2018-01-11  175.
#> 9 AAPL   2018-01-12  177.
```

Contributing
------------

Your contributions are welcome! Issues, typo fixes, new functions; I'm up for anything. There is a boilerplate `CONTRIBUTING.md` worth reading, though it will be eventually updated to be more specific to this package and my workflow.

Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
