# Transform Raw Absorbance Data into Blank-corrected Absorbance

Transform Raw Absorbance Data into Blank-corrected Absorbance

## Usage

``` r
blank_correct_abs(
  raw_wells_data,
  per_plate_avg_blank,
  map_to_exclude = c("empty", "Std", "extr")
)
```

## Arguments

- raw_wells_data:

  A tibble, based on `tidy_plates`, can contain metadata as well.
  `raw_wells_data` contains the raw absorbance data to be
  blank-corrected. Must contain columns "abs" and "map".

- per_plate_avg_blank:

  Contains the per-plate average absorbance of the blank Must contain
  column "blank_avg" (rename it prior to function call if needed)

- map_to_exclude:

  A vector of strings containing all `map` definitions of wells that are
  not data per se (e.g., empty wells, etc.). Defaults to
  `c("empty","Std","extr")`. If wells to exclude are not defined by a
  unique "map" (e.g., blank wells of the standard curve), make sure to
  filter out those rows from `raw_wells_data` before the function call.

## Value

A tibble with the blank-corrected absorbance. It has the same structure
as `raw_wells_data`, but the `abs` column has been removed, and column
`abs_corrected` has been added. The output tibble normally contains less
rows than the input tibble (due to `map_to_exclude`)

## Examples

``` r
data <- tidy_plates
extractant_average <- tidy_plates |> extractant_average()
blank_correct_abs(
    raw_wells_data = data,
    per_plate_avg_blank = extractant_average,
    map_to_exclude = c("empty","Std","extr"))
#> Joining with `by = join_by(plate_id)`
#> Joining with `by = join_by(row, column, well_id, unique_well_id, dataset,
#> plate_id, map)`
#> # A tibble: 264 × 10
#>    row   column well_id unique_well_id dataset plate_id map      abs_corrected
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>            <dbl>
#>  1 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2       0.0312 
#>  2 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1      -0.00975
#>  3 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3       0.0104 
#>  4 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1       0.0437 
#>  5 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1       0.0832 
#>  6 A     3      A3      A3_NO3_1F1     Nmin    NO3_1F1  82_t1_z2       0.0452 
#>  7 A     3      A3      A3_NO3_1F2     Nmin    NO3_1F2  98_t1_z1      -0.0128 
#>  8 A     3      A3      A3_NO3_1F3     Nmin    NO3_1F3  90_t1_z3       0.0124 
#>  9 A     3      A3      A3_NO3_1F4     Nmin    NO3_1F4  82_t1_z3       0.0638 
#> 10 A     3      A3      A3_NO3_1F5     Nmin    NO3_1F5  98_t1_z3       0.0232 
#> # ℹ 254 more rows
#> # ℹ 2 more variables: blank_sdev <dbl>, blank_coeff_var_percent <dbl>
```
