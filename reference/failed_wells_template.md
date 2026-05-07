# Generate a template to record "failed wells"

In experiments with 96-well plates, especially with manual pipetting, it
is not rare to have some mishaps where we know that a certain well is to
be excluded. The template generated here, once filled by the user with
data allowing the identification of failed wells, will allow the
automated exclusion of those wells from data analysis. The template can
then easily be exported, for example with
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)
or
[`readr::write_excel_csv()`](https://readr.tidyverse.org/reference/write_delim.html).

## Usage

``` r
failed_wells_template(nrow = 30)
```

## Arguments

- nrow:

  The desired number of rows. Defaults at `nrow = 30`. Note that if data
  is encoded in an Excel or equivalent file, the number of rows is not
  really important and can be increased indefinitely

## Value

A simple tibble with `nrow` rows and 3 columns: dataset, plate_id and
well_id.

## Examples

``` r
failed_wells_template()
#> # A tibble: 30 × 3
#>    dataset plate_id well_id
#>    <chr>   <chr>    <chr>  
#>  1 ""      ""       ""     
#>  2 ""      ""       ""     
#>  3 ""      ""       ""     
#>  4 ""      ""       ""     
#>  5 ""      ""       ""     
#>  6 ""      ""       ""     
#>  7 ""      ""       ""     
#>  8 ""      ""       ""     
#>  9 ""      ""       ""     
#> 10 ""      ""       ""     
#> # ℹ 20 more rows
```
