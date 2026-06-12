# Extraction and Quality Check (QC) of blank values for standard curves

In cases where the blank of the standard curve is not the same as the
blank of the samples, a separate blank correction must happen for both
subsets of the data. Here, each standard curve only has one well
containing the blank value, usually pipetted in row A
(`pipetting_direction = "top_down"`), or in row H
(`pipetting_direction = "bottom_up"`).

## Usage

``` r
extract_std_blank(data, std_def = "Std", pipetting_direction = "top_down")
```

## Arguments

- data:

  A tibble respecting the structure of
  [`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md).
  `data` must have, though not necessarily in that order, the following
  column names: row, column, well_id, unique_well_id, dataset, plate_id,
  map, abs

- std_def:

  A string, defaults with `"Std"`: how data from wells containing the
  standard curve are referred to.

- pipetting_direction:

  Can only be "top_down" (default) or "bottom_up". A top_down pipetting
  means that the curve was pipetted vertically (in a single column of
  the 96-well plate), with the smallest value (blank) in row A and the
  highest value in row H. Conversely, bottom_up pipetting would have the
  blank in row H and the most concentrated solution in row A

## Value

A list of 4 elements characterizing blank wells: - `list$all` contains
all supposed blank values (minimum values from each curve) -
`list$trusted` contains all trusted blank values (minimum values and
wells in the "correct" row (A or H)) - `list$untrusted` contains all
untrusted wells - `list$average` contains a summarized table with a
per-plate computation of average, standard deviation and coefficient of
variation of blank values. Note that a coefficient of variation has
little value when computed on 2 values, especially when the values are
small numbers (typically, blank absorbances are often lower than 0.1)

## Details

`extract_std_blank()` works in a few steps: - First, data corresponding
to wells containing the standard curve is extracted (as defined by
parameter `std_def`) - Second, within this "standard data", for each
dataset, plate and column (= 1 curve), the smallest absorbance value is
extracted. - We then check that the smallest per-curve value is indeed
found in plate row "A" (top_down pipetting) or row "H" (bottom_up
pipetting). - Should that not be the case, those wells are considered
"untrusted" and are removed from the "trusted" blank values. - Per-plate
averages for blank values are then computed

## Examples

``` r
# reconstruct a proper data table to start from
# map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
# abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
# map_tibble <- csv_to_tibble(map_file)
# abs_tibble <- txt_to_tibble(abs_folder)
# joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
# tidy_data <- vertical_to_tidy(joined_vertical)

# check out input table
tidy_plates
#> # A tibble: 480 × 8
#>    row   column well_id unique_well_id dataset plate_id map      abs  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.110
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.113
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167
#> # ℹ 470 more rows

# run the function
std_blank <- tidy_plates |> extract_std_blank(std_def = "Std")
std_blank$all ; std_blank$trusted ; std_blank$untrusted
#> # A tibble: 10 × 8
#> # Groups:   dataset, plate_id, column [10]
#>    well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>    <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#>  1 A1      Nmin    NO3_1F1  A     1      A1_NO3_1F1     NO3_1F1_col1    0.092
#>  2 A1      Nmin    NO3_1F2  A     1      A1_NO3_1F2     NO3_1F2_col1    0.091
#>  3 A1      Nmin    NO3_1F3  A     1      A1_NO3_1F3     NO3_1F3_col1    0.11 
#>  4 A1      Nmin    NO3_1F4  A     1      A1_NO3_1F4     NO3_1F4_col1    0.092
#>  5 A1      Nmin    NO3_1F5  A     1      A1_NO3_1F5     NO3_1F5_col1    0.113
#>  6 A12     Nmin    NO3_1F1  A     12     A12_NO3_1F1    NO3_1F1_col12   0.091
#>  7 A12     Nmin    NO3_1F2  A     12     A12_NO3_1F2    NO3_1F2_col12   0.09 
#>  8 A12     Nmin    NO3_1F3  A     12     A12_NO3_1F3    NO3_1F3_col12   0.09 
#>  9 A12     Nmin    NO3_1F4  A     12     A12_NO3_1F4    NO3_1F4_col12   0.091
#> 10 A12     Nmin    NO3_1F5  A     12     A12_NO3_1F5    NO3_1F5_col12   0.092
#> # A tibble: 8 × 8
#>   well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>   <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#> 1 A1      Nmin    NO3_1F1  A     1      A1_NO3_1F1     NO3_1F1_col1    0.092
#> 2 A1      Nmin    NO3_1F2  A     1      A1_NO3_1F2     NO3_1F2_col1    0.091
#> 3 A1      Nmin    NO3_1F4  A     1      A1_NO3_1F4     NO3_1F4_col1    0.092
#> 4 A12     Nmin    NO3_1F1  A     12     A12_NO3_1F1    NO3_1F1_col12   0.091
#> 5 A12     Nmin    NO3_1F2  A     12     A12_NO3_1F2    NO3_1F2_col12   0.09 
#> 6 A12     Nmin    NO3_1F3  A     12     A12_NO3_1F3    NO3_1F3_col12   0.09 
#> 7 A12     Nmin    NO3_1F4  A     12     A12_NO3_1F4    NO3_1F4_col12   0.091
#> 8 A12     Nmin    NO3_1F5  A     12     A12_NO3_1F5    NO3_1F5_col12   0.092
#> # A tibble: 2 × 8
#> # Groups:   dataset, plate_id, column [2]
#>   well_id dataset plate_id column unique_curve_id row   unique_well_id   abs
#>   <chr>   <chr>   <chr>    <chr>  <chr>           <chr> <chr>          <dbl>
#> 1 A1      Nmin    NO3_1F3  1      NO3_1F3_col1    A     A1_NO3_1F3     0.11 
#> 2 A1      Nmin    NO3_1F5  1      NO3_1F5_col1    A     A1_NO3_1F5     0.113
```
