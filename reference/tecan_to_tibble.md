# Import plate data from a Tecan-generated .xlsx file

Import plate data from a Tecan-generated .xlsx file

## Usage

``` r
tecan_to_tibble(folderpath, extension = ".xlsx")
```

## Arguments

- folderpath:

  Path to the folder that contains all .xlsx in the "Tecan" output
  format. Make sure that folder contains only plate data as .xlsx files.
  It may contain other file types, but all .xlsx files will be imported,
  which could lead to errors should the files not present the correct
  structure

- extension:

  For now has only 1 .xlsx option. Should it be relevant to add a csv
  option, please reach out to the authors.

## Value

The plate data in a tibble format

## Examples

``` r
filepath <- system.file("extdata", "tecan_example/", package = "plate2N")
tecan_to_tibble(filepath)
#> # A tibble: 18 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 teca… 1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     0.31… 0.35… 0.501 0.50… 0.47… 0.48… 0.50… 0.53… 0.46… 0.47… 0.49… 0.45…
#>  3 B     0.29… 0.31… 0.48… 0.49… 0.50… 0.5   0.46… 0.53… 0.46… 0.51… 0.45… 0.50…
#>  4 C     0.29… 0.32… 0.46… 0.44… 0.47… 0.50… 0.49… 0.50… 0.44… 0.60… 0.49… 0.45…
#>  5 D     0.27… 0.35… 0.42… 0.44… 0.45… 0.47… 0.47… 0.47… 0.46… 0.49… 0.52… 0.48…
#>  6 E     0.29… 0.32… 0.46… 0.45… 0.42… 0.46… 0.43… 0.46… 0.47… 0.44… 0.52… 0.46…
#>  7 F     0.32… 0.33… 0.46… 0.44… 0.48… 0.44… 0.42… 0.50… 0.49… 0.48… 0.47… 0.47…
#>  8 G     0.63… 0.59… 0.62… 0.61… 0.60… 0.58… 0.46… 0.53… 0.33… 0.29… 0.34… 0.37…
#>  9 H     0.67… 0.63… 0.66… 0.63… 0.62… 0.62… 0.60… 0.62… 0.66… 0.60… 0.64  0.63…
#> 10 teca… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     0.31… 0.35… 0.501 0.50… 0.47… 0.48… 0.50… 0.53… 0.46… 0.47… 0.49… 0.45…
#> 12 B     0.29… 0.31… 0.48… 0.49… 0.50… 0.5   0.46… 0.53… 0.46… 0.51… 0.45… 0.50…
#> 13 C     0.29… 0.32… 0.46… 0.44… 0.47… 0.50… 0.49… 0.50… 0.44… 0.60… 0.49… 0.45…
#> 14 D     0.27… 0.35… 0.42… 0.44… 0.45… 0.47… 0.47… 0.47… 0.46… 0.49… 0.52… 0.48…
#> 15 E     0.29… 0.32… 0.46… 0.45… 0.42… 0.46… 0.43… 0.46… 0.47… 0.44… 0.52… 0.46…
#> 16 F     0.32… 0.33… 0.46… 0.44… 0.48… 0.44… 0.42… 0.50… 0.49… 0.48… 0.47… 0.47…
#> 17 G     0.63… 0.59… 0.62… 0.61… 0.60… 0.58… 0.46… 0.53… 0.33… 0.29… 0.34… 0.37…
#> 18 H     0.67… 0.63… 0.66… 0.63… 0.62… 0.62… 0.60… 0.62… 0.66… 0.60… 0.64  0.63…
```
