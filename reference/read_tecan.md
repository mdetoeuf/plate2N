# Import single plate data from a single Tecan-generated file

Import single plate data from a single Tecan-generated file

## Usage

``` r
read_tecan(file, extension = ".xlsx")
```

## Arguments

- file:

  (path to) file to import from

- extension:

  ".xlsx" is currently the only option, but this might change based on
  user needs

## Value

A tibble with a single plate

## Examples

``` r
file <- system.file("extdata", "tecan_example/tecan1.xlsx", package = "plate2N")
read_tecan(file)
#> # A tibble: 9 × 13
#>   row    X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>   <chr>  <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 tecan1 1     2     3     4     5     6     7     8     9     10    11    12   
#> 2 A      0.31… 0.35… 0.501 0.50… 0.47… 0.48… 0.50… 0.53… 0.46… 0.47… 0.49… 0.45…
#> 3 B      0.29… 0.31… 0.48… 0.49… 0.50… 0.5   0.46… 0.53… 0.46… 0.51… 0.45… 0.50…
#> 4 C      0.29… 0.32… 0.46… 0.44… 0.47… 0.50… 0.49… 0.50… 0.44… 0.60… 0.49… 0.45…
#> 5 D      0.27… 0.35… 0.42… 0.44… 0.45… 0.47… 0.47… 0.47… 0.46… 0.49… 0.52… 0.48…
#> 6 E      0.29… 0.32… 0.46… 0.45… 0.42… 0.46… 0.43… 0.46… 0.47… 0.44… 0.52… 0.46…
#> 7 F      0.32… 0.33… 0.46… 0.44… 0.48… 0.44… 0.42… 0.50… 0.49… 0.48… 0.47… 0.47…
#> 8 G      0.63… 0.59… 0.62… 0.61… 0.60… 0.58… 0.46… 0.53… 0.33… 0.29… 0.34… 0.37…
#> 9 H      0.67… 0.63… 0.66… 0.63… 0.62… 0.62… 0.60… 0.62… 0.66… 0.60… 0.64  0.63…
```
