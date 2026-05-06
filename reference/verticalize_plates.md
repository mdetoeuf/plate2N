# Tidying plate data (verticalization)

`verticalize_plates` brings plate data (absorbance or mapping data) into
a vertical, tidy format. It starts from a tibble in plate format (as
rendered by
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md),
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
and
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)),
and ends with a tidy tibble of 96 rows (row per well) and one column per
plate, as well as structural columns allowing well identification (row,
column)

## Usage

``` r
verticalize_plates(tibble, coerce_numeric = FALSE, prefix = NULL)
```

## Arguments

- tibble:

  The tibble containing the raw plate-formatted data to be tidied.
  tibble must fit the following criteria: - Plate ids **cannot** be a
  single capital letter (e.g., "A", "B", ...) - Plates must be complete
  (96 wells accounted for, set up in 12 columns x 8 rows), but may
  contain NA's - Plate data in the tibble **must be** structured exactly
  as in example files (see also
  [`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md),
  [`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
  or
  [`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)).

- coerce_numeric:

  Whether or not to force data entries to be numerical. The default is
  set to `FALSE`, so that data will be outputted as strings

- prefix:

  Defaults as an empty string. A `prefix` can be added to all column
  names, which can be useful to join tables from distinct datasets

## Value

A tidy tibble (verticalized plate data), with 1 column per plate

## See also

[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md),
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md),
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
that can generate the input needed

## Examples

``` r
# check out input
tibble_example
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
(verticalize_plates(tibble_example))
#> # A tibble: 96 × 6
#>    row   column NO3_TDN_01 NO3_TDN_02 NO3_TDN_03 NO3_TDN_04
#>    <chr> <chr>  <chr>      <chr>      <chr>      <chr>     
#>  1 A     1      0.095      0.097      0.113      0.114     
#>  2 A     2      0.537      0.552      0.53       0.535     
#>  3 A     3      0.528      0.559      0.528      0.534     
#>  4 A     4      0.562      0.555      0.521      0.531     
#>  5 A     5      0.51       0.538      0.521      0.506     
#>  6 A     6      0.507      0.552      0.54       0.551     
#>  7 A     7      0.546      0.534      0.551      0.528     
#>  8 A     8      0.078      0.079      0.097      0.102     
#>  9 A     9      0.519      0.589      0.559      0.541     
#> 10 A     10     0.543      0.535      0.528      0.544     
#> # ℹ 86 more rows
(verticalize_plates(tibble_example, coerce_numeric = TRUE))
#> # A tibble: 96 × 6
#>    row   column NO3_TDN_01 NO3_TDN_02 NO3_TDN_03 NO3_TDN_04
#>    <chr> <chr>       <dbl>      <dbl>      <dbl>      <dbl>
#>  1 A     1           0.095      0.097      0.113      0.114
#>  2 A     2           0.537      0.552      0.53       0.535
#>  3 A     3           0.528      0.559      0.528      0.534
#>  4 A     4           0.562      0.555      0.521      0.531
#>  5 A     5           0.51       0.538      0.521      0.506
#>  6 A     6           0.507      0.552      0.54       0.551
#>  7 A     7           0.546      0.534      0.551      0.528
#>  8 A     8           0.078      0.079      0.097      0.102
#>  9 A     9           0.519      0.589      0.559      0.541
#> 10 A     10          0.543      0.535      0.528      0.544
#> # ℹ 86 more rows
(verticalize_plates(tibble_example, prefix = "prefix_"))
#> # A tibble: 96 × 6
#>    row   column prefix_NO3_TDN_01 prefix_NO3_TDN_02 prefix_NO3_TDN_03
#>    <chr> <chr>  <chr>             <chr>             <chr>            
#>  1 A     1      0.095             0.097             0.113            
#>  2 A     2      0.537             0.552             0.53             
#>  3 A     3      0.528             0.559             0.528            
#>  4 A     4      0.562             0.555             0.521            
#>  5 A     5      0.51              0.538             0.521            
#>  6 A     6      0.507             0.552             0.54             
#>  7 A     7      0.546             0.534             0.551            
#>  8 A     8      0.078             0.079             0.097            
#>  9 A     9      0.519             0.589             0.559            
#> 10 A     10     0.543             0.535             0.528            
#> # ℹ 86 more rows
#> # ℹ 1 more variable: prefix_NO3_TDN_04 <chr>
```
