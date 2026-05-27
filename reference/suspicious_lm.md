# Extract Suspicious Rows from Linear Model Data (non-significance, Non-normality, heteroscedasticity)

This "bad" subset of linear model data (regression of standard curves)
is useful in the case of numerous standard curves. It facilitates
individual review of suspicious curves only.

## Usage

``` r
suspicious_lm(lm_data)
```

## Arguments

- lm_data:

  A tible containing data from the linear model. Structured as the
  output of
  [`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md)

## Value

A tible same structure as lm_data, but contains only "suspicious"
standard curves

## See also

[`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md)

[`plot_list_lm()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_lm.md)

## Examples

``` r
data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_data <- lm_std_curve(data)
suspicious_lm(lm_data)
#> # A tibble: 10 × 10
#>    plate_id unique_curve_id  slope r_squared adj_r_squared     lm_p
#>    <chr>    <chr>            <dbl>     <dbl>         <dbl>    <dbl>
#>  1 NO3_1F1  NO3_1F1_col1    0.0189     0.999         0.999 6.49e-11
#>  2 NO3_1F1  NO3_1F1_col12   0.0179     0.999         0.999 2.79e-10
#>  3 NO3_1F2  NO3_1F2_col1    0.0178     0.999         0.999 6.03e-11
#>  4 NO3_1F2  NO3_1F2_col12   0.0190     0.999         0.999 1.64e-10
#>  5 NO3_1F3  NO3_1F3_col1    0.0186     0.999         0.999 2.07e-10
#>  6 NO3_1F3  NO3_1F3_col12   0.0184     0.999         0.999 4.07e-10
#>  7 NO3_1F4  NO3_1F4_col1    0.0178     0.999         0.999 2.16e-10
#>  8 NO3_1F4  NO3_1F4_col12   0.0188     0.999         0.999 2.43e-10
#>  9 NO3_1F5  NO3_1F5_col1    0.0194     0.999         0.999 1.31e-10
#> 10 NO3_1F5  NO3_1F5_col12   0.0185     0.999         0.999 3.49e-10
#> # ℹ 4 more variables: normality_lm_residuals <chr>, shapiro_p <dbl>,
#> #   homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>
```
