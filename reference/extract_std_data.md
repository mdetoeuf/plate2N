# Keeps only wells corresponding to standard curves

Keeps only wells corresponding to standard curves

## Usage

``` r
extract_std_data(data, std_def = "Std")
```

## Arguments

- data:

  A tibble respecting the structure of
  [`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md).
  `data` must have, though not necessarily in that order, the following
  column names: dataset, map, plate_id, column

- std_def:

  A string, defaults with `"Std"`: how data from wells containing the
  standard curve are referred to.

## Value

A smaller tible than `data`, keeping only rows where the column `map`
contain the value definind standard curve wells (default is
`std_def = "Std"`)

## Examples

``` r
tidy_plates
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
extract_std_data(tidy_plates)
#> # A tibble: 80 × 9
#> # Groups:   dataset, plate_id [5]
#>    row   column well_id unique_well_id dataset plate_id unique_curve_id map  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>           <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  NO3_1F1_col1    Std  
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  NO3_1F2_col1    Std  
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  NO3_1F3_col1    Std  
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  NO3_1F4_col1    Std  
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  NO3_1F5_col1    Std  
#>  6 A     12     A12     A12_NO3_1F1    Nmin    NO3_1F1  NO3_1F1_col12   Std  
#>  7 A     12     A12     A12_NO3_1F2    Nmin    NO3_1F2  NO3_1F2_col12   Std  
#>  8 A     12     A12     A12_NO3_1F3    Nmin    NO3_1F3  NO3_1F3_col12   Std  
#>  9 A     12     A12     A12_NO3_1F4    Nmin    NO3_1F4  NO3_1F4_col12   Std  
#> 10 A     12     A12     A12_NO3_1F5    Nmin    NO3_1F5  NO3_1F5_col12   Std  
#> # ℹ 70 more rows
#> # ℹ 1 more variable: abs <chr>
```
