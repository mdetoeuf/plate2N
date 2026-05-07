# import-tidy

**TO DO**

- Create a function to prepare a csv template to be filled (by hand)
- Create a function to generate a csv from a sample list

## Introduction

The goal of `plate2N` is to facilitate data wrangling and data analysis
for raw data that originates from absorbance readings with a 96-well
plate reader (spectrophotometry).

``` r

library(plate2N)
```

This particular vignette adresses the first steps of the pipeline:
getting from files of raw data in various forms to a tidy data table
that can be easily manipulated in downstream steps. The final
`tidy_table` will look something like this:

``` r

tidy_table
#> # A tibble: 960 × 8
#>    row   column well_id plate_id unique_well_id dataset map     abs   
#>    <chr> <chr>  <chr>   <chr>    <chr>          <chr>   <chr>   <chr> 
#>  1 A     1      A1      M12      A1_M12         expe1   Std0001 1.4402
#>  2 A     1      A1      M16      A1_M16         expe1   Std0097 1.5789
#>  3 A     1      A1      M17      A1_M17         expe1   Std0193 1.5611
#>  4 A     1      A1      M18      A1_M18         expe1   Std0289 1.7013
#>  5 A     1      A1      M19      A1_M19         expe1   Std0385 1.6865
#>  6 A     1      A1      M20      A1_M20         expe1   Std0481 1.7936
#>  7 A     1      A1      M21      A1_M21         expe1   Std0577 1.7925
#>  8 A     1      A1      M22      A1_M22         expe1   Std0673 1.8274
#>  9 A     1      A1      M23      A1_M23         expe1   Std0769 1.9330
#> 10 A     1      A1      M1       A1_M1          expe1   Std0865 0.9254
#> # ℹ 950 more rows
```

In this vignette, we cover three steps:

**1) Data import** from various raw file formats with
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md),
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
and
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md),
where data is brought into a shape that is common to all import file. We
refer to the output of this first step in an object called “tibble”
where data is still in a “plate” format (see hereunder). In this tibble,
the first columns contains the plate id in the first row, followed by
the letters caracterising the 8 rows of the plate (from A to H). The
rest of the first row contains the plate-column numbers (from 1 to 12).
The rest of the table contains the original plate data, which can be
numerical (e.g., absorbance data) or characters (e.g., plate mapping)

``` r

tibble_example
#> # A tibble: 36 × 13
#>    row          X1    X2    X3    X4    X5    X6    X7    X8    X9    X10    X11
#>    <chr>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
#>  1 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#>  2 A         0.095 0.537 0.528 0.562 0.51  0.507 0.546 0.078 0.519  0.543  0.521
#>  3 B         0.191 0.541 0.521 0.544 0.507 0.515 0.527 0.078 0.521  0.54   0.521
#>  4 C         0.255 0.551 0.513 0.559 0.505 0.511 0.541 0.078 0.519  0.54   0.514
#>  5 D         0.396 0.54  0.528 0.551 0.507 0.509 0.541 0.078 0.517  0.54   0.515
#>  6 E         0.65  0.979 0.946 1.01  0.926 0.927 0.996 0.078 0.955  0.997  0.936
#>  7 F         1.05  0.981 0.959 1     0.921 0.931 0.99  0.08  0.944  0.975  0.943
#>  8 G         1.83  0.988 0.954 0.994 0.936 0.935 0.995 0.077 0.945  0.995  0.939
#>  9 H         2.45  0.984 0.969 0.991 0.923 0.94  0.99  0.077 0.932  0.986  0.949
#> 10 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#> # ℹ 26 more rows
#> # ℹ 1 more variable: X12 <dbl>
```

