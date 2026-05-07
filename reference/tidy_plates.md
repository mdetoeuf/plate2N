# Example of Tidy table of plate data

The `tidy_table`represents data corresponding to 5 physical 96-well
plates, where absorbance and mapping data are merged (thus containing 10
times the volume of data of 1 plate).

## Usage

``` r
tidy_plates
```

## Format

A tibble with 960 rows (1 per well of the 5x2 data plates) and 8 columns

- row:

  1-letter identifier of the original plate-row (letters A to H)

- column:

  1-number identifier of the original plate-column (numbers 1 to 12)

- well_id:

  concatenation of `row` and `column` (values from A1 to H12). Each
  `well_id` is repeated 10 times (once per data plate)

- plate_id:

  Unique identifier for each physical 96-well plate (thus repeated 2x
  each, corresponding to absorbance and mapping data)

- unique_well_id:

  concatenation of `well_id` and `plate_id`, it identifies uniquely
  every single well

- dataset:

  here, all data comes from a single dataset called "expe1", but the
  information on dataset is added at the merging stage, and could allow
  filtering the `tidy_table` based on dataset

- map:

  mapping data from the 96-well plates. This can contain a sample
  identifier and/or treatment identifier. It reflects strictly the data
  that was imported from the raw data files

- abs:

  absorbance data from the 96-well plates. This, too, corresponds
  strictly to the imported data. Note that absorbance data is still
  stored as a character string. Use
  [`as.double()`](https://rdrr.io/r/base/double.html) or
  [`as.numeric()`](https://rdrr.io/r/base/numeric.html) to turn it into
  numbers

## Details

This tidy table set was generated from raw absorbance data in the .TXT
format, (see the raw file stored at
`system.file("extdata", "txt_examples", package = "plate2N")`). The
mapping data was imported from a .csv format, (see also the raw file
stored at `system.file("extdata", "csv_map.csv", package = "plate2N")`)

The data wrangling pipeline followed steps of the vignette (see
`vignette("import-tidy, package = "plate2N")`), i.e., data was imported
with
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
and
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md),
then absorbance and mapping data were verticalized and merged with
[`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md),
and finally the verticalized plate data was rearranged using
[`vertical_to_tidy()`](https://mdetoeuf.github.io/plate2N/reference/vertical_to_tidy.md).
