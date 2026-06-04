# Mapping a Vector with Sample ids into 96-well Plate Format - Several Plates

Mapping a Vector with Sample ids into 96-well Plate Format - Several
Plates

## Usage

``` r
map_plates(
  samples,
  n_samples_per_plate = 18,
  plate_ids = NULL,
  std_def = "Std",
  column_curves = c(1, 12),
  blank_def = "extr",
  rename_na = "empty",
  empty_def = "empty",
  column_empty = c(),
  column_blank = 8,
  n_wells_samples = 4
)
```

## Arguments

- samples:

  A vector of strings containing sample names. Samples will be divided
  into plates, and displayed vertically (see examples)

- n_samples_per_plate:

  How many samples should be fitted on a single plate. Defaults to 18,
  which fits the default settings of
  [`map_1_plate()`](https://mdetoeuf.github.io/plate2N/reference/map_1_plate.md).

- plate_ids:

  Optional, a vector of plate_ids to attribute to the plates. Must be
  the fitting length. By default, plate ids will be `plate_1`,
  `plate_2`, etc.

- std_def, column_curves, blank_def, rename_na, empty_def, column_empty,
  column_blank, n_wells_samples:

  These parameters are given to a call to
  [`map_1_plate()`](https://mdetoeuf.github.io/plate2N/reference/map_1_plate.md)
  and follow its logic. See also `?map_1_plate()`.

## Value

A tibble with the plate mapping, in a format similar to
`tibble_example`. This format also fits the import pipeline. See also
the vignette `import-tidy`.

## See also

[`map_1_plate()`](https://mdetoeuf.github.io/plate2N/reference/map_1_plate.md)

## Examples

``` r
# take random fruit names as sample names
samples <- stringr::fruit[1:70] ; samples[1:5]
#> [1] "apple"       "apricot"     "avocado"     "banana"      "bell pepper"
map_plates(samples, 14) |> print(n = 20)
#> # A tibble: 45 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 plat… 1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     Std   apple avoc… bell… blac… bloo… boys… extr  cana… empty empty Std  
#>  3 B     Std   apple avoc… bell… blac… bloo… boys… extr  cana… empty empty Std  
#>  4 C     Std   apple avoc… bell… blac… bloo… boys… extr  cana… empty empty Std  
#>  5 D     Std   apple avoc… bell… blac… bloo… boys… extr  cana… empty empty Std  
#>  6 E     Std   apri… bana… bilb… blac… blue… brea… extr  cant… empty empty Std  
#>  7 F     Std   apri… bana… bilb… blac… blue… brea… extr  cant… empty empty Std  
#>  8 G     Std   apri… bana… bilb… blac… blue… brea… extr  cant… empty empty Std  
#>  9 H     Std   apri… bana… bilb… blac… blue… brea… extr  cant… empty empty Std  
#> 10 plat… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     Std   cher… chil… clou… cran… curr… date  extr  duri… empty empty Std  
#> 12 B     Std   cher… chil… clou… cran… curr… date  extr  duri… empty empty Std  
#> 13 C     Std   cher… chil… clou… cran… curr… date  extr  duri… empty empty Std  
#> 14 D     Std   cher… chil… clou… cran… curr… date  extr  duri… empty empty Std  
#> 15 E     Std   cher… clem… coco… cucu… dams… drag… extr  eggp… empty empty Std  
#> 16 F     Std   cher… clem… coco… cucu… dams… drag… extr  eggp… empty empty Std  
#> 17 G     Std   cher… clem… coco… cucu… dams… drag… extr  eggp… empty empty Std  
#> 18 H     Std   cher… clem… coco… cucu… dams… drag… extr  eggp… empty empty Std  
#> 19 plat… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 20 A     Std   elde… fig   goos… grap… hone… jack… extr  juju… empty empty Std  
#> # ℹ 25 more rows
```
