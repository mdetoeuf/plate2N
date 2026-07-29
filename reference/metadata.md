# Example of plate metadata

metadata is an example data set of the package plate2N. Must-have
columns are those detailed here. Additional recommanded columns are
those recording detail on extractant. This is information that can
easily get lost, and is especially relevant when there are variations
within a lab (ex., K2SO4 vs KCl, or extractant concentration, ...).
Here, we propose to record extractant species (K2SO4), extractant
concentration (0.5) and unit (M).

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

More experimental parameters could be relevant as well, anything that is
valid on a per-plate basis (e.g., dilution, incubation time, sampling
time, researcher, machine used, wavelength,...)

Recording date and time can help to distinguish batch-effects

You can create your own metadata as a csv and import it using a family
of import functions from the readr package (e.g.,
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
or
[`readr::read_csv2()`](https://readr.tidyverse.org/reference/read_delim.html)).
