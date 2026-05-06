# Merging 2 vertical plates into one

The function `join_abs_map()` was thought to merge absorbance data with
their mapping counterparts, coming from 2 separate import occurrences,
into a single, vertical tibble. It takes profit of the
[`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
function, connected to our
[`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)
function, so that it provides a 2-in-1 feature of verticalizing plates
while joining them.

## Usage

``` r
join_abs_map(
  abs_tibble,
  map_tibble,
  dataset = "",
  abs_map = c("abs-", "map-"),
  coerce_numeric = c(FALSE, FALSE)
)
```

## Arguments

- abs_tibble, map_tibble:

  The first and second tibble (will appear on the left and right,
  respectively). Must have the same structure as `tibble_example`.

- dataset:

  An optional string to be added as a prefix to all column names (from
  both tibbles), with the exception of the first 2 columns describing
  well id ("row" and "column"). It is originally meant to record the
  name of the dataset for later uses.

- abs_map:

  A string vector to add additional prefixes. The default value is set
  to c("abs", "map"), so that the "abs" data (corresponding to argument
  `abs_tibble`) will receive the first prefix, and the "map" data
  (corresponding to argument `map_tibble`) will receive the second
  prefix. Set this to c("", "") to prevent prefix addition.

- coerce_numeric:

  A logical vector to decide whether the function
  [`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md),
  called separately for `abs_tibble` and `map_tibble`, should coerce
  data to become numeric or not. The default value is set to
  `c(FALSE, FALSE)`, so that eventually all data can be pivotted in a
  single column (see later steps in the pipeline).

## Value

A unique verticalized table containing the data from both data sets.

## Details

The first purpose of this function is to join an absorbance tibble and a
mapping tibble, which is how the default setup is organized. Still, it
offers enough flexibility in its parameters to be adapted to the joining
of any 2 tibbles, so long as they fit the proper `tibble_example`-like
structure.

## See also

[`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)

## Examples

``` r
skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
skanit_tibbles <- skanit_to_tibble(skanit_csv)
join_abs_map(skanit_tibbles$abs_tibble, skanit_tibbles$map_tibble)
#> # A tibble: 96 × 22
#>    row   column `abs-M12` `abs-M16` `abs-M17` `abs-M18` `abs-M19` `abs-M20`
#>    <chr> <chr>  <chr>     <chr>     <chr>     <chr>     <chr>     <chr>    
#>  1 A     1      1.4402    1.5789    1.5611    1.7013    1.6865    1.7936   
#>  2 A     2      1.4802    1.5590    1.5946    1.6475    1.6805    1.7742   
#>  3 A     3      1.4380    1.5446    1.5868    1.6804    1.6934    1.7348   
#>  4 A     4      1.4752    1.5414    1.6137    1.6902    1.6825    1.8029   
#>  5 A     5      1.5143    1.6169    1.5939    1.6849    1.5994    1.7709   
#>  6 A     6      1.4927    1.5561    1.5973    1.6939    1.7107    1.7814   
#>  7 A     7      1.5052    1.5608    1.5888    1.6686    1.7196    1.7760   
#>  8 A     8      1.5293    1.5882    1.5836    1.6908    1.6722    1.7262   
#>  9 A     9      1.5301    1.6060    1.6011    1.7069    1.6220    1.8117   
#> 10 A     10     1.5228    1.5773    1.6066    1.6949    1.6794    1.7938   
#> # ℹ 86 more rows
#> # ℹ 14 more variables: `abs-M21` <chr>, `abs-M22` <chr>, `abs-M23` <chr>,
#> #   `abs-M1` <chr>, `map-M12` <chr>, `map-M16` <chr>, `map-M17` <chr>,
#> #   `map-M18` <chr>, `map-M19` <chr>, `map-M20` <chr>, `map-M21` <chr>,
#> #   `map-M22` <chr>, `map-M23` <chr>, `map-M1` <chr>
```
