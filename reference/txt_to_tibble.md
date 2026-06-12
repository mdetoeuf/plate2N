# Imports 96-well plate data from .TXT format as exported from the plate reader

Imports 96-well plate data from .TXT format as exported from the plate
reader

## Usage

``` r
txt_to_tibble(filepath, extension = ".TXT", output = "tibble")
```

## Arguments

- filepath:

  The path to the folder containing the .TXT files. The folder may
  contain other non-TXT files, but all .TXT files within the folder will
  be included.

- extension:

  The default is ".TXT". This parameter defines the pattern by which
  files to be included will be picked from the folder identified by
  'filepath'.

- output:

  Desired output format. Default "tibble." Alternative option is a list
  (one element of the list attributed to each plate)

## Value

Depends on the output parameter. If `output = "tibble"`, a tibble where
each plate is stacked on top of each other (same format as with
skanit_to_plate()) If `output = "list"`, a list where each element is a
tibble corresponding to raw plate data (1 file –\> 1 plate –\> 1
element). Names of the elements correspond to the names of the files
(without the extension .TXT). A good practice is thus to name the files
as "plate_name.TXT"

## Examples

``` r
filepath <- system.file("extdata", "txt_examples/", package = "plate2N")
abs_tibble <- txt_to_tibble(filepath)
```
