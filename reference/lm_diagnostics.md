# Compute diagnostic statistics for a fitted standard curve model

Extracts diagnostic statistics from an already-fitted model: R²,
adjusted R², overall model p-value, tests of residual normality
(Shapiro-Wilk) and homoscedasticity (Breusch-Pagan), and, for polynomial
models, the individual coefficients and their p-values —
`poly_a`/`poly_a_p` for the squared (`x²`) term, `poly_b`/`poly_b_p` for
the linear (`x`) term. Used internally by
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

A one-row tibble of diagnostic statistics.

## See also

[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md),
[`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md)

## Examples

``` r
curve <- std_corrected |> dplyr::filter(unique_curve_id == unique(std_corrected$unique_curve_id)[1])
model <- fit_curve_model(curve, model = "linear")
lm_diagnostics(model, model_type = "linear")
#> # A tibble: 1 × 8
#>    slope r_squared adj_r_squared     lm_p normality_lm_residuals shapiro_p
#>    <dbl>     <dbl>         <dbl>    <dbl> <chr>                      <dbl>
#> 1 0.0189     0.999         0.999 6.49e-11 Normal                     0.836
#> # ℹ 2 more variables: homoscedasticity_lm_residuals <chr>,
#> #   breusch_pagan_p <dbl>
```
