# Import 96-well plate data from Skanit format

Import 96-well plate data from Skanit format

## Usage

``` r
skanit_to_tibble(skanit_csv, delim = ",")
```

## Arguments

- skanit_csv:

  The csv exported from Skanit (or generated from the first sheet of a
  Skanit Excel) in its raw shape

- delim:

  The value delimiter within the csv file. Default is ",", accepts also
  ";".

## Value

A list containing 2 elements. The first, called \$abs_data contains a
tibble with the absorbance data. The second \$map_data contains a tibble
with the mapping data (only relevant if the mapping has been encoded
into skanit. Otherwise: use other functions to import mapping data).

## Examples

``` r
skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
plate_data <- skanit_to_tibble(skanit_csv, delim = ",")
plate_data$abs_data
#> NULL
plate_data$map_data
#> NULL
```
