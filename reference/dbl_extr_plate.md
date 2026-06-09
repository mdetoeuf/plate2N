# Tidy Table with 2 different Extractant IDs

This is a modified version of `tidy_plates` where some wells have been
artificially attributed to a second extractant. It serves as example to
test several steps of the vignette `blank-correction` and functions
therein. It has one more column than `tidy_plates` that stores the
information of which well needs to be corrected with which extractant

## Usage

``` r
dbl_extr_plate
```

## Format

A tibble similar to `tidy_plates`, with one row per well, and the
following columns:

- row,column,well_id,unique_well_id,dataset,plate_id:

  allowing the unique identification of each well of the 96-well plate

- map:

  identifier of samples, Standard curve or extractant (“extr_1" or
  "extr_2")

- abs:

  raw absorbance read of each well

- extr_id:

  extractant identifier corresponding to each well. 3 possible values:
  "extr_1", "extr_2" or "none" (for empty wells or standard curves)
