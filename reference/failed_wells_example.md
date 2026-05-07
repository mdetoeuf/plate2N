# Example of failed well table

In experiments with 96-well plates, especially with manual pipetting, it
is not rare to have some mishaps where we know that a certain well is to
be excluded. A template for such data can be obtained using
[`failed_wells_template()`](https://mdetoeuf.github.io/plate2N/reference/failed_wells_template.md),
exported (e.g., with
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html))
filled by users and imported (e.g., with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)).

## Usage

``` r
failed_wells_example
```

## Format

A tibble 2 rows and 3 columns (dataset, plate_id and well_id), allowing
unique identification of failed wells

- dataset,plate_id:

  must be the same as in your plate data

- well_id:

  standard well identifiers, concatenation of plate rows (letters from A
  to H) and plate columns (numbers from 1 to 12)
