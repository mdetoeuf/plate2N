# Perform Linear Model for Standard Curve

The linear model is based on the function
[`lm()`](https://rdrr.io/r/stats/lm.html) and fits the curve to go
through the origin (0,0), which only makes sense for blank-corrected
absorbance data.

## Usage

``` r
lm_std_curve(grouped_data, model = "linear")
```

## Arguments

- grouped_data:

  A tibble, grouped per curve (e.g., use
  `dplyr::group_by(plate_id, column)` on your data before calling the
  function). Must contain columns `std_conc`, `unique_curve_id` and
  `abs_corrected`

- model:

  Which model to use. Accepts either `linear` (default) or `poly` for
  polynomial model.

## Value

A table containing relevant parameters of the linear model, with - 1 row
per "group" (e.g., plate \* column, which is relevant to spot
outliers). - columns: `unique_curve_id`, `slope`, `r_squared`,
`adj_r_squared`, `lm_p`, `normality_lm_residuals`, `shapiro_p`,
`homoscedasticity_lm_residuals`, `breusch_pagan_p`

## Details

Formula within [`lm()`](https://rdrr.io/r/stats/lm.html). For linear
model: `y = m*x + c`; For polynomial model: `y = a*x^2 + b*x + c`;
With - y = blank-corrected absorbance - x = concentration - c = 0
because we use blank-corrected absorbance data

## Examples

``` r
data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_std_curve(data)
#> # A tibble: 10 × 11
#>    plate_id unique_curve_id std_sp  slope r_squared adj_r_squared     lm_p
#>    <chr>    <chr>           <chr>   <dbl>     <dbl>         <dbl>    <dbl>
#>  1 NO3_1F1  NO3_1F1_col1    NO3    0.0189     0.999         0.999 6.49e-11
#>  2 NO3_1F1  NO3_1F1_col12   NO3    0.0179     0.999         0.999 2.79e-10
#>  3 NO3_1F2  NO3_1F2_col1    NO3    0.0178     0.999         0.999 6.03e-11
#>  4 NO3_1F2  NO3_1F2_col12   NO3    0.0190     0.999         0.999 1.64e-10
#>  5 NO3_1F3  NO3_1F3_col1    NO3    0.0187     0.999         0.999 9.25e-11
#>  6 NO3_1F3  NO3_1F3_col12   NO3    0.0185     0.999         0.999 1.69e-10
#>  7 NO3_1F4  NO3_1F4_col1    NO3    0.0178     0.999         0.999 2.16e-10
#>  8 NO3_1F4  NO3_1F4_col12   NO3    0.0188     0.999         0.999 2.43e-10
#>  9 NO3_1F5  NO3_1F5_col1    NO3    0.0193     0.999         0.999 2.45e-10
#> 10 NO3_1F5  NO3_1F5_col12   NO3    0.0185     0.999         0.998 6.15e-10
#> # ℹ 4 more variables: normality_lm_residuals <chr>, shapiro_p <dbl>,
#> #   homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>
```
