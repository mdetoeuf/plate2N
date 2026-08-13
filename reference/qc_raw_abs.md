# Quality Check (QC) of raw absorbance data

`qc_raw_abs()` extracts data relating to wells for which the absorbance
is outside of a user-defined range. Whereas there is a long-lasting
tradition of setting "acceptable" absorbance values between 0.1 and 1
(default values for this function), in reality, the acceptable range
will depend on experiment, usage and quality of the spectrophotomer.
Note that values lower than 0.1 are not rare, especially for blank and
lower values in the standard curve.

## Usage

``` r
qc_raw_abs(
  data,
  value_col = "abs",
  map_col = "map",
  dataset_col = "dataset",
  plate_id_col = "plate_id",
  well_id_col = "well_id",
  min_abs = 0.1,
  max_abs = 1,
  empty_wells = "empty",
  show_msg = TRUE,
  show_warning = TRUE,
  show_plot = TRUE,
  plot_binwidth = 0.01,
  plot_col_facet = "dataset",
  export_plot = NULL
)
```

## Arguments

- data:

  Tibble, in a similar form to our
  [`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md).
  In particular, the columns referenced by `map_col`, `value_col`,
  `dataset_col`, `plate_id_col`, and `well_id_col` must be present.

- value_col:

  Name of the column containing absorbance (or another numeric value
  you'd like to QC). Defaults to `"abs"`.

- map_col:

  Name of the column containing well mapping/type information, used to
  identify empty wells. Defaults to `"map"`.

- dataset_col, plate_id_col, well_id_col:

  Names of the columns identifying dataset, plate, and well — used to
  report which wells are suspicious. Default to `"dataset"`,
  `"plate_id"`, and `"well_id"` respectively.

- min_abs, max_abs:

  Lowest and highest accepted value for absorbance, default at 0.1 and
  1, respectively.

- empty_wells:

  Character string corresponding to how empty wells are described in the
  plate mapping. Defaults to "empty", can also be a vector containing
  several values. Note that wells described as `NA` in the map column
  will also be ignored.

- show_msg, show_warning:

  Whether to keep (TRUE) or suppress (FALSE) the message or warning that
  are returned in the case of absence (message) or presence (warning) of
  suspicious, out-of-range, wells

- show_plot:

  Whether to display the associated plot (histogram of absorbance
  values). Default is `TRUE`. Note that the next arguments are only
  relevant is `show_plot = TRUE`.

- plot_binwidth:

  To set the binwidth of the histogram. Default is 0.01

- plot_col_facet:

  Which column to use to facet the plots. For no facetting, use `NULL`
  (the legacy `"none"` string is still accepted too, for backward
  compatibility). Defaults to `"dataset"`. (For now, only facet with 1
  axis is possible)

- export_plot:

  Defaults to null. Set it to a string to save the plot in the global
  environment, the string will name the object (e.g.,
  `export_plot = "abs_distrib"` will save an object called
  `abs_distrib`)

## Value

A table with 5 columns. The first 3 (dataset, plate_id, well_id) allow
the unique identification of suspicious wells and can be used to run
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md).
The next 2 columns (map, abs) allow further visualization of those
suspicious wells

## Examples

``` r
# bring some NA (abs) and empty wells in tidy_table to check that those wells are removed
data <- tidy_plates
data$abs[1] <- NA
data$map[2] <- "empty"
qc_raw_abs(data)
#> Warning: 160 wells out of 382 are out of range for absorbance, i.e., not in the set boundaries of [0.1; 1]. 
#> See table to identify suspicious wells. 

#> # A tibble: 160 × 5
#>    dataset plate_id well_id map       abs  
#>    <chr>   <chr>    <chr>   <chr>     <chr>
#>  1 Nmin    NO3_1F4  A1      Std       0.092
#>  2 Nmin    NO3_1F3  A2      89_t1_z3  0.095
#>  3 Nmin    NO3_1F3  A3      90_t1_z3  0.097
#>  4 Nmin    NO3_1F2  A4      99_t1_z1  0.093
#>  5 Nmin    NO3_1F3  A5      92_t1_z2  0.094
#>  6 Nmin    NO3_1F4  A5      84_t1_z2  0.098
#>  7 Nmin    NO3_1F5  A5      100_t1_z2 0.093
#>  8 Nmin    NO3_1F3  A6      93_t1_z2  0.093
#>  9 Nmin    NO3_1F3  A7      94_t1_z3  0.099
#> 10 Nmin    NO3_1F1  A8      extr      0.083
#> # ℹ 150 more rows

# facetting the histogram: split by any column with a few distinct
# values. Here we create artificial groups just to illustrate.
data_grouped <- tidy_plates |>
  dplyr::mutate(dataset = rep(c("A", "B", "C"), length.out = dplyr::n()))
qc_raw_abs(data_grouped, plot_col_facet = "dataset")
#> Warning: 162 wells out of 384 are out of range for absorbance, i.e., not in the set boundaries of [0.1; 1]. 
#> See table to identify suspicious wells. 

#> # A tibble: 162 × 5
#>    dataset plate_id well_id map       abs  
#>    <chr>   <chr>    <chr>   <chr>     <chr>
#>  1 A       NO3_1F1  A1      Std       0.092
#>  2 B       NO3_1F2  A1      Std       0.091
#>  3 A       NO3_1F4  A1      Std       0.092
#>  4 B       NO3_1F3  A2      89_t1_z3  0.095
#>  5 A       NO3_1F3  A3      90_t1_z3  0.097
#>  6 B       NO3_1F2  A4      99_t1_z1  0.093
#>  7 B       NO3_1F3  A5      92_t1_z2  0.094
#>  8 C       NO3_1F4  A5      84_t1_z2  0.098
#>  9 A       NO3_1F5  A5      100_t1_z2 0.093
#> 10 A       NO3_1F3  A6      93_t1_z2  0.093
#> # ℹ 152 more rows
```
