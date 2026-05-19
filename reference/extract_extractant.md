# Extracting "extractant" data (blank for samples) from plate tidy table

Extracting "extractant" data (blank for samples) from plate tidy table

## Usage

``` r
extract_extractant(data, extr_def = "extr")
```

## Arguments

- data:

  A tibble like `tidy_plates`

- extr_def:

  A string that characterizes wells containing the extractant in the
  mapping (`map`column) of the plate

## Value

A subset of `data`, containing only extractant data

## Examples

``` r
data = tidy_plates
extract_extractant(data)
#> # A tibble: 40 × 8
#>    row   column well_id unique_well_id dataset plate_id map   abs  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr> <chr>
#>  1 A     8      A8      A8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  2 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr  0.083
#>  3 A     8      A8      A8_NO3_1F3     Nmin    NO3_1F3  extr  0.084
#>  4 A     8      A8      A8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#>  5 A     8      A8      A8_NO3_1F5     Nmin    NO3_1F5  extr  0.084
#>  6 B     8      B8      B8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  7 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#>  8 B     8      B8      B8_NO3_1F3     Nmin    NO3_1F3  extr  0.085
#>  9 B     8      B8      B8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 10 B     8      B8      B8_NO3_1F5     Nmin    NO3_1F5  extr  0.084
#> # ℹ 30 more rows
```