**2) Verticalization** of the “tibble” into a verticalized table with
[`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md).
The `vertical_plates` present data in a verticalized format, i.e., data
from each plate is displayed in a single column where the name of the
column is the plate id. The first 2 columns contain the well identifier,
stored in the columns “row” (of the plate, from A to H), and “column”
(from 1 to 12). This vertical format is a good format to select a subset
of plates (e.g., based on experiment, treatment, or anything else that
the user stored into column names). See example hereunder:

``` r

vertical_plates
#> # A tibble: 96 × 6
#>    row   column NO3_TDN_01 NO3_TDN_02 NO3_TDN_03 NO3_TDN_04
#>    <chr> <chr>       <dbl>      <dbl>      <dbl>      <dbl>
#>  1 A     1           0.095      0.097      0.113      0.114
#>  2 A     2           0.537      0.552      0.53       0.535
#>  3 A     3           0.528      0.559      0.528      0.534
#>  4 A     4           0.562      0.555      0.521      0.531
#>  5 A     5           0.51       0.538      0.521      0.506
#>  6 A     6           0.507      0.552      0.54       0.551
#>  7 A     7           0.546      0.534      0.551      0.528
#>  8 A     8           0.078      0.079      0.097      0.102
#>  9 A     9           0.519      0.589      0.559      0.541
#> 10 A     10          0.543      0.535      0.528      0.544
#> # ℹ 86 more rows
```

**3) Tidying** of the verticalized plate into the `tidy_table` displayed
at the beginning of this vignette, a format that is easily usable for
downstream data transformations and analyses. This step is done using
the `tidyr` package

Note: If the need arises to fit this package to other plate formats than
96-well plates, please reach out to the authors.

------------------------------------------------------------------------

## 1 - Import

All 3 import functions hereunder
([`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md),
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)
and
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md))
can be used to import absorbance **and** mapping data into a single
tibble. However, in that case, it is recommended to attribute different
plate ids to the 2 “plates” that represent the same plate (e.g.,
“NO3_plate1_abs” and “NO3_plate1_map”, see also description of
[`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)
in section 2 to see the final output).

### 1.1 - From a .csv file

The function
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
imports plate data from a csv file where data is structured in a
specific way (see hereunder). For other csv formats, see sections below
about “skanit csv” and “other formats”. The required data structure is
strictly the same as in the outputted tibble (see `tibble_example`
hereabove).

In that sense, the function
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)constitutes
the simplest import option and takes advantage of the `readr` package
(part of the `tidyverse`), by using either the function
[`read_csv()`](https://readr.tidyverse.org/reference/read_delim.html) or
[`read_csv2()`](https://readr.tidyverse.org/reference/read_delim.html),
for comma-separated or semi-colon separated values, respectively, which
can be modulated by the parameter `delim`, which defaults with the value
`","`
([`read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)),
but accepts `";"`
([`read_csv2()`](https://readr.tidyverse.org/reference/read_delim.html)).

Here is an example of how to call the
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
function.

``` r

# see the function in action
example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
preview_csv <- csv_to_tibble(example_csv)
print(preview_csv, n = 20)
#> # A tibble: 36 × 13
#>    row          X1    X2    X3    X4    X5    X6    X7    X8    X9    X10    X11
#>    <chr>     <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>  <dbl>
#>  1 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#>  2 A         0.095 0.537 0.528 0.562 0.51  0.507 0.546 0.078 0.519  0.543  0.521
#>  3 B         0.191 0.541 0.521 0.544 0.507 0.515 0.527 0.078 0.521  0.54   0.521
#>  4 C         0.255 0.551 0.513 0.559 0.505 0.511 0.541 0.078 0.519  0.54   0.514
#>  5 D         0.396 0.54  0.528 0.551 0.507 0.509 0.541 0.078 0.517  0.54   0.515
#>  6 E         0.65  0.979 0.946 1.01  0.926 0.927 0.996 0.078 0.955  0.997  0.936
#>  7 F         1.05  0.981 0.959 1     0.921 0.931 0.99  0.08  0.944  0.975  0.943
#>  8 G         1.83  0.988 0.954 0.994 0.936 0.935 0.995 0.077 0.945  0.995  0.939
#>  9 H         2.45  0.984 0.969 0.991 0.923 0.94  0.99  0.077 0.932  0.986  0.949
#> 10 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#> 11 A         0.097 0.552 0.559 0.555 0.538 0.552 0.534 0.079 0.589  0.535  0.536
#> 12 B         0.19  0.548 0.553 0.544 0.538 0.558 0.539 0.08  0.583  0.537  0.534
#> 13 C         0.253 0.541 0.556 0.553 0.529 0.552 0.539 0.081 0.575  0.523  0.541
#> 14 D         0.391 0.543 0.548 0.554 0.545 0.556 0.539 0.08  0.577  0.535  0.534
#> 15 E         0.625 0.972 1.00  1.01  0.982 1.02  0.977 0.08  1.08   0.96   0.974
#> 16 F         1.08  0.978 1.00  1.01  0.987 1.01  0.979 0.081 1.07   0.971  0.96 
#> 17 G         1.74  0.962 1.01  1.00  0.994 1.02  0.97  0.081 1.08   0.966  0.963
#> 18 H         2.34  0.954 1     1.01  0.982 1.02  0.98  0.084 1.06   0.972  0.962
#> 19 NO3_TDN_… 1     2     3     4     5     6     7     8     9     10     11    
#> 20 A         0.113 0.53  0.528 0.521 0.521 0.54  0.551 0.097 0.559  0.528  0.526
#> # ℹ 16 more rows
#> # ℹ 1 more variable: X12 <dbl>
```

### 1.2 - From a skanit .csv

A “skanit csv” is a csv where data is structured also in a plate format,
but where plates are organized differently, according to a format that
is generated by a software called *Skanit* and is linked to the plate
reader. The raw csv format can be observed in the raw data attached to
this package and is displayed hereunder.

**It would make no sense to manually create a csv file in the “skanit
csv” format**, and using the function
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)
is only useful for users of the Skanit software. See also
`?skanit_to_tibble()` for more details.

``` r

library(readr)
skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
preview_skanit_raw <- readr::read_csv(skanit_csv, col_names = FALSE, show_col_types = FALSE)
print(preview_skanit_raw, n = 40)
#> # A tibble: 255 × 13
#>    X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12   X13  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 Meas… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  2 MR_1… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  3 01/0… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  4 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  5 Abso… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  6 Wave… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  7 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  8 M12   NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#>  9 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 10 Abs   1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     1.44… 1.48… 1.43… 1.47… 1.51… 1.49… 1.50… 1.52… 1.53… 1.52… 1.51… 1.53…
#> 12 B     1.45… 1.52… 1.50… 1.49… 1.53… 1.56… 1.53… 1.53… 1.53… 1.54… 1.54… 1.54…
#> 13 C     1.51… 1.54… 1.52… 1.53… 1.56… 1.54… 1.56… 1.57… 1.55… 1.55… 1.56… 1.55…
#> 14 D     1.53… 1.55… 1.57… 1.52… 1.54… 1.56… 1.55… 1.56… 1.55… 1.56… 1.55… 1.57…
#> 15 E     1.53… 1.55… 1.55… 1.53… 1.55… 1.55… 1.55… 1.55… 1.58… 1.56… 1.56… 1.55…
#> 16 F     1.52… 1.57… 1.55… 1.53… 1.52… 1.56… 1.57… 1.58… 1.56… 1.55… 1.57… 1.55…
#> 17 G     1.53… 1.55… 1.53… 1.53… 1.56… 1.55… 1.57… 1.55… 1.55… 1.56… 1.56… 1.57…
#> 18 H     1.49… 1.54… 1.52… 1.51… 1.55… 1.55… 1.56… 1.57… 1.53… 1.56… 1.57… 1.58…
#> 19 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 20 Samp… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 21 A     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 22 B     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 23 C     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 24 D     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 25 E     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 26 F     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 27 G     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 28 H     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 29 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 30 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 31 Wave… NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 32 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 33 M16   NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 34 NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA   
#> 35 Abs   1     2     3     4     5     6     7     8     9     10    11    12   
#> 36 A     1.57… 1.55… 1.54… 1.54… 1.61… 1.55… 1.56… 1.58… 1.60… 1.57… 1.51… 1.58…
#> 37 B     1.60… 1.62… 1.62… 1.57… 1.63… 1.62… 1.62… 1.59… 1.64… 1.63… 1.62… 1.64…
#> 38 C     1.63… 1.65… 1.63… 1.64… 1.66… 1.65… 1.65… 1.67… 1.66… 1.66… 1.65… 1.68…
#> 39 D     1.64… 1.64… 1.65… 1.67… 1.66… 1.67… 1.65… 1.66… 1.66… 1.65… 1.64… 1.65…
#> 40 E     1.64… 1.66… 1.65… 1.65… 1.66… 1.68… 1.67… 1.67… 1.67… 1.63… 1.65… 1.66…
#> # ℹ 215 more rows
```

Here is an example of how to call the
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)
function and see its output. Notice the identical structure between
`skanit$abs_tibble` and `skanit$map_tibble`.

