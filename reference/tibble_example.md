# Example of a tibble format for plate data

This particular tibble was generated with the
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)function,
but the end structure is strictly the same with all import options
(e.g., with
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)or
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)).
It contains practise "plate data" to be used within the
`plate2N`package. A tibble (data frame) with 96-well plate data in a
plate format (data can be numerical, e.g., for absorbance data, or
characters, e.g., for mapping data).

## Usage

``` r
tibble_example
```

## Format

A tibble with 13 columns and 9 rows per plate, with no empty rows:

- row:

  column with an iterative structure every 9 rows. The first row of this
  column contains the plate id, the next 8 rows contain letters from A
  to H, reflecting plate rows

- X1:X12:

  containing data from the 12 columns of each plate, where the first row
  of each plate mentions plate-column number, from 1 to 12
