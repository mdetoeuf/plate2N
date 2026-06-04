# prepare_plates

``` r

library(plate2N)
```

> **Work in progress**
>
> This vignette is still under development, bugs are to be expected

## 1 - Introduction

Functions introduced in this vignette are mostly helpful in a
preparation step, before going to the lab and running the absorbance
readings in the 96-well plate reader.

## 2 - Mapping samples to plate(s)

[`map_1_plate()`](https://mdetoeuf.github.io/plate2N/reference/map_1_plate.md)
takes a single plate_id and a vector containing sample names and returns
a mapped plate format where the plate id is in the upper left corner.

``` r

(samples <- sample(LETTERS, size = 15))
#>  [1] "G" "P" "X" "L" "T" "E" "W" "B" "N" "Z" "S" "H" "M" "O" "V"
map_1_plate(plate_id = "test_plate", samples = samples)
#> # A tibble: 9 × 13
#>   row    X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>   <chr>  <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 test_… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 2 A      Std   G     X     T     W     N     S     extr  M     V     empty Std  
#> 3 B      Std   G     X     T     W     N     S     extr  M     V     empty Std  
#> 4 C      Std   G     X     T     W     N     S     extr  M     V     empty Std  
#> 5 D      Std   G     X     T     W     N     S     extr  M     V     empty Std  
#> 6 E      Std   P     L     E     B     Z     H     extr  O     empty empty Std  
#> 7 F      Std   P     L     E     B     Z     H     extr  O     empty empty Std  
#> 8 G      Std   P     L     E     B     Z     H     extr  O     empty empty Std  
#> 9 H      Std   P     L     E     B     Z     H     extr  O     empty empty Std
```

Usually, more than one plate needs to be prepared. Let’s say we need to
prepare 5 plates, and we have a list of 5 x 14 samples (we want exactly
14 samples in each plate).
[`map_plates()`](https://mdetoeuf.github.io/plate2N/reference/map_plates.md)
builds on
[`map_1_plate()`](https://mdetoeuf.github.io/plate2N/reference/map_1_plate.md)
to map several plates.

``` r

# take random fruit names as sample names
samples <- stringr::fruit[1:70]

# Have a look at the first 5
samples[1:5]
#> [1] "apple"       "apricot"     "avocado"     "banana"      "bell pepper"

tibble <- map_plates(
  samples, 
  n_samples_per_plate = 14, 
  column_blank = 6) 
tibble |> print(n = 15)
#> # A tibble: 45 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 plat… 1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     Std   apple avoc… bell… blac… extr  bloo… boys… cana… empty empty Std  
#>  3 B     Std   apple avoc… bell… blac… extr  bloo… boys… cana… empty empty Std  
#>  4 C     Std   apple avoc… bell… blac… extr  bloo… boys… cana… empty empty Std  
#>  5 D     Std   apple avoc… bell… blac… extr  bloo… boys… cana… empty empty Std  
#>  6 E     Std   apri… bana… bilb… blac… extr  blue… brea… cant… empty empty Std  
#>  7 F     Std   apri… bana… bilb… blac… extr  blue… brea… cant… empty empty Std  
#>  8 G     Std   apri… bana… bilb… blac… extr  blue… brea… cant… empty empty Std  
#>  9 H     Std   apri… bana… bilb… blac… extr  blue… brea… cant… empty empty Std  
#> 10 plat… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     Std   cher… chil… clou… cran… extr  curr… date  duri… empty empty Std  
#> 12 B     Std   cher… chil… clou… cran… extr  curr… date  duri… empty empty Std  
#> 13 C     Std   cher… chil… clou… cran… extr  curr… date  duri… empty empty Std  
#> 14 D     Std   cher… chil… clou… cran… extr  curr… date  duri… empty empty Std  
#> 15 E     Std   cher… clem… coco… cucu… extr  dams… drag… eggp… empty empty Std  
#> # ℹ 30 more rows
```

The interest of this tibble is that it can easily

- be exported as a csv, then made “pretty” for printing and usage in the
  lab, for example with `readr::write_csv("path/to/my/mapping_data.csv)`

&nbsp;

- be inputted back into the import pipeline, either with
  [`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
  or as this tibble in post-import steps.

Either way, but especially if the tibble is not exported as a csv, we
recommend saving this tibble on the disk, for example using
`readr::wrtite_rds("path/to/my/output/data.rds)`
