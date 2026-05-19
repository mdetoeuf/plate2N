# Get concentration of standard curve from metadata

Get concentration of standard curve from metadata

## Usage

``` r
extract_curve(metadata, pipetting_direction = "top_down")
```

## Arguments

- metadata:

  A tibble following a similar structure as
  [`metadata`](https://mdetoeuf.github.io/plate2N/reference/metadata.md),
  see documentation of \`metadata for more details

- pipetting_direction:

  Can only be "top_down" (default) or "bottom_up". A top_down pipetting
  means that the curve was pipetted vertically (in a single column of
  the 96-well plate), with the smallest value (blank) in row A and the
  highest value in row H. Conversely, bottom_up pipetting would have the
  blank in row H and the most concentrated solution in row A

## Value

A tibble with 3 columns: `plate_id`, `row` (corresponding to plate-row,
from A to H) and `std_conc` containing the concentrations as given in
the `std_conc` column of `metadata`.

## See also

[metadata](https://mdetoeuf.github.io/plate2N/reference/metadata.md)

## Examples

``` r
metadata
#> # A tibble: 5 × 16
#>   plate_id date  time  sampling_time std_column std_sp std_unit    std_prep
#>   <chr>    <lgl> <lgl> <chr>         <chr>      <chr>  <chr>       <chr>   
#> 1 NO3_1F1  NA    NA    t1            1-12       NO3    mg NO3- L-1 H2O     
#> 2 NO3_1F2  NA    NA    t1            1-12       NO3    mg NO3- L-1 H2O     
#> 3 NO3_1F3  NA    NA    t1            1-12       NO3    mg NO3- L-1 H2O     
#> 4 NO3_1F4  NA    NA    t1            1-12       NO3    mg NO3- L-1 H2O     
#> 5 NO3_1F5  NA    NA    t1            1-12       NO3    mg NO3- L-1 H2O     
#> # ℹ 8 more variables: std_conc <chr>, sample_dilution <chr>,
#> #   extractant_column <lgl>, extractant_sp <chr>, extractant_unit <chr>,
#> #   extractant_conc <dbl>, empty_column <lgl>, wait_min <chr>
extract_curve(metadata)
#> # A tibble: 40 × 3
#>    plate_id row   std_conc
#>    <chr>    <chr> <chr>   
#>  1 NO3_1F1  A     0       
#>  2 NO3_1F1  B     0.5     
#>  3 NO3_1F1  C     1       
#>  4 NO3_1F1  D     2       
#>  5 NO3_1F1  E     4       
#>  6 NO3_1F1  F     8       
#>  7 NO3_1F1  G     16      
#>  8 NO3_1F1  H     24      
#>  9 NO3_1F2  A     0       
#> 10 NO3_1F2  B     0.5     
#> # ℹ 30 more rows
```