``` r

skanit <- skanit_to_tibble(skanit_csv)
skanit_tibble_abs <- skanit$abs_tibble
skanit_tibble_map <- skanit$map_tibble
print(skanit_tibble_abs, n = 12) ; print(skanit_tibble_map, n = 12)
#> # A tibble: 90 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 M12   1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     1.44… 1.48… 1.43… 1.47… 1.51… 1.49… 1.50… 1.52… 1.53… 1.52… 1.51… 1.53…
#>  3 B     1.45… 1.52… 1.50… 1.49… 1.53… 1.56… 1.53… 1.53… 1.53… 1.54… 1.54… 1.54…
#>  4 C     1.51… 1.54… 1.52… 1.53… 1.56… 1.54… 1.56… 1.57… 1.55… 1.55… 1.56… 1.55…
#>  5 D     1.53… 1.55… 1.57… 1.52… 1.54… 1.56… 1.55… 1.56… 1.55… 1.56… 1.55… 1.57…
#>  6 E     1.53… 1.55… 1.55… 1.53… 1.55… 1.55… 1.55… 1.55… 1.58… 1.56… 1.56… 1.55…
#>  7 F     1.52… 1.57… 1.55… 1.53… 1.52… 1.56… 1.57… 1.58… 1.56… 1.55… 1.57… 1.55…
#>  8 G     1.53… 1.55… 1.53… 1.53… 1.56… 1.55… 1.57… 1.55… 1.55… 1.56… 1.56… 1.57…
#>  9 H     1.49… 1.54… 1.52… 1.51… 1.55… 1.55… 1.56… 1.57… 1.53… 1.56… 1.57… 1.58…
#> 10 M16   1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     1.57… 1.55… 1.54… 1.54… 1.61… 1.55… 1.56… 1.58… 1.60… 1.57… 1.51… 1.58…
#> 12 B     1.60… 1.62… 1.62… 1.57… 1.63… 1.62… 1.62… 1.59… 1.64… 1.63… 1.62… 1.64…
#> # ℹ 78 more rows
#> # A tibble: 90 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 M12   1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  3 B     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  4 C     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  5 D     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  6 E     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  7 F     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  8 G     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  9 H     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 10 M16   1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 12 B     Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> # ℹ 78 more rows
```

