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
  be included. **Warning:** the only "." allowed in the filename is the
  one before the TXT extension

- extension:

  The default is ".TXT". This parameter defines the pattern by which
  files to be included will be picked from the folder identified by
  'filepath'.

- output:

  Desired output format. Default is a tibble. Alternative option is a
  list (one element per plate)

## Value

Depends on the output parameter. If `output = "tibble"`, a tibble where
each plate is stacked on top of each other (same format as with
skanit_to_plate()) If `output = "list"`, a list where each element is a
tibble corresponding to raw plate data (1 file –\> 1 plate –\> 1
element). Names of the elements correspond to the names of the files
(without the extension .TXT). A good practice is thus to name the files
as "plate_name.TXT"
