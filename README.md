
<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyquandl
==========

The goal of tidyquandl is to be an easier-to-use and tidy interfact to the [Quandl](https://www.quandl.com/) API for financial data.

Installation
------------

You can install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ClaytonJY/tidyquandl")
```

Example
-------

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyquandl)

quandl_api_key(Sys.getenv("QUANDL_API_KEY"))

quandl_datatable("WIKI/PRICES", ticker = "AAPL", date.gte = "2018-01-01")
#> # A tibble: 59 x 14
#>    ticker date        open  high   low close   volume `ex-dividend`
#>    <chr>  <date>     <dbl> <dbl> <dbl> <dbl>    <dbl>         <dbl>
#>  1 AAPL   2018-01-02  170.  172.  169.  172. 25048048             0
#>  2 AAPL   2018-01-03  173.  175.  172.  172. 28819653             0
#>  3 AAPL   2018-01-04  173.  173.  172.  173. 22211345             0
#>  4 AAPL   2018-01-05  173.  175.  173.  175  23016177             0
#>  5 AAPL   2018-01-08  174.  176.  174.  174. 20134092             0
#>  6 AAPL   2018-01-09  175.  175.  173.  174. 21262614             0
#>  7 AAPL   2018-01-10  173.  174.  173   174. 23589129             0
#>  8 AAPL   2018-01-11  175.  175.  174.  175. 17523256             0
#>  9 AAPL   2018-01-12  176.  177.  176.  177. 25039531             0
#> 10 AAPL   2018-01-16  178.  179.  176.  176. 29159005             0
#> # ... with 49 more rows, and 6 more variables: split_ratio <chr>,
#> #   adj_open <dbl>, adj_high <dbl>, adj_low <dbl>, adj_close <dbl>,
#> #   adj_volume <chr>
```

Contributing
------------

Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