### 1.3 - From .TXT files

The function
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
has its own specific logic. Indeed, whereas both
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
and
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)
take a single **file** as input,
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
takes a single **folder** as input, in which an indefinite amount of
single .TXT files can be found. It is however important that the folder
contains no other .TXT files than the input data, though it may contain
other file types. More details on file requirements can be found under
`?txt_to_tibble()`. Here is an example of folder containing 5 .TXT
files.

``` r

# path to the folder containing .TXT plate files
(txt_folder <- system.file("extdata", "txt_examples", package = "plate2N"))
#> [1] "/home/runner/work/_temp/Library/plate2N/extdata/txt_examples"

#examine contents of txt_folder 
(files <- list.files(txt_folder))
#> [1] "NO3_1F1.TXT" "NO3_1F2.TXT" "NO3_1F3.TXT" "NO3_1F4.TXT" "NO3_1F5.TXT"
file <- paste0(txt_folder, "/", files[1]) # an example of file to look up in your computer
```

Each .TXT file contains the absorbance data of a single plate. This
means that, to create the `tibble`,
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
iterates through all .TXT files in a given folder (`txt_folder` in the
example above), extracts their plate data, adds the plate id in the
upper left corner of each plate data, then combines all plates into a
single `tibble`.

To examine the aspect of the raw file, go and manually visit the file
path displayed hereunder for `txt_folder` in your computer’s file
directory. Alternatively, you can see an example of raw .TXT file on our
github repository: *Add here a link to something*. Indeed, the raw file
structure cannot be easily shown here because import functions return
error messages unless we add some additional tweaking to extract only
the plate data. These error messages come because the column-structure
of the .TXT file is confusing to the import functions (see tentative
below). Therefore the import with
[`readr::read_tsv()`](https://readr.tidyverse.org/reference/read_delim.html)
already needs to skip some lines and extracts only the plate data, as
shown below, and cannot display the raw file structure.

``` r

# import the file "properly" (as in `txt_to_tibble()`), and loose the raw structure of the original .TXT
extracted_plate_data <- readr::read_tsv(file, col_names = TRUE, skip = 5, show_col_types = FALSE, name_repair = "unique_quiet", col_types = cols(.default = col_character())) |>
      tidyr::drop_na()
extracted_plate_data
#> # A tibble: 8 × 13
#>   ...1  `1`   `2`   `3`   `4`   `5`   `6`   `7`   `8`   `9`   `10`  `11`  `12` 
#>   <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 A     0.092 0.114 0.128 0.110 0.108 0.106 0.101 0.083 0.119 0.113 0.082 0.091
#> 2 B     0.100 0.110 0.124 0.109 0.106 0.103 0.103 0.083 0.117 0.111 0.081 0.097
#> 3 C     0.107 0.111 0.124 0.110 0.105 0.103 0.102 0.083 0.117 0.110 0.098 0.105
#> 4 D     0.122 0.111 0.122 0.109 0.107 0.103 0.102 0.083 0.118 0.114 0.081 0.120
#> 5 E     0.157 0.098 0.103 0.092 0.091 0.100 0.092 0.082 0.097 0.098 0.081 0.155
#> 6 F     0.238 0.097 0.098 0.093 0.091 0.100 0.093 0.083 0.095 0.099 0.081 0.229
#> 7 G     0.396 0.101 0.098 0.093 0.089 0.100 0.092 0.082 0.097 0.097 0.081 0.373
#> 8 H     0.546 0.097 0.099 0.092 0.090 0.103 0.094 0.083 0.110 0.099 0.082 0.530
```

Just as for
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md),
it would make little sense to use
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)
to extract plate data from .TXT files that have been generated in
another raw structure than the one provided here. Indeed, just as the
“skanit csv”, the “txt” structure was automatically generated by our
plate reader (*Add here reference of the plate reader*) when data is not
exported through the skanit software, but indeed is directly exported as
txt.

