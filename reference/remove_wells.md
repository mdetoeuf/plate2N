# Clean a tidy table from undesired wells

This function relies on a very simple use of the
[`dplyr::anti_join()`](https://dplyr.tidyverse.org/reference/filter-joins.html)
function with settings that are particular to our data structure.
However, its iterative use in analysis justifies the definition of an
ad-hoc function.

## Usage

``` r
remove_wells(table_to_clean, well_table, show_msg = TRUE)
```

## Arguments

- table_to_clean, well_table:

  Tibbles with the same structure, respectively, as
  [`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md)
  and
  [`failed_wells_example`](https://mdetoeuf.github.io/plate2N/reference/failed_wells_example.md).
  Column (dataset, plate_id, well_id) must have strictly the same name,
  but the order of columns does not matter. Rows of `well_table`
  uniquely identify wells to be removed

- show_msg:

  Logical (default to TRUE). Whether to show the message (confirmation
  that it worked) or warning (that it failed).

## Value

A cleaned version of the input tidy_table, that should have less rows
than the input table (shortened by the number of rows of `well_table`)

## Examples

``` r
print(tidy_table, n = 10); failed_wells_example
#> # A tibble: 960 × 8
#>    row   column well_id plate_id unique_well_id dataset map     abs   
#>    <chr> <chr>  <chr>   <chr>    <chr>          <chr>   <chr>   <chr> 
#>  1 A     1      A1      M12      A1_M12         expe1   Std0001 1.4402
#>  2 A     1      A1      M16      A1_M16         expe1   Std0097 1.5789
#>  3 A     1      A1      M17      A1_M17         expe1   Std0193 1.5611
#>  4 A     1      A1      M18      A1_M18         expe1   Std0289 1.7013
#>  5 A     1      A1      M19      A1_M19         expe1   Std0385 1.6865
#>  6 A     1      A1      M20      A1_M20         expe1   Std0481 1.7936
#>  7 A     1      A1      M21      A1_M21         expe1   Std0577 1.7925
#>  8 A     1      A1      M22      A1_M22         expe1   Std0673 1.8274
#>  9 A     1      A1      M23      A1_M23         expe1   Std0769 1.9330
#> 10 A     1      A1      M1       A1_M1          expe1   Std0865 0.9254
#> # ℹ 950 more rows
#> # A tibble: 2 × 3
#>   dataset plate_id well_id
#>   <chr>   <chr>    <chr>  
#> 1 expe1   M16      A1     
#> 2 expe1   M23      H12    
tidy_table |> remove_wells(failed_wells_example) |> print(n = 10)
#> # A tibble: 958 × 8
#>    row   column well_id plate_id unique_well_id dataset map     abs   
#>    <chr> <chr>  <chr>   <chr>    <chr>          <chr>   <chr>   <chr> 
#>  1 A     1      A1      M12      A1_M12         expe1   Std0001 1.4402
#>  2 A     1      A1      M17      A1_M17         expe1   Std0193 1.5611
#>  3 A     1      A1      M18      A1_M18         expe1   Std0289 1.7013
#>  4 A     1      A1      M19      A1_M19         expe1   Std0385 1.6865
#>  5 A     1      A1      M20      A1_M20         expe1   Std0481 1.7936
#>  6 A     1      A1      M21      A1_M21         expe1   Std0577 1.7925
#>  7 A     1      A1      M22      A1_M22         expe1   Std0673 1.8274
#>  8 A     1      A1      M23      A1_M23         expe1   Std0769 1.9330
#>  9 A     1      A1      M1       A1_M1          expe1   Std0865 0.9254
#> 10 A     2      A2      M12      A2_M12         expe1   Std0002 1.4802
#> # ℹ 948 more rows
```
