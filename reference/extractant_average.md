# Computing the per-plate average for raw absorbance of the extractant (blank for samples)

Computing the per-plate average for raw absorbance of the extractant
(blank for samples)

## Usage

``` r
extractant_average(data = NULL, extractant_data = NULL, extr_def = "extr")
```

## Arguments

- data:

  A tibble like `tidy_plates`

- extractant_data:

  Alternatively, A tibble containing only extractant data Defaults to
  NULL, where it would be computed from `data` using
  `extract_extractant(data)`

- extr_def:

  A string that characterizes wells containing the extractant in the
  mapping (`map`column) of the plate

## Value

A tibble with one row per plate, contianing the average, standard
deviation and coefficient of variation of raw absorbance of the
extractant

## Examples

``` r
data = tidy_plates
(blank_avg <- extractant_average(data))
#> # A tibble: 5 × 5
#>   plate_id map   blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>    <chr>     <dbl>      <dbl>                   <dbl>
#> 1 NO3_1F1  extr     0.0828   0.000463                   0.559
#> 2 NO3_1F2  extr     0.0821   0.000641                   0.780
#> 3 NO3_1F3  extr     0.0846   0.00151                    1.78 
#> 4 NO3_1F4  extr     0.0838   0.000463                   0.553
#> 5 NO3_1F5  extr     0.0838   0.000463                   0.553
```