``` r

tibble_txt <- txt_to_tibble(filepath = txt_folder)
print(tibble_txt, n = 20)
#> # A tibble: 45 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 NO3_… 1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     0.092 0.114 0.128 0.110 0.108 0.106 0.101 0.083 0.119 0.113 0.082 0.091
#>  3 B     0.100 0.110 0.124 0.109 0.106 0.103 0.103 0.083 0.117 0.111 0.081 0.097
#>  4 C     0.107 0.111 0.124 0.110 0.105 0.103 0.102 0.083 0.117 0.110 0.098 0.105
#>  5 D     0.122 0.111 0.122 0.109 0.107 0.103 0.102 0.083 0.118 0.114 0.081 0.120
#>  6 E     0.157 0.098 0.103 0.092 0.091 0.100 0.092 0.082 0.097 0.098 0.081 0.155
#>  7 F     0.238 0.097 0.098 0.093 0.091 0.100 0.093 0.083 0.095 0.099 0.081 0.229
#>  8 G     0.396 0.101 0.098 0.093 0.089 0.100 0.092 0.082 0.097 0.097 0.081 0.373
#>  9 H     0.546 0.097 0.099 0.092 0.090 0.103 0.094 0.083 0.110 0.099 0.082 0.530
#> 10 NO3_… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     0.091 0.107 0.104 0.093 0.104 0.103 0.101 0.083 0.105 0.091 0.084 0.090
#> 12 B     0.099 0.103 0.100 0.092 0.101 0.104 0.101 0.082 0.107 0.089 0.084 0.098
#> 13 C     0.106 0.101 0.100 0.091 0.102 0.108 0.100 0.081 0.104 0.089 0.084 0.104
#> 14 D     0.119 0.101 0.100 0.093 0.101 0.109 0.100 0.082 0.105 0.092 0.084 0.131
#> 15 E     0.153 0.103 0.114 0.102 0.108 0.103 0.112 0.083 0.118 0.121 0.085 0.155
#> 16 F     0.230 0.106 0.113 0.102 0.109 0.105 0.107 0.082 0.116 0.122 0.084 0.234
#> 17 G     0.374 0.114 0.116 0.103 0.109 0.104 0.108 0.082 0.117 0.120 0.085 0.393
#> 18 H     0.523 0.116 0.119 0.102 0.111 0.106 0.108 0.082 0.121 0.125 0.085 0.551
#> 19 NO3_… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 20 A     0.093 0.095 0.097 0.102 0.094 0.093 0.099 0.084 0.098 0.102 0.081 0.090
#> # ℹ 25 more rows
```

**Note:** Should you have raw .TXT files with a different structure,
please reach out, and we can propose an adapted importing step into our
function definition.

### 1.4 - From other formats

Should you have data in different raw formats, there are 2 options.

**1) With small data sets**, a quick option would be to simply
copy-paste your raw plate data into a clean csv sheet (outside of R, for
example in Excel), adopting the raw structure of `tibble_example`. You
can generate an empty csv template using the function *Add here the name
of other funtion*. Or you can lookup the csv structure of the following
file:

``` r

(example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N"))
#> [1] "/home/runner/work/_temp/Library/plate2N/extdata/csv_example.csv"
```

