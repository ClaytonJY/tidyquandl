
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

Quandl::Quandl.api_key(Sys.getenv("QUANDL_API_KEY"))

quandl_datatable("ZACKS/MT", ticker = "AAPL")
#> # A tibble: 1 x 27
#>   m_ticker ticker comp_name comp_name_2 exchange currency_code ticker_type
#>   <chr>    <chr>  <chr>     <chr>       <chr>    <chr>         <chr>      
#> 1 AAPL     AAPL   APPLE INC Apple Inc.  NSDQ     USD           S          
#> # ... with 20 more variables: active_ticker_flag <chr>, comp_url <chr>,
#> #   sic_4_code <dbl>, sic_4_desc <chr>, zacks_x_ind_code <dbl>,
#> #   zacks_x_ind_desc <chr>, zacks_x_sector_code <dbl>,
#> #   zacks_x_sector_desc <chr>, zacks_m_ind_code <dbl>,
#> #   zacks_m_ind_desc <chr>, per_end_month_nbr <dbl>, mr_split_date <date>,
#> #   mr_split_factor <dbl>, comp_cik <chr>, country_code <chr>,
#> #   country_name <chr>, comp_type <dbl>, optionable_flag <chr>,
#> #   sp500_member_flag <chr>, asset_type <chr>
```

Contributing
------------

Please note that this project is released with a [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
