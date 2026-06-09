# Extract suspicious extractant wells

Extract suspicious extractant wells

## Usage

``` r
suspicious_extr(
  data,
  extr_def = "extr",
  suspicious_extr_per_plate = NULL,
  max_coeff = 5
)
```

## Arguments

- data:

  A tibble, as in `tidy_plates`.

- extr_def:

  Needed to compute `extractant_average`. Defaults to "extr"

- suspicious_extr_per_plate:

  If NULL (default), computed from `data` with
  `qc_raw_extr(data, max_coeff = max_coeff)`. Should be a tibble with 2
  columns: `plate_id` and `map`

- max_coeff:

  User-defined threshold value, defaults at 5%. All plates for which the
  coefficient of variation for extractant raw absorbance is above this
  threshold will be considered "suspicious plates"

## Value

A subset of `data` containing only plates where raw extractant values
should be reviewed (because their coefficient of variation is above the
user-defined threshold)

## Examples

``` r
data <- tidy_plates
# 0.5 is unreasonable in most uses, but is used here to ensure some output
suspicious_plate_id <- qc_raw_extr(data, max_coeff = 5,
    suppress_message = TRUE, suppress_warning = TRUE)
(suspicious_extr <- suspicious_extr(data, max_coeff = 0.5,
    suspicious_extr_per_plate = suspicious_plate_id))
#> Joining with `by = join_by(plate_id, map)`
#> # A tibble: 16 × 8
#>    row   column well_id unique_well_id dataset plate_id map     abs
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr> <dbl>
#>  1 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr  0.083
#>  2 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#>  3 C     8      C8      C8_NO3_1F2     Nmin    NO3_1F2  extr  0.25 
#>  4 D     8      D8      D8_NO3_1F2     Nmin    NO3_1F2  extr  0.19 
#>  5 E     8      E8      E8_NO3_1F2     Nmin    NO3_1F2  extr  0.083
#>  6 F     8      F8      F8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#>  7 G     8      G8      G8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#>  8 H     8      H8      H8_NO3_1F2     Nmin    NO3_1F2  extr  0.082
#>  9 A     8      A8      A8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 10 B     8      B8      B8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 11 C     8      C8      C8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 12 D     8      D8      D8_NO3_1F4     Nmin    NO3_1F4  extr  0.083
#> 13 E     8      E8      E8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 14 F     8      F8      F8_NO3_1F4     Nmin    NO3_1F4  extr  0.008
#> 15 G     8      G8      G8_NO3_1F4     Nmin    NO3_1F4  extr  0.084
#> 16 H     8      H8      H8_NO3_1F4     Nmin    NO3_1F4  extr  0.083

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
(suspicious_extr <- suspicious_extr(
    dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
    max_coeff = 5, suspicious_extr_per_plate = suspicious_extr_per_plate))
#> Joining with `by = join_by(plate_id, map)`
#> # A tibble: 40 × 9
#>    row   column well_id unique_well_id dataset plate_id map      abs extr_id
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>  <dbl> <chr>  
#>  1 A     4      A4      A4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.11  extr_2 
#>  2 B     4      B4      B4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.109 extr_2 
#>  3 C     4      C4      C4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.11  extr_2 
#>  4 D     4      D4      D4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.109 extr_2 
#>  5 E     4      E4      E4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.092 extr_2 
#>  6 F     4      F4      F4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.093 extr_2 
#>  7 G     4      G4      G4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.093 extr_2 
#>  8 H     4      H4      H4_NO3_1F1     Nmin    NO3_1F1  extr_2 0.092 extr_2 
#>  9 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr_1 0.083 extr_1 
#> 10 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr_1 0.082 extr_1 
#> # ℹ 30 more rows
```