**2) With bigger data sets**, we recommend using an export function from
the `readr` package (e.g.,
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html),
[`readr::read_tsv()`](https://readr.tidyverse.org/reference/read_delim.html)
or
[`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)),
possibly with a selection of columns or rows, then using tools of the
`dplyr` or `tidyr` packages to bring the resulting tibble into the
required format.

## 2 - Verticalized table

Finally, once the `tibble` has been generated with any of the import
options hereabove, we can proceed to the data verticalization.

### 2.1 - Simple verticalization of a single tibble

See also `?verticalize_plates()` for a detailed overview of function
options.

``` r

# compute vertical plate
## from txt
(vertical_txt <- verticalize_plates(tibble_txt))
#> # A tibble: 96 × 7
#>    row   column NO3_1F1 NO3_1F2 NO3_1F3 NO3_1F4 NO3_1F5
#>    <chr> <chr>  <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 A     1      0.092   0.091   0.093   0.092   0.092  
#>  2 A     2      0.114   0.107   0.095   0.118   0.167  
#>  3 A     3      0.128   0.104   0.097   0.138   0.107  
#>  4 A     4      0.110   0.093   0.102   0.108   0.101  
#>  5 A     5      0.108   0.104   0.094   0.098   0.093  
#>  6 A     6      0.106   0.103   0.093   0.104   0.103  
#>  7 A     7      0.101   0.101   0.099   0.107   0.120  
#>  8 A     8      0.083   0.083   0.084   0.084   0.084  
#>  9 A     9      0.119   0.105   0.098   0.121   0.113  
#> 10 A     10     0.113   0.091   0.102   0.119   0.099  
#> # ℹ 86 more rows

## from csv
(vertical_csv <- verticalize_plates(preview_csv))
#> # A tibble: 96 × 6
#>    row   column NO3_TDN_01 NO3_TDN_02 NO3_TDN_03 NO3_TDN_04
#>    <chr> <chr>  <chr>      <chr>      <chr>      <chr>     
#>  1 A     1      0.095      0.097      0.113      0.114     
#>  2 A     2      0.537      0.552      0.53       0.535     
#>  3 A     3      0.528      0.559      0.528      0.534     
#>  4 A     4      0.562      0.555      0.521      0.531     
#>  5 A     5      0.51       0.538      0.521      0.506     
#>  6 A     6      0.507      0.552      0.54       0.551     
#>  7 A     7      0.546      0.534      0.551      0.528     
#>  8 A     8      0.078      0.079      0.097      0.102     
#>  9 A     9      0.519      0.589      0.559      0.541     
#> 10 A     10     0.543      0.535      0.528      0.544     
#> # ℹ 86 more rows

## from skanit --> choose abs_data or map_data
(vertical_skanit_abs <- verticalize_plates(skanit_tibble_abs))
#> # A tibble: 96 × 12
#>    row   column M12    M16    M17    M18    M19    M20   M21   M22   M23   M1   
#>    <chr> <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  <chr> <chr> <chr> <chr> <chr>
#>  1 A     1      1.4402 1.5789 1.5611 1.7013 1.6865 1.79… 1.79… 1.82… 1.93… 0.92…
#>  2 A     2      1.4802 1.5590 1.5946 1.6475 1.6805 1.77… 1.79… 1.81… 1.89… 1.14…
#>  3 A     3      1.4380 1.5446 1.5868 1.6804 1.6934 1.73… 1.80… 1.84… 1.87… 1.13…
#>  4 A     4      1.4752 1.5414 1.6137 1.6902 1.6825 1.80… 1.80… 1.83… 1.93… 1.13…
#>  5 A     5      1.5143 1.6169 1.5939 1.6849 1.5994 1.77… 1.80… 1.88… 1.98… 1.14…
#>  6 A     6      1.4927 1.5561 1.5973 1.6939 1.7107 1.78… 1.81… 1.84… 1.98… 1.14…
#>  7 A     7      1.5052 1.5608 1.5888 1.6686 1.7196 1.77… 1.81… 1.89… 1.99… 1.15…
#>  8 A     8      1.5293 1.5882 1.5836 1.6908 1.6722 1.72… 1.83… 1.88… 2.01… 1.16…
#>  9 A     9      1.5301 1.6060 1.6011 1.7069 1.6220 1.81… 1.84… 1.93… 2.04… 1.16…
#> 10 A     10     1.5228 1.5773 1.6066 1.6949 1.6794 1.79… 1.81… 1.91… 2.01… 1.11…
#> # ℹ 86 more rows
(vertical_skanit_map <- verticalize_plates(skanit_tibble_map))
#> # A tibble: 96 × 12
#>    row   column M12     M16     M17    M18   M19   M20   M21   M22   M23   M1   
#>    <chr> <chr>  <chr>   <chr>   <chr>  <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 A     1      Std0001 Std0097 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  2 A     2      Std0002 Std0098 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  3 A     3      Std0003 Std0099 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  4 A     4      Std0004 Std0100 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  5 A     5      Std0005 Std0101 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  6 A     6      Std0006 Std0102 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  7 A     7      Std0007 Std0103 Std01… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  8 A     8      Std0008 Std0104 Std02… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#>  9 A     9      Std0009 Std0105 Std02… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> 10 A     10     Std0010 Std0106 Std02… Std0… Std0… Std0… Std0… Std0… Std0… Std0…
#> # ℹ 86 more rows

# compare tibble to its verticalized format
print(tibble_txt, n = 12) ; print(vertical_txt, n = 12)
#> # A tibble: 45 × 13
#>    row   X1    X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>    <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 NO3_… 1     2     3     4     5     6     7     8     9     10    11    12   
#>  2 A     0.092 0.114 0.128 0.110 0.108 0.106 0.101 0.083 0.119 0.113 0.082 0.091
#>  3 B     0.100 0.110 0.124 0.109 0.106 0.103 0.103 0.083 0.117 0.111 0.081 0.097
#>  4 C     0.107 0.111 0.124 0.110 0.105 0.103 0.102 0.083 0.117 0.110 0.098 0.105
#>  5 D     0.122 0.111 0.122 0.109 0.107 0.103 0.102 0.083 0.118 0.114 0.081 0.120
#>  6 E     0.157 0.098 0.103 0.092 0.091 0.100 0.092 0.082 0.097 0.098 0.081 0.155
#>  7 F     0.238 0.097 0.098 0.093 0.091 0.100 0.093 0.083 0.095 0.099 0.081 0.229
#>  8 G     0.396 0.101 0.098 0.093 0.089 0.100 0.092 0.082 0.097 0.097 0.081 0.373
#>  9 H     0.546 0.097 0.099 0.092 0.090 0.103 0.094 0.083 0.110 0.099 0.082 0.530
#> 10 NO3_… 1     2     3     4     5     6     7     8     9     10    11    12   
#> 11 A     0.091 0.107 0.104 0.093 0.104 0.103 0.101 0.083 0.105 0.091 0.084 0.090
#> 12 B     0.099 0.103 0.100 0.092 0.101 0.104 0.101 0.082 0.107 0.089 0.084 0.098
#> # ℹ 33 more rows
#> # A tibble: 96 × 7
#>    row   column NO3_1F1 NO3_1F2 NO3_1F3 NO3_1F4 NO3_1F5
#>    <chr> <chr>  <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 A     1      0.092   0.091   0.093   0.092   0.092  
#>  2 A     2      0.114   0.107   0.095   0.118   0.167  
#>  3 A     3      0.128   0.104   0.097   0.138   0.107  
#>  4 A     4      0.110   0.093   0.102   0.108   0.101  
#>  5 A     5      0.108   0.104   0.094   0.098   0.093  
#>  6 A     6      0.106   0.103   0.093   0.104   0.103  
#>  7 A     7      0.101   0.101   0.099   0.107   0.120  
#>  8 A     8      0.083   0.083   0.084   0.084   0.084  
#>  9 A     9      0.119   0.105   0.098   0.121   0.113  
#> 10 A     10     0.113   0.091   0.102   0.119   0.099  
#> 11 A     11     0.082   0.084   0.081   0.081   0.168  
#> 12 A     12     0.091   0.090   0.090   0.091   0.090  
#> # ℹ 84 more rows
```

### 2.2 - Joined verticalization of 2 related tibbles

In the practice, we often import absorbance data with one function
(typically
[`skanit_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/skanit_to_tibble.md)
or
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md))
and mapping data from another (typically
[`csv_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/csv_to_tibble.md)
or even simply
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)).
This means that, in the end, we not only need to verticalize both those
datasets, but we also need to merge them in a single data set.

`join_ab_map()` does just that. It works directly from the imported
`tibble`s, uses
[`verticalize_plates()`](https://mdetoeuf.github.io/plate2N/reference/verticalize_plates.md)
followed by
[`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html)
that is given a series of default presets that match exactly our needs
by adding a prefix to column names to incorporate information on dataset
(optional) and data type (absorbance vs mapping).

``` r

(joined_vertical <- join_abs_map(
  skanit_tibble_abs,
  skanit_tibble_map,
  dataset = "expe1-"))
#> # A tibble: 96 × 22
#>    row   column `expe1-abs-M12` `expe1-abs-M16` `expe1-abs-M17` `expe1-abs-M18`
#>    <chr> <chr>  <chr>           <chr>           <chr>           <chr>          
#>  1 A     1      1.4402          1.5789          1.5611          1.7013         
#>  2 A     2      1.4802          1.5590          1.5946          1.6475         
#>  3 A     3      1.4380          1.5446          1.5868          1.6804         
#>  4 A     4      1.4752          1.5414          1.6137          1.6902         
#>  5 A     5      1.5143          1.6169          1.5939          1.6849         
#>  6 A     6      1.4927          1.5561          1.5973          1.6939         
#>  7 A     7      1.5052          1.5608          1.5888          1.6686         
#>  8 A     8      1.5293          1.5882          1.5836          1.6908         
#>  9 A     9      1.5301          1.6060          1.6011          1.7069         
#> 10 A     10     1.5228          1.5773          1.6066          1.6949         
#> # ℹ 86 more rows
#> # ℹ 16 more variables: `expe1-abs-M19` <chr>, `expe1-abs-M20` <chr>,
#> #   `expe1-abs-M21` <chr>, `expe1-abs-M22` <chr>, `expe1-abs-M23` <chr>,
#> #   `expe1-abs-M1` <chr>, `expe1-map-M12` <chr>, `expe1-map-M16` <chr>,
#> #   `expe1-map-M17` <chr>, `expe1-map-M18` <chr>, `expe1-map-M19` <chr>,
#> #   `expe1-map-M20` <chr>, `expe1-map-M21` <chr>, `expe1-map-M22` <chr>,
#> #   `expe1-map-M23` <chr>, `expe1-map-M1` <chr>
```

When we look at this new joined table, we recognize the same
verticalized structures, but now names have been added a double prefix,
containing “expe1” which was attributed to the argument `dataset` and
either “abs” or “map”.

- Defining a dataset in the column names makes sense especially if
  several datasets will be joined down the line.
- The “abs/map” prefixes can be modulated by adapting the default value
  of the argument `abs_map = c("abs-", "map")`

Additional info can be found under `?join_abs_map()`.

## 3 - Tidy table

The vertical format is practical for manual/human handling, with an
easy-to-handle number of rows (96), and individual plates are easy to
select based on plate name. For example, here is an easy moment to
subset some plates based on dataset, abs/map or even some features that
are embedded in plate name (such as N species in our case where plate
names contained either “NO3”, “NO2” or “NH4”). This can be easily done
using the `dplyr` package and its function
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html),
aided by some helper functions from the `tidyselect` package, such as
`starts_with()`, `contains()`, etc.

