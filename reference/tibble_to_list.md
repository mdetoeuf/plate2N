# Converts plates data from tibble to a list

Converts a tibble (as outputted from csv_import() or skanit_to_plate())
containing all plate data into a list of tibbles (1 per plate)

## Usage

``` r
tibble_to_list(tibble)
```

## Arguments

- tibble:

  The tibble containing all plate data. See output from examples under
  ?csv_import for a glimpse of the required tibble structure and column
  names

## Value

A list where each element contains the data of a single plate, and the
name of each element is the plate identifier (plate name). This list
format is the same as the output from txt_import()

## Examples

``` r
tibble <- csv_to_tibble(system.file("extdata", "csv_example.csv", package = "plate2N"))
tibble
#> # A tibble: 36 × 13
#>    row          X1    X2    X3    X4    X5    X6    X7    X8    X9    X10    X11
#>    <chr>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
#>  1 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#>  2 A         0.095 0.537 0.528 0.562 0.51  0.507 0.546 0.078 0.519  0.543  0.521
#>  3 B         0.191 0.541 0.521 0.544 0.507 0.515 0.527 0.078 0.521  0.54   0.521
#>  4 C         0.255 0.551 0.513 0.559 0.505 0.511 0.541 0.078 0.519  0.54   0.514
#>  5 D         0.396 0.54  0.528 0.551 0.507 0.509 0.541 0.078 0.517  0.54   0.515
#>  6 E         0.65  0.979 0.946 1.01  0.926 0.927 0.996 0.078 0.955  0.997  0.936
#>  7 F         1.05  0.981 0.959 1     0.921 0.931 0.99  0.08  0.944  0.975  0.943
#>  8 G         1.83  0.988 0.954 0.994 0.936 0.935 0.995 0.077 0.945  0.995  0.939
#>  9 H         2.45  0.984 0.969 0.991 0.923 0.94  0.99  0.077 0.932  0.986  0.949
#> 10 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#> # ℹ 26 more rows
#> # ℹ 1 more variable: X12 <dbl>
list <- tibble_to_list(tibble)
names(list)[1]; list[[1]]
#> [1] "NO3_TDN_01"
#> # A tibble: 8 × 13
#>   row     `1`   `2`   `3`   `4`   `5`   `6`   `7`   `8`   `9`  `10`  `11`  `12`
#>   <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 A     0.095 0.537 0.528 0.562 0.51  0.507 0.546 0.078 0.519 0.543 0.521 0.605
#> 2 B     0.191 0.541 0.521 0.544 0.507 0.515 0.527 0.078 0.521 0.54  0.521 0.592
#> 3 C     0.255 0.551 0.513 0.559 0.505 0.511 0.541 0.078 0.519 0.54  0.514 0.609
#> 4 D     0.396 0.54  0.528 0.551 0.507 0.509 0.541 0.078 0.517 0.54  0.515 0.6  
#> 5 E     0.65  0.979 0.946 1.01  0.926 0.927 0.996 0.078 0.955 0.997 0.936 1.10 
#> 6 F     1.05  0.981 0.959 1     0.921 0.931 0.99  0.08  0.944 0.975 0.943 1.11 
#> 7 G     1.83  0.988 0.954 0.994 0.936 0.935 0.995 0.077 0.945 0.995 0.939 1.10 
#> 8 H     2.45  0.984 0.969 0.991 0.923 0.94  0.99  0.077 0.932 0.986 0.949 1.09 
names(list)[2]; list[[2]]
#> [1] "NO3_TDN_02"
#> # A tibble: 8 × 13
#>   row     `1`   `2`   `3`   `4`   `5`   `6`   `7`   `8`   `9`  `10`  `11`  `12`
#>   <chr> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 A     0.097 0.552 0.559 0.555 0.538 0.552 0.534 0.079 0.589 0.535 0.536 0.594
#> 2 B     0.19  0.548 0.553 0.544 0.538 0.558 0.539 0.08  0.583 0.537 0.534 0.594
#> 3 C     0.253 0.541 0.556 0.553 0.529 0.552 0.539 0.081 0.575 0.523 0.541 0.603
#> 4 D     0.391 0.543 0.548 0.554 0.545 0.556 0.539 0.08  0.577 0.535 0.534 0.601
#> 5 E     0.625 0.972 1.00  1.01  0.982 1.02  0.977 0.08  1.08  0.96  0.974 1.09 
#> 6 F     1.08  0.978 1.00  1.01  0.987 1.01  0.979 0.081 1.07  0.971 0.96  1.07 
#> 7 G     1.74  0.962 1.01  1.00  0.994 1.02  0.97  0.081 1.08  0.966 0.963 1.09 
#> 8 H     2.34  0.954 1     1.01  0.982 1.02  0.98  0.084 1.06  0.972 0.962 1.07 
```
