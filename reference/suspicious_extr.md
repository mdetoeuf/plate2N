# Review suspicious extractant values and spot outliers

Review suspicious extractant values and spot outliers

## Usage

``` r
suspicious_extr(data, suspicious_plate_id = NULL, max_coeff = 5)
```

## Arguments

- data:

  Tibble formatted as `tidy_plates`

- suspicious_plate_id:

  If NULL (default), computed from `data` with
  `qc_raw_extr(data, max_coeff = max_coeff)`

- max_coeff:

  User-defined threshold value, defaults at 5%. All plates for which the
  coefficient of variation for extractant raw absorbance is above this
  threshold will be considered "suspicious plates"

## Value

A list with 2 elements. `$suspicious_extractant`, a subset of `data`
containing only plates where raw extractant values should be reviewed
`$multiple_plot`, a collection of distributions of those raw absorbance
values, to help spotting outlier wells

## Examples

``` r
data <- tidy_plates
# 0.5 is unreasonable in most uses, but is used here to ensure some output
suspicious_extr <- suspicious_extr(data, max_coeff = 0.5)
#> Warning: There is a big variation in absorbance values for the blanc (more than 0.5%).
#>         Remove the most unlikely values / remove outliers manually.
#>         Suspicious plate ID's are returned
suspicious_extr$suspicious_extractant
#> # A tibble: 40 × 8
#> # Groups:   plate_id, map [5]
#>    row   column well_id unique_well_id dataset plate_id map     abs
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr> <dbl>
#>  1 A     8      A8      A8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  2 B     8      B8      B8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  3 C     8      C8      C8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  4 D     8      D8      D8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  5 E     8      E8      E8_NO3_1F1     Nmin    NO3_1F1  extr  0.082
#>  6 F     8      F8      F8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  7 G     8      G8      G8_NO3_1F1     Nmin    NO3_1F1  extr  0.082
#>  8 H     8      H8      H8_NO3_1F1     Nmin    NO3_1F1  extr  0.083
#>  9 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr  0.083
#> 10 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#> # ℹ 30 more rows
suspicious_extr$multiple_plot
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.
#> `stat_bin()` using `bins = 30`. Pick better value `binwidth`.

```