But this verticalized format is not ideal for bulk computing and
transformations, where the might of the `tidyverse` sits in computations
done no columns. So, a typical last step of tidying would be to bring
this dataset in a format with a single column for the absorbance date,
and another for the mapping data, where each unique well would be
represented by a row. The `tidyr` and “`dplyr` packages do this job
wonderfully and we did not feel the need to create our own function, as
each user might want to adapt this final tidy table to their own need.
However, we show here one example of how to use successively
[`tidyr::pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html)and
[`tidyr::pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html)
to get the data where we need it before sending it to
computational/analytical pipelines.

First, we use pivot longer to get columns in a more compacted way. In
the end, we will need to separate again absorbance data (numerical) from
mapping data (strings), that will come in the next step

``` r

(too_long <- joined_vertical |> 
  tidyr::pivot_longer(
    cols = !any_of(c("row", "column")),
    names_to = c("dataset", "abs_map", "plate_id"),
    names_sep = "-",
    values_to = "value"
    ))
#> # A tibble: 1,920 × 6
#>    row   column dataset abs_map plate_id value 
#>    <chr> <chr>  <chr>   <chr>   <chr>    <chr> 
#>  1 A     1      expe1   abs     M12      1.4402
#>  2 A     1      expe1   abs     M16      1.5789
#>  3 A     1      expe1   abs     M17      1.5611
#>  4 A     1      expe1   abs     M18      1.7013
#>  5 A     1      expe1   abs     M19      1.6865
#>  6 A     1      expe1   abs     M20      1.7936
#>  7 A     1      expe1   abs     M21      1.7925
#>  8 A     1      expe1   abs     M22      1.8274
#>  9 A     1      expe1   abs     M23      1.9330
#> 10 A     1      expe1   abs     M1       0.9254
#> # ℹ 1,910 more rows
```

