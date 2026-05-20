# Perform Linear Model for Standard Curve

The linear model is based on the function
[`lm()`](https://rdrr.io/r/stats/lm.html) and fits the curve to go
through the origin (0,0), which only makes sense for blank-corrected
absorbance data.

## Usage

``` r
lm_std_curve(grouped_data)
```

## Arguments

- grouped_data:

  A tibble, grouped per curve (e.g., use
  `dplyr::group_by(plate_id, column)` on your data before calling the
  function). Must contain columns `std_conc`, `unique_curve_id` and
  `abs_corrected`

## Value

A table containing relevant parameters of the linear model, with - 1 row
per "group" (e.g., plate \* column, which is relevant to spot
outliers). - columns

## Examples

``` r
data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_std_curve(data)
#> # A tibble: 10 × 8
#>    unique_curve_id  slope     lm_p normality_lm_residuals shapiro_p
#>    <chr>            <dbl>    <dbl> <chr>                      <dbl>
#>  1 NO3_1F1_col1    0.0189 6.49e-11 Normal                     0.836
#>  2 NO3_1F1_col12   0.0179 2.79e-10 Not Normal                 0.01 
#>  3 NO3_1F2_col1    0.0178 6.03e-11 Normal                     0.824
#>  4 NO3_1F2_col12   0.0190 1.64e-10 Normal                     0.962
#>  5 NO3_1F3_col1    0.0186 2.07e-10 Normal                     0.693
#>  6 NO3_1F3_col12   0.0184 4.07e-10 Normal                     0.775
#>  7 NO3_1F4_col1    0.0178 2.16e-10 Normal                     0.632
#>  8 NO3_1F4_col12   0.0188 2.43e-10 Normal                     0.646
#>  9 NO3_1F5_col1    0.0194 1.31e-10 Normal                     0.769
#> 10 NO3_1F5_col12   0.0185 3.49e-10 Normal                     0.663
#> # ℹ 3 more variables: homoscedasticity_lm_residuals <chr>,
#> #   breusch_pagan_p <dbl>, outlier_rstudent <dbl>
```
