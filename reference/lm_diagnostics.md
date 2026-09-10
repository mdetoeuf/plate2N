# Compute diagnostic statistics for a fitted standard curve model

Extracts diagnostic statistics from an already-fitted model: R²,
adjusted R², overall model p-value, tests of residual normality
(Shapiro-Wilk) and homoscedasticity (Breusch-Pagan), and, for polynomial
models, the individual coefficients and their p-values —
`poly_a`/`poly_a_p` for the squared (`x²`) term, `poly_b`/`poly_b_p` for
the linear (`x`) term. Also extracts `intercept`/`intercept_p` whenever
the model was fitted with `through_origin = FALSE` (see
[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md))
— `NA` when the model was forced through the origin instead, since
there's no intercept term to report in that case. Used internally by
[`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md),
but can be called directly on any
[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md)
output.

## Usage

``` r
lm_diagnostics(model, model_type = c("linear", "poly"), conc_col = "std_conc")
```

## Arguments

- model:

  An `lm` model object, typically from
  [`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md).

- model_type:

  Which kind of model `model` is: `"linear"` or `"poly"` — determines
  whether polynomial-specific coefficients are extracted.

- conc_col:

  Name of the concentration term in the model's original formula, used
  to extract polynomial coefficients by name. Defaults to `"std_conc"`.
  Only relevant when `model_type = "poly"`.

## Value

A one-row tibble of diagnostic statistics, including
`intercept`/`intercept_p` (`NA` unless the model was fitted with
`through_origin = FALSE`).

## See also

[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md),
[`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md)

## Examples

``` r
curve <- std_corrected |> dplyr::filter(unique_curve_id == unique(std_corrected$unique_curve_id)[1])
model <- fit_curve_model(curve, model = "linear")
lm_diagnostics(model, model_type = "linear")
#> # A tibble: 1 × 10
#>    slope intercept intercept_p     lm_p r_squared adj_r_squared
#>    <dbl>     <dbl>       <dbl>    <dbl>     <dbl>         <dbl>
#> 1 0.0189        NA          NA 6.49e-11     0.999         0.999
#> # ℹ 4 more variables: normality_lm_residuals <chr>, shapiro_p <dbl>,
#> #   homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>

# a model not forced through the origin - intercept/intercept_p are
# real values rather than NA
model_free <- fit_curve_model(curve, model = "linear", through_origin = FALSE)
lm_diagnostics(model_free, model_type = "linear")
#> # A tibble: 1 × 10
#>    slope intercept intercept_p          lm_p r_squared adj_r_squared
#>    <dbl>     <dbl>       <dbl>         <dbl>     <dbl>         <dbl>
#> 1 0.0192  -0.00575      0.0346 0.00000000118     1.000         1.000
#> # ℹ 4 more variables: normality_lm_residuals <chr>, shapiro_p <dbl>,
#> #   homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>
```