This went a bit too far. What we want, is to have one column for
absorbance data, another one for the mapping. This is what we do with
the call to pivot_wider() in the next chunk. The next steps in the
pipeline (dplyr::relocate() and dplyr::mutate()) serve to improve the
table, with additional columns that might prove useful later (well_id
and unique_well_id).

``` r

(data_tidy <- too_long |> 
  tidyr::pivot_wider(
    names_from = "abs_map",
    values_from = "value"
  ) |> 
  dplyr::relocate(map, .before = "abs" ) |> 
  dplyr::mutate(
    well_id = paste0(row, column),
    unique_well_id = paste0(well_id, "_", plate_id),
    .before = 3
  ))
#> # A tibble: 960 × 8
#>    row   column well_id unique_well_id dataset plate_id map     abs   
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>   <chr> 
#>  1 A     1      A1      A1_M12         expe1   M12      Std0001 1.4402
#>  2 A     1      A1      A1_M16         expe1   M16      Std0097 1.5789
#>  3 A     1      A1      A1_M17         expe1   M17      Std0193 1.5611
#>  4 A     1      A1      A1_M18         expe1   M18      Std0289 1.7013
#>  5 A     1      A1      A1_M19         expe1   M19      Std0385 1.6865
#>  6 A     1      A1      A1_M20         expe1   M20      Std0481 1.7936
#>  7 A     1      A1      A1_M21         expe1   M21      Std0577 1.7925
#>  8 A     1      A1      A1_M22         expe1   M22      Std0673 1.8274
#>  9 A     1      A1      A1_M23         expe1   M23      Std0769 1.9330
#> 10 A     1      A1      A1_M1          expe1   M1       Std0865 0.9254
#> # ℹ 950 more rows
```

## 4 - Next steps

Once the data is in this practical and tidy format, we can start data
transformation of all sorts, see also vignettes *xxx and xxx (under
development)* of this package. This is a good place to save the tidy
table into an intermediary file, for example, using
`data_tidy |> write_rds("path/to/my/output/file.rds")`.

## 5 - Final note: issues when absorbance and mapping data with identical plate ids are imported from a single file.

Usually, a physical plate that is used in the lab will come with 2 or
more data tables in plate format. Indeed, the measure of absorbance of a
well needs to be accompanied by some mapping information (e.g., to each
well corresponds also a sample id or information on treatment).
Consequently, a single plate (let’s call it “NO3_plate1”) will result in
the import of at least 2 “plate data tables”. Those 2 plate data sets
characterizing the same plate will need to be handled differently in
downstream analysis. We see here 2 typical use cases

**1) The 2 (or more) plate data sets are separated** into separate raw
files to be imported (e.g., absorbance data as a raw .TXT and mapping
data recorded as a .csv). In that case, 2 distinct `tibble`s will be
created, and it is quite easy to manipulate them separately in
subsequent steps or to use
[`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md)
to merge them and take profit of the automatic prefix that the function
adds during the verticalization/merging process.

**2) The 2 (or more) plate data sets are imported from a the same raw
file**. This can be done in several ways.

- data is imported from a “skanit csv” where the mapping of the plates
  had been encoded. By default, absorbance and mapping data will be
  returned into 2 separate items in the list generated by
  `skanit_to_csv()` and can be easily manipulated separately, e.g.,
  using
  [`join_abs_map()`](https://mdetoeuf.github.io/plate2N/reference/join_abs_map.md)
  as mentioned above.
- data is imported from a single csv file. In this particular case, it
  is recommended to name the 2 “plate data” with distinct plate ids
  (e.g., “abs-NO3_plate1” and “map-NO3_plate1”), so that they will
  simply be considered as distinct plates by the function
  `csv_to_skanit()`, and can easily be selected separately in subsequent
  steps, for example, taking advantage of the helper function
  [`tidyselect::starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html)
  (try this on the verticalized plate:
  `dplyr::select(my_vertical_plate, tidyselect::starts_with("abs"))`).
