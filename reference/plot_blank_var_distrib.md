# Plot dataset-wide distribution of withing-plate variation for extractant data

Plots, the distribution for each plate of the coefficient of variation
of raw absorbance of the extractant

## Usage

``` r
plot_blank_var_distrib(extractant_average = NULL, data = NULL)
```

## Arguments

- extractant_average:

  Defaults to NULL, where it is computed from `data` using
  `extractant_average(data)`

- data:

  A tibble like `tidy_plates`, must be provided if `extractant_average`
  is NULL.

## Value

A plot of the distribution of the coefficient of variation of raw
absorbance of the extractant

## Examples

``` r
# example code
tidy_plates |> extractant_average() |> plot_blank_var_distrib()

```
