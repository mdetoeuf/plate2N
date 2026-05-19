# Example of plate metadata

Must-have columns are those detailed here.

## Usage

``` r
metadata
```

## Format

A tibble with 1 row per plate, and an indefinite number of columns

- dataset,plate_id:

  must be the same as in your plate data (dataset manually encoded in
  the import-tidy pipeline)

- std_sp, std_unit, std_conc:

  characterize the standard curve. The format of std_conc, with `.`as a
  digit separator and `-`as a value separator is important.
  Concentration values MUST be in ascending order

## Details

Additional recommended columns are those recording detail on extractant.
This is information that can easily get lost, and is especially relevant
when there are variations within a lab (ex., K2SO4 vs KCl, or extractant
concentration, ...). Here, we propose to record extractant species
(K2SO4), extractant unit (M) and extractant concentration (0.5).

More experimental parameters could be relevant as well (e.g., dilution,
incubation time, sampling time, researcher, machine used,
wavelength,...)

Recording date and time can help to distinguish batch-effects
