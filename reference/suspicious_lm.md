# Extract Suspicious Rows from Linear Model Data (non-significance, Non-normality, heteroscedasticity)

This "bad" subset of linear model data (regression of standard curves)
is useful in the case of numerous standard curves. It facilitates
individual review of suspicious curves only.

## Usage

``` r
suspicious_lm(lm_data, model = "linear")
```

## Arguments

- lm_data:

  A tible containing data from the linear model. Structured as the
  output of
  [`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md)

- model:

  Which model to use. Accepts either `linear` (default) or `poly` for
  polynomial model.

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
#> # A tibble: 1 × 12
#>   dataset plate_id unique_curve_id std_sp  slope r_squared adj_r_squared
#>   <chr>   <chr>    <chr>           <chr>   <dbl>     <dbl>         <dbl>
#> 1 Nmin    NO3_1F1  NO3_1F1_col12   NO3    0.0179     0.999         0.999
#> # ℹ 5 more variables: lm_p <dbl>, normality_lm_residuals <chr>,
#> #   shapiro_p <dbl>, homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>
```
