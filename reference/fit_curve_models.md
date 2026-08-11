# Fit both linear and polynomial models for one standard curve

Fits two models relating absorbance to concentration for a single
standard curve, both forced through the origin (blank-corrected
absorbance should read zero at zero concentration): a linear model
(`value ~ 0 + conc`) and a polynomial model
(`value ~ 0 + conc + I(conc^2)`). Used to help decide which model fits
better for a given dataset — see
[`plot_model_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_model_comparison.md)
and
[`plot_residual_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_residual_comparison.md)
to visualize the two fits, or
[`review_model_choice()`](https://mdetoeuf.github.io/plate2N/reference/review_model_choice.md)
to do this across several curves at once.

## Usage

``` r
fit_curve_models(
  curve_data,
  conc_col = "std_conc",
  value_col = "abs_corrected",
  through_origin = TRUE
)
```

## Arguments

- curve_data:

  A tibble containing data for a single standard curve (e.g. one
  `unique_curve_id`), with the columns referenced by `conc_col` and
  `value_col`.

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

- value_col:

  Name of the column containing (blank-corrected) absorbance. Defaults
  to `"abs_corrected"`.

- through_origin:

  Whether to force both models through the origin (`0 +` in the model
  formula). Defaults to `TRUE`, appropriate when blank-corrected
  absorbance should read zero at zero concentration. Set to `FALSE` if
  that assumption doesn't hold for your data (e.g. if the standard curve
  and samples share the same blank, matching
  [`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)'s
  own `through_origin` argument).

## Value

A named list with two elements, `linear` and `poly`, each an `lm` model
object.

## See also

[`plot_model_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_model_comparison.md),
[`plot_residual_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_residual_comparison.md),
[`review_model_choice()`](https://mdetoeuf.github.io/plate2N/reference/review_model_choice.md)

## Examples

``` r
curve <- std_corrected_TDN |>
  dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
models <- fit_curve_models(curve)
summary(models$linear)
#> 
#> Call:
#> stats::lm(formula = stats::reformulate(terms, response = value_col), 
#>     data = curve_data)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -0.18370  0.04129  0.10244  0.13621  0.20977 
#> 
#> Coefficients:
#>           Estimate Std. Error t value Pr(>|t|)    
#> std_conc 0.0124279  0.0004877   25.48 2.41e-07 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 0.1477 on 6 degrees of freedom
#> Multiple R-squared:  0.9908, Adjusted R-squared:  0.9893 
#> F-statistic: 649.5 on 1 and 6 DF,  p-value: 2.405e-07
#> 
summary(models$poly)
#> 
#> Call:
#> stats::lm(formula = stats::reformulate(terms, response = value_col), 
#>     data = curve_data)
#> 
#> Residuals:
#>         1         2         3         4         5         6         7 
#> -0.003064  0.023935  0.025124  0.021264  0.002595 -0.028541  0.011591 
#> 
#> Coefficients:
#>                 Estimate Std. Error t value Pr(>|t|)    
#> std_conc       1.672e-02  2.846e-04   58.75 2.70e-08 ***
#> I(std_conc^2) -2.127e-05  1.360e-06  -15.64 1.94e-05 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 0.0229 on 5 degrees of freedom
#> Multiple R-squared:  0.9998, Adjusted R-squared:  0.9997 
#> F-statistic: 1.363e+04 on 2 and 5 DF,  p-value: 4.551e-10
#> 
```
