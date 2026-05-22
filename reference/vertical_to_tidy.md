# From vertical plate data to tidy data using the tidyr package

See also
[`vertical_plates`](https://mdetoeuf.github.io/plate2N/reference/vertical_plates.md)
and
[`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md)
to understand input and output data structure

## Usage

``` r
vertical_to_tidy(vertical_data, abs_def = "abs", map_def = "map")
```

## Arguments

- vertical_data:

  As generated from either
  [`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)
  or
  [`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md).

- abs_def, map_def:

  Strings defining the 2 types of data to be recovered. They correspond
  to the prefixes added to column names in a previous step with
  [`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md)
  (default "abs" and "map", respectively). `abs_def` and `map_def` also
  define column names in the output table

## Value

A table in a tidy format for downstream analysis

## Examples

``` r
map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
map_tibble <- csv_to_tibble(map_file)
abs_tibble <- txt_to_tibble(abs_folder)
joined_vertical <- join_abs_map(
    abs_tibble, map_tibble,
    dataset = "Nmin-", abs_map = c("abs-", "map-"))
(tidy_data <- vertical_to_tidy(joined_vertical, abs_def = "abs", map_def = "map"))
#> # A tibble: 480 × 8
#>    row   column well_id unique_well_id dataset plate_id map      abs  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.093
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.092
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167
#> # ℹ 470 more rows
```
