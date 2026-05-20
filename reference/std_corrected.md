# Example of Blank-corrected Data for Standard Curve

Example of Blank-corrected Data for Standard Curve

## Usage

``` r
std_corrected
```

## Format

A tibble with 1 row per well containing serial dilutions of the standard
curve. Most relevant columns are described here

- row, column, well_id, plate_id, dataset:

  of the 96-well plate

- unique_curve_id:

  relevant when there are several curves per plate

- unique_well_id:

  combination of well_id and plate_id

- map:

  mapping og the wells ("Std" in this case)

- abs_corrected:

  blank-corrected absorbance value. Note that the `abs` column has been
  removed to avoid inadvertend use of uncorrected data

- map:

  mapping og the wells ("Std" in this case)

- map:

  mapping og the wells ("Std" in this case)

- std_sp, std_unit, std_conc:

  characterize the species, concentration and unit of the standard
  solution in that well
