# Import 96-well plate data in csv format

Can be either comma-delimited ("normal csv" = default setting) or
semi-colon delimited ("French version" with commas used for digits and
semi-colons as separators). The format must follow strictly the
following structure, and content can be numerical (e.g., absorbance
data) or strings (e.g., plate mapping):

- plates must be directly on top of each other (no empty rows between
  the plates)

- the first plate must be at the top of the document (no empty row above
  it)

- plates must be at the utmost left of the document (first 13 columns of
  the sheet)

- No data must be recorded beyond plate data (nothing below the plates
  or further right)

- the plate name must be in the first cell (top left) of the plate, just
  above "A", marking the first row of data, and just left of "1",
  marking the first column of data For csv files that do fit neither
  this structure nor the "Skanit" structure (see ?skanit_to_plate for
  more details), an alternative is to use read_csv() or read_csv2 and
  rearrange the resulting tibble to fit the output given here, so that
  it can be inputted in the downstream steps.

## Usage

``` r
csv_to_tibble(filepath, delim = ",")
```

## Arguments

- filepath:

  The path to the file.

- delim:

  Value separator of the .csv document. Default value is ",". ";" is
  also accepted.

## Value

A tibble with the plate data, all plates are still on top of each other
(see examples)

## Examples

``` r
example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
plate_data <- csv_to_tibble(example_csv)
plate_data
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
```
