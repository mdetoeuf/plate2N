# From vertical plate data to tidy data using the tidyr package

See also
[`vertical_plates`](https://mdetoeuf.github.io/plate2N/reference/vertical_plates.md)
and
[`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md)
to understand input and output data structure

## Usage

``` r
vertical_to_tidy(vertical_data)
```

## Arguments

- vertical_data:

  As generated from either
  [`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)
  or
  [`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md).

## Value

A table in a tidy format for downstream analysis

## Examples

``` r
map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
map_tibble <- csv_to_tibble(map_file)
abs_tibble <- txt_to_tibble(abs_folder)
joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
tidy_data <- vertical_to_tidy(joined_vertical)
```
