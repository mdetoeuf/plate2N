# Import 96-well plate data from Skanit format

Import 96-well plate data from Skanit format

## Usage

``` r
skanit_to_tibble(skanit_csv, delim = ",", suppress_msg = FALSE)
```

## Arguments

- skanit_csv:

  The csv exported from Skanit (or generated from the first sheet of a
  Skanit Excel) in its raw shape

- delim:

  The value delimiter within the csv file. Default is ",", accepts also
  ";".

- suppress_msg:

  Wether to suppress the message received when `delim` is different than
  = ",". Defaults to `FALSE`.

## Value

A list containing 2 elements. The first, called \$abs_data contains a
tibble with the absorbance data. The second \$map_data contains a tibble
with the mapping data (only relevant if the mapping has been encoded
into skanit. Otherwise: use other functions to import mapping data).

## Examples

``` r
skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
plate_data <- skanit_to_tibble(skanit_csv, delim = ",")
plate_data$abs_tibble
#> # A tibble: 90 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 M12   1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     1.44… 1.48… 1.43… 1.47… 1.51… 1.49… 1.50… 1.52… 1.53… 1.52… 1.51… 1.53…
#>  3 B     1.45… 1.52… 1.50… 1.49… 1.53… 1.56… 1.53… 1.53… 1.53… 1.54… 1.54… 1.54…
#>  4 C     1.51… 1.54… 1.52… 1.53… 1.56… 1.54… 1.56… 1.57… 1.55… 1.55… 1.56… 1.55…
#>  5 D     1.53… 1.55… 1.57… 1.52… 1.54… 1.56… 1.55… 1.56… 1.55… 1.56… 1.55… 1.57…
#>  6 E     1.53… 1.55… 1.55… 1.53… 1.55… 1.55… 1.55… 1.55… 1.58… 1.56… 1.56… 1.55…
#>  7 F     1.52… 1.57… 1.55… 1.53… 1.52… 1.56… 1.57… 1.58… 1.56… 1.55… 1.57… 1.55…
#>  8 G     1.53… 1.55… 1.53… 1.53… 1.56… 1.55… 1.57… 1.55… 1.55… 1.56… 1.56… 1.57…
#>  9 H     1.49… 1.54… 1.52… 1.51… 1.55… 1.55… 1.56… 1.57… 1.53… 1.56… 1.57… 1.58…
#> 10 M16   1     2     3     4     5     6     7     8     9     10    11    12   
#> # ℹ 80 more rows
plate_data$map_tibble
#> # A tibble: 90 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 M12   1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  3 B     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  4 C     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  5 D     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  6 E     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  7 F     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  8 G     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  9 H     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 10 M16   1     2     3     4     5     6     7     8     9     10    11    12   
#> # ℹ 80 more rows
```
