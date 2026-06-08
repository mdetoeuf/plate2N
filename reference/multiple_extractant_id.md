# Correspondance Table between Plate Mapping and Extractant ID

Such a table is only needed in the case where several extractants are
found on a single plate. In this case, we need to allocate to each
extractant (e.g, "extr_1", "extr_2") the samples that need
blank-correction from that extractant. This table could, in theory, be
as reduced as 2 columns (one for mapping or `map`, one for extractant or
`extr_id`). However, should the mapping not be unique (e.g., repeated
over several plates), or the extractant bear the same name across
plates, it is prudent to add additional columns to ensure unequivocal
relations between wells and their corresponding blanks, such as
`dataset` and `plate_id`.

## Usage

``` r
multiple_extractant_id
```

## Format

A tibble with one row per well, and the following columns:

- dataset,plate_id:

  allowing the unique identification of the 96-well plate

- map:

  identifier of samples, Standard curve or extractant (“extr_1" or
  "extr_2")

- extr_id:

  extractant identifier corresponding to each well. 3 possible values:
  "extr_1", "extr_2" or "none" (for empty wells or standard curves)
