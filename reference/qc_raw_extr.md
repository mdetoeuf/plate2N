# Quality check of raw absorbance data for extractant wells

Extracts plate ID's where it is suspected that raw absorbance data for
extractant (sample blank) still contain some outliers. The criterion for
a plate to be deemed "suspicious" is defined by max_coeff

## Usage

``` r
qc_raw_extr(
  data = NULL,
  extractant_average = NULL,
  extr_def = "extr",
  max_coeff = 5,
  suppress_message = FALSE,
  suppress_warning = FALSE
)
```

## Arguments

- data:

  A tibble, as in `tidy_plates`, optional. It is only used if argument
  `extractant_data` is `NULL` to compute it with
  [`extractant_average()`](https://mdetoeuf.github.io/plate2N/reference/extractant_average.md)
  and the argument `extr_def`.

- extractant_average:

  Defaults to NULL, where it is computed from `data` using
  `extractant_average(data)`

- extr_def:

  Optional: is needed to compute `extractant_average` if needed.
  Defaults to "extr"

- max_coeff:

  User-defined, in % (defaults at 5): determines the threshold
  coefficient of variation for raw absorbance of extractant wells, above
  which plates will be considered "suspicious"

- suppress_message:

  Logical, whether or not to suppress the "success" message (given when
  no plate is above the `max_coeff`)

- suppress_warning:

  Logical, whether or not to suppress the warning (given when some plate
  are above the `max_coeff`)

## Value

ID's of suspicious plates. (+ a message or warning if not suppressed)

## Details

`qc_raw_extr()` is not yet optimized for the case where there are 2
exractant: it works, but it returns a list of problematic plates without
telling which extractant is problematic on that plate

## Examples

``` r
# example code
data <- tidy_plates
extractant_average <- tidy_plates |> extractant_average()
(suspicious_plate_id <- qc_raw_extr(data, max_coeff = 5))
#> Warning: 
#>         There is a big variation in absorbance values for the blank (more than 5%).
#>         Remove the most unlikely values / remove outliers manually.
#>         Suspicious plate ID's are returned
#> # A tibble: 2 × 2
#>   plate_id map  
#>   <chr>    <chr>
#> 1 NO3_1F2  extr 
#> 2 NO3_1F4  extr 

# example with 2 extractants
dbl_extr_plate
#> # A tibble: 480 × 9
#>    row   column well_id unique_well_id dataset plate_id map      abs   extr_id
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr> <chr>  
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092 none   
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091 none   
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.110 none   
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092 none   
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.113 none   
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114 extr_1 
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107 extr_2 
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095 extr_2 
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118 extr_1 
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167 extr_2 
#> # ℹ 470 more rows
(suspicious_extr_per_plate <- qc_raw_extr(
    dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
    max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE))
#> # A tibble: 5 × 2
#>   plate_id map   
#>   <chr>    <chr> 
#> 1 NO3_1F2  extr_1
#> 2 NO3_1F4  extr_1
#> 3 NO3_1F1  extr_2
#> 4 NO3_1F2  extr_2
#> 5 NO3_1F5  extr_2

```
