# blank-correction

``` r

library(plate2N)
```

> **Work in progress**
>
> This vignette is still under development, bugs are to be expected

## TO DO

- Make sure there is a “bad” curve in the example dataset (with blank
  with higher absorbance than row B)
- Make sure there is a funky well in some extractant to check out the
  outlier removal plot
- Split actions within extract_std_blank so that average computes in a
  separate function, so it can be more easily re-run after outlier
  removal, then adapt code of the re-run

## Introduction

This vignette shows the basic functions that allow the correction of raw
absorbance data (`abs`) to blank-corrected absorbance data, referred to
as `abs_corrected` throughout this package.

This pipeline is adapted to the case where the standard curve solutions
were prepared with a different blank than the samples. Because of that,
there are 2 parallel pipelines to perform the blank-correction, then
data from standard curves and from samples are merged again.

In theory, the “samples” pipeline should be adaptable to the case where
all wells used the same blank (including those containing standard curve
solutions), though this has yet to be tested, and bugs may occur. Feel
free to contact the authors to suggest improvements.

To avoid confusion between “blank of the standard curve” and “blank of
the samples”, the sample-blank is referred to as “extractant” or `extr`
throughout this vignette, to refer to the solution that was used to
extract N-compounds from soil samples and now serves as blank. The
standard blank is referred to as `std_blank`.

## 1 - Getting raw absorbance data

The vignette `import-tidy` shows how to import and tidy absorbance data.
The vignette `handling-outliers` shows how to run some preliminary
quality checks and possibly remove some first outliers. To access those
vignettes, run the following commands

