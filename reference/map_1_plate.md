# Mapping a Vector with Sample ids into a 96-well Plate Format - Single Plate

Mapping a Vector with Sample ids into a 96-well Plate Format - Single
Plate

## Usage

``` r
map_1_plate(
  plate_id,
  samples,
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

- plate_id:

  The unique identifier of the plate

- samples:

  A vector of strings containing sample names. Samples will be displayed
  vertically in the plate (see examples)

- std_def:

  A single string to define wells containing the serial dilutions of the
  standard curve. Defaults to "Std"

- column_curves:

  Which columns to map the standard curves to. Can be a unique string or
  a vector. Defaults to `c(1,12)`.

- blank_def:

  A single string to define wells containing the blank. Defaults to
  `extr` (for "extractant")

- rename_na:

  How to replace NAs found in the sample list. Defaults to "empty",
  e.i., the plate map will show "empty" at the corresponding place to
  where the function found NAs

- empty_def:

  A single string to define empty wells

- column_empty:

  Optional, which columns to map as empty

- column_blank:

  Which column(s) to map to the blank. Defaults to `8`.

- n_wells_samples:

  How many replicates to attribute to each sample. Defaults to `4`.

## Value

A tibble of a single 96-well plate, in plate format, with the plate id
in the top left corner

## Details

This mapping function always attributes complete columns to standard
curves and blanks. Additional empty columns may be given, optionally.

If the list of samples is too short to fill all the wells, remaining
empty wells will be mapped using the character string defined under
`empty_def`.

## Examples

``` r
(samples <- sample(LETTERS, size = 15))
#>  [1] "O" "M" "B" "W" "K" "V" "E" "L" "X" "F" "Z" "P" "D" "R" "C"
map_1_plate(plate_id = "test_plate", samples = samples)
#> # A tibble: 9 × 13
#>   row    X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>   <chr>  <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 test_… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 2 A      Std   O     B     K     E     X     Z     extr  D     C     empty Std  
#> 3 B      Std   O     B     K     E     X     Z     extr  D     C     empty Std  
#> 4 C      Std   O     B     K     E     X     Z     extr  D     C     empty Std  
#> 5 D      Std   O     B     K     E     X     Z     extr  D     C     empty Std  
#> 6 E      Std   M     W     V     L     F     P     extr  R     empty empty Std  
#> 7 F      Std   M     W     V     L     F     P     extr  R     empty empty Std  
#> 8 G      Std   M     W     V     L     F     P     extr  R     empty empty Std  
#> 9 H      Std   M     W     V     L     F     P     extr  R     empty empty Std  
```
