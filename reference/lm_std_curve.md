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
outliers). - columns: `unique_curve_id`, `slope`, `r_squared`,
`adj_r_squared`, `lm_p`, `normality_lm_residuals`, `shapiro_p`,
`homoscedasticity_lm_residuals`, `breusch_pagan_p`, `outlier_rstudent`

## Examples

``` r
data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_std_curve(data)
#> # A tibble: 10 × 11
#>    plate_id unique_curve_id  slope r_squared adj_r_squared     lm_p
#>    <chr>    <chr>            <dbl>     <dbl>         <dbl>    <dbl>
#>  1 NO3_1F1  NO3_1F1_col1    0.0189         1         0.999 6.49e-11
#>  2 NO3_1F1  NO3_1F1_col12   0.0179         1         0.999 2.79e-10
#>  3 NO3_1F2  NO3_1F2_col1    0.0178         1         0.999 6.03e-11
#>  4 NO3_1F2  NO3_1F2_col12   0.0190         1         0.999 1.64e-10
#>  5 NO3_1F3  NO3_1F3_col1    0.0186         1         0.999 2.07e-10
#>  6 NO3_1F3  NO3_1F3_col12   0.0184         1         0.999 4.07e-10
#>  7 NO3_1F4  NO3_1F4_col1    0.0178         1         0.999 2.16e-10
#>  8 NO3_1F4  NO3_1F4_col12   0.0188         1         0.999 2.43e-10
#>  9 NO3_1F5  NO3_1F5_col1    0.0194         1         0.999 1.31e-10
#> 10 NO3_1F5  NO3_1F5_col12   0.0185         1         0.999 3.49e-10
#> # ℹ 5 more variables: normality_lm_residuals <chr>, shapiro_p <dbl>,
#> #   homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>,
#> #   outlier_rstudent <dbl>
```