[`vignette("import-tidy", package = "plate2N")`](https://mdetoeuf.github.io/plate2N/articles/import-tidy.md)

[`vignette("handling-outliers", package = "plate2N")`](https://mdetoeuf.github.io/plate2N/articles/handling-outliers.md)

Tidy data as imported according to `import-tidy` should look something
like this:

``` r

tidy_plates
#> # A tibble: 480 × 8
#>    row   column well_id unique_well_id dataset plate_id map      abs  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.093
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.092
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167
#> # ℹ 470 more rows
```

For blank-correction of the standard curve, we will also require some
metadata for each 96-well plate containing at least the concentrations
of the dilutions of the standard curve

``` r

(meta <- metadata |> dplyr::select(dataset, plate_id, std_sp, std_unit, std_conc))
#> # A tibble: 5 × 5
#>   dataset plate_id std_sp std_unit    std_conc           
#>   <chr>   <chr>    <chr>  <chr>       <chr>              
#> 1 Nmin    NO3_1F1  NO3    mg NO3- L-1 0-0.5-1-2-4-8-16-24
#> 2 Nmin    NO3_1F2  NO3    mg NO3- L-1 0-0.5-1-2-4-8-16-24
#> 3 Nmin    NO3_1F3  NO3    mg NO3- L-1 0-0.5-1-2-4-8-16-24
#> 4 Nmin    NO3_1F4  NO3    mg NO3- L-1 0-0.5-1-2-4-8-16-24
#> 5 Nmin    NO3_1F5  NO3    mg NO3- L-1 0-0.5-1-2-4-8-16-24
```

We now join (raw) plate data and metadata (meta)

``` r

raw_meta <- tidy_plates |> 
  dplyr::left_join(meta, by = dplyr::join_by(dataset, plate_id))
```

## 2 - Blank-correction of standard curves

### 2.1 - Extract curve concentrations

To fit in one row per plate, the concentrations for standard curve are,
so far, stored in a compact manner, like this:

``` r

raw_meta |> dplyr::select(plate_id, std_conc) |> head(n = 3)
#> # A tibble: 3 × 2
#>   plate_id std_conc           
#>   <chr>    <chr>              
#> 1 NO3_1F1  0-0.5-1-2-4-8-16-24
#> 2 NO3_1F2  0-0.5-1-2-4-8-16-24
#> 3 NO3_1F3  0-0.5-1-2-4-8-16-24
```

Note that concentration values are separated by a `-` and digits are
marked by a `.`, which is important in the function call to
[`extract_curve()`](https://mdetoeuf.github.io/plate2N/reference/extract_curve.md).
Also, concentration values MUST be in ascending order in the metadata
file. See also
[`?metadata`](https://mdetoeuf.github.io/plate2N/reference/metadata.md)
and `?extract_curve()`

``` r

(curve_concentration <- extract_curve(meta, pipetting_direction = "top_down"))
#> # A tibble: 40 × 4
#>    dataset plate_id row   std_conc
#>    <chr>   <chr>    <chr> <chr>   
#>  1 Nmin    NO3_1F1  A     0       
#>  2 Nmin    NO3_1F1  B     0.5     
#>  3 Nmin    NO3_1F1  C     1       
#>  4 Nmin    NO3_1F1  D     2       
#>  5 Nmin    NO3_1F1  E     4       
#>  6 Nmin    NO3_1F1  F     8       
#>  7 Nmin    NO3_1F1  G     16      
#>  8 Nmin    NO3_1F1  H     24      
#>  9 Nmin    NO3_1F2  A     0       
#> 10 Nmin    NO3_1F2  B     0.5     
#> # ℹ 30 more rows
```

> **Too many rows?**
>
> A common mistake is to run
> [`extract_curve()`](https://mdetoeuf.github.io/plate2N/reference/extract_curve.md)
> on `raw_meta` instead of `meta`. But `meta` has one row per plate,
> whereas `raw_meta` has one row per well, so that calling
> `extract_curve(raw_meta)` would result on a table that is much too
> long (~96 times too long). If you run into issues later, this might be
> the source.

We now have curve concentrations connected to the dataset, plate_id and
row of a plate, which we can use for all downstream steps. This goes
under the assumption that standard curves are pipetted vertically in a
complete column of the 96-well plate. Check `?extract_curve()` for more
details.

### 2.2 - Extract Standard data

``` r

std_data <- raw_meta |> 
  extract_std_data(std_def = "Std") |> 
  dplyr::select(!std_conc) |> 
  dplyr::left_join(curve_concentration, by = dplyr::join_by(row, dataset, plate_id))
std_data
#> # A tibble: 80 × 12
#> # Groups:   dataset, plate_id [5]
#>    row   column well_id unique_well_id dataset plate_id unique_curve_id map  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>           <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  NO3_1F1_col1    Std  
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  NO3_1F2_col1    Std  
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  NO3_1F3_col1    Std  
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  NO3_1F4_col1    Std  
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  NO3_1F5_col1    Std  
#>  6 A     12     A12     A12_NO3_1F1    Nmin    NO3_1F1  NO3_1F1_col12   Std  
#>  7 A     12     A12     A12_NO3_1F2    Nmin    NO3_1F2  NO3_1F2_col12   Std  
#>  8 A     12     A12     A12_NO3_1F3    Nmin    NO3_1F3  NO3_1F3_col12   Std  
#>  9 A     12     A12     A12_NO3_1F4    Nmin    NO3_1F4  NO3_1F4_col12   Std  
#> 10 A     12     A12     A12_NO3_1F5    Nmin    NO3_1F5  NO3_1F5_col12   Std  
#> # ℹ 70 more rows
#> # ℹ 4 more variables: abs <chr>, std_sp <chr>, std_unit <chr>, std_conc <chr>
```

### 2.3 - Compute per-plate average of std_blank

`extract_std_blanc()` returns a list with several elements concerning
standard blanks

- `std_blank$all` fetches all wells that are expected to contain the
  standard blank (all standard data from plate-row A
  (`pipetting_direction = "top_down"`) or H
  (`pipetting_direction = "bottom_up"`)

- `std_blank$untrusted` identifies expected blank wells that do not
  correspond to the lowest absorbance value of their standard curve[^1].
  This item and may be empty

- `std_blank$trusted` is the complement to `std_blank$untrusted`.

- `std_blank$average` computes the per-plate average of standard blanks
  (relevant if there are several standard curves pipetted in one plate),
  as well as the standard deviation and the coefficient of variation.

``` r

std_blank <- std_data |> 
  extract_std_blank(
    std_def = "Std",
    pipetting_direction = "top_down")

std_blank$all
#> # A tibble: 10 × 8
#> # Groups:   dataset, plate_id, column [10]
#>    well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>    <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#>  1 A1      Nmin    NO3_1F1  A     1      A1_NO3_1F1     NO3_1F1_col1    0.092
#>  2 A1      Nmin    NO3_1F2  A     1      A1_NO3_1F2     NO3_1F2_col1    0.091
#>  3 A1      Nmin    NO3_1F3  A     1      A1_NO3_1F3     NO3_1F3_col1    0.093
#>  4 A1      Nmin    NO3_1F4  A     1      A1_NO3_1F4     NO3_1F4_col1    0.092
#>  5 A1      Nmin    NO3_1F5  A     1      A1_NO3_1F5     NO3_1F5_col1    0.092
#>  6 A12     Nmin    NO3_1F1  A     12     A12_NO3_1F1    NO3_1F1_col12   0.091
#>  7 A12     Nmin    NO3_1F2  A     12     A12_NO3_1F2    NO3_1F2_col12   0.09 
#>  8 A12     Nmin    NO3_1F3  A     12     A12_NO3_1F3    NO3_1F3_col12   0.09 
#>  9 A12     Nmin    NO3_1F4  A     12     A12_NO3_1F4    NO3_1F4_col12   0.091
#> 10 A12     Nmin    NO3_1F5  A     12     A12_NO3_1F5    NO3_1F5_col12   0.09

std_blank$average
#> # A tibble: 5 × 5
#>   dataset plate_id blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>   <chr>        <dbl>      <dbl>                   <dbl>
#> 1 Nmin    NO3_1F1     0.0915   0.000707                   0.773
#> 2 Nmin    NO3_1F2     0.0905   0.000707                   0.781
#> 3 Nmin    NO3_1F3     0.0915   0.00212                    2.32 
#> 4 Nmin    NO3_1F4     0.0915   0.000707                   0.773
#> 5 Nmin    NO3_1F5     0.091    0.00141                    1.55

std_blank$untrusted ; std_blank$trusted
#> # A tibble: 0 × 8
#> # Groups:   dataset, plate_id, column [0]
#> # ℹ 8 variables: well_id <chr>, dataset <chr>, plate_id <chr>, column <chr>,
#> #   unique_curve_id <chr>, row <chr>, unique_well_id <chr>, abs <dbl>
#> # A tibble: 10 × 8
#>    well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>    <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#>  1 A1      Nmin    NO3_1F1  A     1      A1_NO3_1F1     NO3_1F1_col1    0.092
#>  2 A1      Nmin    NO3_1F2  A     1      A1_NO3_1F2     NO3_1F2_col1    0.091
#>  3 A1      Nmin    NO3_1F3  A     1      A1_NO3_1F3     NO3_1F3_col1    0.093
#>  4 A1      Nmin    NO3_1F4  A     1      A1_NO3_1F4     NO3_1F4_col1    0.092
#>  5 A1      Nmin    NO3_1F5  A     1      A1_NO3_1F5     NO3_1F5_col1    0.092
#>  6 A12     Nmin    NO3_1F1  A     12     A12_NO3_1F1    NO3_1F1_col12   0.091
#>  7 A12     Nmin    NO3_1F2  A     12     A12_NO3_1F2    NO3_1F2_col12   0.09 
#>  8 A12     Nmin    NO3_1F3  A     12     A12_NO3_1F3    NO3_1F3_col12   0.09 
#>  9 A12     Nmin    NO3_1F4  A     12     A12_NO3_1F4    NO3_1F4_col12   0.091
#> 10 A12     Nmin    NO3_1F5  A     12     A12_NO3_1F5    NO3_1F5_col12   0.09
```

### 2.4 - Quality check of std_blank & outlier removal

> **Check out untrusted standard blanks**
>
> The computation of `std_blank$average` is made on trusted blank wells
> only. It is therefore important to check curves containing “untrusted”
> blank wells and decide whether to keep them or not

The function
[`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)
allows the visualization of a subset of curves. Because there is no
untrusted blank for now (**Make sure there is a “bad” curve in the
example dataset**), we artificially take a subset of `std_blank$all`
just for the purpose of demonstrating the plots.

``` r

# Subset: create an artificial std_data
artificial_std <- std_data |> 
  dplyr::filter(
    unique_curve_id %in% std_blank$all$unique_curve_id[1:4]) 

# look at (fake) "suspicious" curves
artificial_std |> 
  plot_std(through_origin = FALSE) +
  ggplot2::facet_wrap(~plate_id, scales = "free") +
  ggplot2::theme(legend.position = "none")
```

![](blank-correction_files/figure-html/unnamed-chunk-8-1.png)

If the absorbance in well A is very obviously wrong, then remove those
wells, either by keeping `std_blank$average` as is, or by using
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md)
and re-computing blank averages. Of course, this only works if there
were several standard curves on problematic plates, otherwise you will
be removing the only std_blank of the plate. In such cases, you must
consider your options. If the inter-plate variability of std_blank is
sufficiently small, taking an across-dataset or an across-batch mean
might do the trick.

Here is an example of how to re-compute average blanks in case we decide
to trust some of the wells from `std_blank$untrusted`, replaced here by
`artificial_blank_untrusted` because our untrusted example is empty (for
now).

``` r

# create artificial version of std_blank$untrusted
(artificial_blank_untrusted <- (artificial_std |> extract_std_blank(std_def = "Std"))$all)
#> # A tibble: 4 × 8
#> # Groups:   dataset, plate_id, column [4]
#>   well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>   <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#> 1 A1      Nmin    NO3_1F1  A     1      A1_NO3_1F1     NO3_1F1_col1    0.092
#> 2 A1      Nmin    NO3_1F2  A     1      A1_NO3_1F2     NO3_1F2_col1    0.091
#> 3 A1      Nmin    NO3_1F3  A     1      A1_NO3_1F3     NO3_1F3_col1    0.093
#> 4 A1      Nmin    NO3_1F4  A     1      A1_NO3_1F4     NO3_1F4_col1    0.092

# remove those untrusted wells from std_blank$all ~ new version of std_blank$trusted
(artificial_blank_clean <- std_blank$all |> remove_wells(artificial_blank_untrusted))
#> # A tibble: 6 × 8
#> # Groups:   dataset, plate_id, column [6]
#>   well_id dataset plate_id row   column unique_well_id unique_curve_id   abs
#>   <chr>   <chr>   <chr>    <chr> <chr>  <chr>          <chr>           <dbl>
#> 1 A1      Nmin    NO3_1F5  A     1      A1_NO3_1F5     NO3_1F5_col1    0.092
#> 2 A12     Nmin    NO3_1F1  A     12     A12_NO3_1F1    NO3_1F1_col12   0.091
#> 3 A12     Nmin    NO3_1F2  A     12     A12_NO3_1F2    NO3_1F2_col12   0.09 
#> 4 A12     Nmin    NO3_1F3  A     12     A12_NO3_1F3    NO3_1F3_col12   0.09 
#> 5 A12     Nmin    NO3_1F4  A     12     A12_NO3_1F4    NO3_1F4_col12   0.091
#> 6 A12     Nmin    NO3_1F5  A     12     A12_NO3_1F5    NO3_1F5_col12   0.09

# re-compute per-plate blank average from that new trusted table
artificial_std_blank_avg <- artificial_blank_clean |>
  dplyr::ungroup() |> 
  dplyr::summarise(
    .by = c(dataset, plate_id),
    blank_avg = mean(abs),
    blank_sdev = stats::sd(abs)
  ) |>
  dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)
```

In case of a manual re-computation of blank avergaes, all occurences of
std_blank\$average below should be replaced by this new
`artificial_std_blank_avg`.

### 2.5 - Blank-correction of Standard Curve

Once we are confident in our `std_blank`s, we can use the
`std_blank$average` to blank-correct the raw absorbance values for the
whole standard curves. This is done with the function
[`blank_correct_abs()`](https://mdetoeuf.github.io/plate2N/reference/blank_correct_abs.md),
which will also be used to correct sample absorbance data in the next
section.

[`blank_correct_abs()`](https://mdetoeuf.github.io/plate2N/reference/blank_correct_abs.md)
takes 3 main arguments.

- `raw_wells_data` takes the standard curves data. It should be
  ungrouped and contain only non-blank data (in the case of “top_down”
  pipetting, rows B to H)

- `per_plate_avg_blank` takes the version of blank averages that we
  trust (e.g., `std_blank$average` or `artificial_std_blank_avg)`

- `map_to_exclude` tells which rows to exclude from `raw_wells_data`
  based on their value for the column “map”. Its default setting fits
  the blank-correction of sample data, not that of standard data, so we
  simply replace it by `""`, as we do not wish to exclude any rows here

You can ignore the message `Joining with by = join_by(...)`, which just
depends on the additional columns you may have in your data tables

``` r

std_corrected <-
  blank_correct_abs(
    raw_wells_data = std_data |>
      dplyr::ungroup() |>
      dplyr::filter_out(row == "A"),
    per_plate_avg_blank = std_blank$average,
    map_to_exclude = ""
  ) |> 
  # only keep relevant columns (remove metadata clutter)
  dplyr::select(row:abs_corrected)
#> Joining with `by = join_by(dataset, plate_id)`
#> Joining with `by = join_by(row, column, well_id, unique_well_id, dataset,
#> plate_id, unique_curve_id, map, std_sp, std_unit, std_conc)`
std_corrected
#> # A tibble: 70 × 9
#>    row   column well_id unique_well_id dataset plate_id unique_curve_id map  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>           <chr>
#>  1 B     1      B1      B1_NO3_1F1     Nmin    NO3_1F1  NO3_1F1_col1    Std  
#>  2 B     1      B1      B1_NO3_1F2     Nmin    NO3_1F2  NO3_1F2_col1    Std  
#>  3 B     1      B1      B1_NO3_1F3     Nmin    NO3_1F3  NO3_1F3_col1    Std  
#>  4 B     1      B1      B1_NO3_1F4     Nmin    NO3_1F4  NO3_1F4_col1    Std  
#>  5 B     1      B1      B1_NO3_1F5     Nmin    NO3_1F5  NO3_1F5_col1    Std  
#>  6 B     12     B12     B12_NO3_1F1    Nmin    NO3_1F1  NO3_1F1_col12   Std  
#>  7 B     12     B12     B12_NO3_1F2    Nmin    NO3_1F2  NO3_1F2_col12   Std  
#>  8 B     12     B12     B12_NO3_1F3    Nmin    NO3_1F3  NO3_1F3_col12   Std  
#>  9 B     12     B12     B12_NO3_1F4    Nmin    NO3_1F4  NO3_1F4_col12   Std  
#> 10 B     12     B12     B12_NO3_1F5    Nmin    NO3_1F5  NO3_1F5_col12   Std  
#> # ℹ 60 more rows
#> # ℹ 1 more variable: abs_corrected <dbl>
```

Notice that the `abs` column has been removed to avoid mistaking it for
corrected absorbance. Instead, it has been replaced by `abs_corrected`.

## 3 - Blank-correction of samples

### 3.1 - Extract extractant data (sample blank)

In a real world, `raw_meta` will have probably undergone some cleaning
steps (e.g., outlier removal). In this example dataset, there are always
8 wells attributed to the sample blank (or extractant), which is found
because its mapping (column “map” in `raw_meta`) contains the string
“extr”.

``` r

raw_meta |> dplyr::filter(map == "extr")
#> # A tibble: 40 × 11
#>    row   column well_id unique_well_id dataset plate_id map   abs   std_sp
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr> <chr> <chr> 
#>  1 A     8      A8      A8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  2 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr  0.083 NO3   
#>  3 A     8      A8      A8_NO3_1F3     Nmin    NO3_1F3  extr  0.084 NO3   
#>  4 A     8      A8      A8_NO3_1F4     Nmin    NO3_1F4  extr  0.084 NO3   
#>  5 A     8      A8      A8_NO3_1F5     Nmin    NO3_1F5  extr  0.084 NO3   
#>  6 B     8      B8      B8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  7 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr  0.082 NO3   
#>  8 B     8      B8      B8_NO3_1F3     Nmin    NO3_1F3  extr  0.085 NO3   
#>  9 B     8      B8      B8_NO3_1F4     Nmin    NO3_1F4  extr  0.084 NO3   
#> 10 B     8      B8      B8_NO3_1F5     Nmin    NO3_1F5  extr  0.084 NO3   
#> # ℹ 30 more rows
#> # ℹ 2 more variables: std_unit <chr>, std_conc <chr>
```

This filtering is also what
[`extract_extractant()`](https://mdetoeuf.github.io/plate2N/reference/extract_extractant.md)
does in the background

``` r

extr_data <- extract_extractant(raw_meta)
```

### 3.2 - Compute per-plate average of extractant

First, extract data for wells containing extractant with
[`extract_extractant()`](https://mdetoeuf.github.io/plate2N/reference/extract_extractant.md)
and have a look at its variation.

This string “extr” is the default of the argument `extr_def` of
[`extractant_average()`](https://mdetoeuf.github.io/plate2N/reference/extractant_average.md)
and can be adapted to reflect your mapping. Like
`extract_std_blank(..)$average`,
[`extractant_average()`](https://mdetoeuf.github.io/plate2N/reference/extractant_average.md)
computes the average, standard deviation and coefficient of variation
(%) of the blanks.

``` r

(extr_avg <- extractant_average(raw_meta, extr_def = "extr")) 
#> # A tibble: 5 × 5
#>   plate_id map   blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>    <chr>     <dbl>      <dbl>                   <dbl>
#> 1 NO3_1F1  extr     0.0828   0.000463                   0.559
#> 2 NO3_1F2  extr     0.0821   0.000641                   0.780
#> 3 NO3_1F3  extr     0.0846   0.00151                    1.78 
#> 4 NO3_1F4  extr     0.0838   0.000463                   0.553
#> 5 NO3_1F5  extr     0.0838   0.000463                   0.553
```

### 3.3 - Quality check of extractant and outlier removal

[`plot_blank_var_distrib()`](https://mdetoeuf.github.io/plate2N/reference/plot_blank_var_distrib.md)
plots a distribution of this coefficient of variation throughout the
dataset (which becomes relevant in big data sets).

``` r

plot_blank_var_distrib(extr_avg)
```

![](blank-correction_files/figure-html/unnamed-chunk-14-1.png)

In big data sets, there is bound to be some plate where one or two wells
went wrong in the lab, and seeing that there are some plates with much
higher variation can be a sign that you need to investigate to remove
outliers. You can take advantage of `dplyr::arrange(desc())` to quickly
identify suspicious plates.

``` r

extr_avg |> 
  dplyr::arrange(desc(blank_coeff_var_percent))
#> # A tibble: 5 × 5
#>   plate_id map   blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>    <chr>     <dbl>      <dbl>                   <dbl>
#> 1 NO3_1F3  extr     0.0846   0.00151                    1.78 
#> 2 NO3_1F2  extr     0.0821   0.000641                   0.780
#> 3 NO3_1F1  extr     0.0828   0.000463                   0.559
#> 4 NO3_1F4  extr     0.0838   0.000463                   0.553
#> 5 NO3_1F5  extr     0.0838   0.000463                   0.553
```

[`qc_raw_extr()`](https://mdetoeuf.github.io/plate2N/reference/qc_raw_extr.md)\`
performs a quality check of raw absorbance data for extractant wells. It
returns a vector containing the “suspicious” `plate_id`s of plates
exceeding the user-defined threshold. For the sake of the example, we
will test a `max_coeff` threshold of acceptable coefficient of variation
at 5% (reasonable) and 0.5% (not really reasonable in the real world).

With a reasonable threshold, we get a happy message.

``` r

threshold <- 5

suspicious_plate_ids <- raw_meta |> 
  qc_raw_extr(suppress_message = FALSE, max_coeff = threshold)
#> 
#>         Good news: all plates show a satisfactorily small variation for raw blank (extractant) absorbance values. This means that the coefficient of variation is below the threshold of 5%.
```

With a very low threshold (for the sake of the example), we get a
warning message (here, all plates are fakly “suspicious”)

``` r

threshold <- 0.5

suspicious_plate_ids <- raw_meta |> 
  qc_raw_extr(suppress_warning = FALSE, max_coeff = threshold)
#> Warning in qc_raw_extr(raw_meta, suppress_warning = FALSE, max_coeff = threshold): 
#>         There is a big variation in absorbance values for the blank (more than 0.5%).
#>         Remove the most unlikely values / remove outliers manually.
#>         Suspicious plate ID's are returned
```

Both message and warning can be suppressed, see `?qc_raw_extr()`.

To obtain the full extractant data corresponding to those suspicious
plate_ids, we can use
[`suspicious_extr()`](https://mdetoeuf.github.io/plate2N/reference/suspicious_extr.md).

``` r

(suspicious_extr <- suspicious_extr(
  raw_meta, 
  suspicious_plate_id = suspicious_plate_ids, 
  max_coeff = threshold))
#> # A tibble: 40 × 11
#> # Groups:   plate_id, map [5]
#>    row   column well_id unique_well_id dataset plate_id map     abs std_sp
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr> <dbl> <chr> 
#>  1 A     8      A8      A8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  2 B     8      B8      B8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  3 C     8      C8      C8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  4 D     8      D8      D8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  5 E     8      E8      E8_NO3_1F1     Nmin    NO3_1F1  extr  0.082 NO3   
#>  6 F     8      F8      F8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  7 G     8      G8      G8_NO3_1F1     Nmin    NO3_1F1  extr  0.082 NO3   
#>  8 H     8      H8      H8_NO3_1F1     Nmin    NO3_1F1  extr  0.083 NO3   
#>  9 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr  0.083 NO3   
#> 10 B     8      B8      B8_NO3_1F2     Nmin    NO3_1F2  extr  0.082 NO3   
#> # ℹ 30 more rows
#> # ℹ 2 more variables: std_unit <chr>, std_conc <chr>
```

Finally, we can use
[`boxplot_outlier_extr()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_outlier_extr.md)
to plot extractant plates containing suspicious wells, so that we can
decide whether of not to remove some outlier wells. To do so, we can,
once more, take advantage of
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md),
see also above, `?remove_wells()` and the vignette `handling-outliers`.
Should there be too many plates for a proper visualization, split
`suspicious_extr` in subsets.

``` r

# plot outliers
suspicious_extr |> boxplot_outlier_extr(max_coeff = threshold)
```

![](blank-correction_files/figure-html/unnamed-chunk-19-1.png)

**Now we don’t see much, but when there is an outlier, we can directly
spot which well, because its well_id is shown on the plot –\> needs
improvement in the raw data here!**

Let’s say that we want to remove the well B8 of plate 1, wells A8 and C8
of plate 3 because they are a obvious outliers, and no wells in the
other plates. the plot given by
[`boxplot_outlier_extr()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_outlier_extr.md)
gives all necessary information to do so. First, we create a small
tibble that will serve to construct the tibble of wells to remove: first
get dataset and plate_ids from `suspicious_extr`, then add a column
“plate_order” that will help checking which plate is which (compared to
the plot, useful when several plates are plotted).

``` r

# Construct tibble to remove
(plate_ids <- suspicious_extr |> 
  dplyr::ungroup() |> 
  dplyr::select(dataset, plate_id) |> unique()) 
#> # A tibble: 5 × 2
#>   dataset plate_id
#>   <chr>   <chr>   
#> 1 Nmin    NO3_1F1 
#> 2 Nmin    NO3_1F2 
#> 3 Nmin    NO3_1F3 
#> 4 Nmin    NO3_1F4 
#> 5 Nmin    NO3_1F5
(plate_ids <- plate_ids |> # save numbers for plate order in the plot
  dplyr::mutate(plate_order = seq(1, nrow(plate_ids))))
#> # A tibble: 5 × 3
#>   dataset plate_id plate_order
#>   <chr>   <chr>          <int>
#> 1 Nmin    NO3_1F1            1
#> 2 Nmin    NO3_1F2            2
#> 3 Nmin    NO3_1F3            3
#> 4 Nmin    NO3_1F4            4
#> 5 Nmin    NO3_1F5            5
```

Then, we create a vector with wells to remove (reading through boxplots
from top to bottom).

> **Manually remove outliers**
>
> > **Tip 1**
> >
> > In the following chunk, we need to manually decide which wells to
> > remove, based on the boxplots produced above.
> >
> > - Make sure to deal appropriately with plates that require 2
> >   outliers or no outlier to be removed (see example below)
> > - Use a number \> nb of plates if there is no plate with 2 or zero
> >   outlier

To remove well B8 from plate 1, and wells A8 and C8 from plate 3:

``` r

#** !!! MANUAL INPUT !!! *

# Which plate needs 2 outliers removed?
plate_with_2_outliers <- c(3) 
# Which plate needs no outlier removed?
plate_without_outliers <- c(2, 4, 5) 

# Which wells are outliers? 
well_ids <- c("B8", "A8", "C8") # only fill in well_ids that need to be removed, in the order of the plates
```

Then we finish constructing the tibble of wells to be removed

``` r

to_remove <- plate_ids |> 
  dplyr::bind_rows(
    plate_ids |> dplyr::filter(plate_order %in% plate_with_2_outliers)) |> 
  dplyr::filter_out(plate_order %in% plate_without_outliers) |> #remove plate without outliers
  dplyr::arrange(plate_order) |> #reorder plates (if needed)
  dplyr::mutate(well_id = well_ids) |> 
  dplyr::select(!plate_order)

# check it out
to_remove
#> # A tibble: 3 × 3
#>   dataset plate_id well_id
#>   <chr>   <chr>    <chr>  
#> 1 Nmin    NO3_1F1  B8     
#> 2 Nmin    NO3_1F3  A8     
#> 3 Nmin    NO3_1F3  C8
```

And we remove it from extractant data (which is the same as removing 3
rows)

``` r

extr_data_clean <- extr_data |> remove_wells(to_remove) 
```

Finally, we re-run the average on cleaned extractant data

``` r

extr_avg_clean <- extractant_average(
  extractant_data = extr_data_clean, extr_def = "extr") 
```

Check that the highest coefficient of variation are now indeed
satisfactory

``` r

extr_avg_clean |> dplyr::arrange(dplyr::desc(blank_coeff_var_percent)) |> head()
#> # A tibble: 5 × 5
#>   plate_id map   blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>    <chr>     <dbl>      <dbl>                   <dbl>
#> 1 NO3_1F3  extr     0.0842   0.000753                   0.894
#> 2 NO3_1F2  extr     0.0821   0.000641                   0.780
#> 3 NO3_1F1  extr     0.0827   0.000488                   0.590
#> 4 NO3_1F4  extr     0.0838   0.000463                   0.553
#> 5 NO3_1F5  extr     0.0838   0.000463                   0.553
```

### 3.4 - Blank-correction of sample absorbance

Now that we are confident in the per-plate average value of raw
absorbance of extractant wells, we can finally blank-correct all sample
data

``` r

sample_corrected <- 
  blank_correct_abs(
    raw_wells_data = raw_meta, 
    per_plate_avg_blank = extr_avg_clean,
    map_to_exclude = c("empty","Std","extr")) 
#> Joining with `by = join_by(plate_id)`
#> Joining with `by = join_by(row, column, well_id, unique_well_id, dataset,
#> plate_id, map, std_sp, std_unit, std_conc)`
```

## 4 - Epilogue

We now have blank-corrected both standard data (`std_corrected`) and
sample data (`sample_corrected`), and we can proceed to computing the
linear model to obtain the regression equation to convert
blank-corrected absorbance data to (N-species) concentration data, as is
detailed in vignette **xxx - under development**

[^1]: This quality check was added because, in case of top_down
    pipetting, A1 often will contain the standard blank, but it is also
    often the first well to be filled during pipetting. With automated
    pipettes, a small ejection of liquid has to occur before dispensing
    the first dose of solution. Failure to intentionally eject will
    result in the first well receiving the “ejection” dose, which is not
    the correct volume. This can end up in various responses in terms of
    absorbance, depending on which reagent has been wrongly pipetted.
