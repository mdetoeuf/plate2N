# Plot residuals of linear vs. polynomial models for one curve

Compares how each model's residuals scatter around zero across the range
of concentrations, for one standard curve. Residuals close to zero with
no systematic pattern indicate a good fit; a curved or systematic
pattern (typically in the linear model's residuals, when a polynomial
fit is actually needed) is a sign that model doesn't capture the true
shape of the curve.

## Usage

``` r
plot_residual_comparison(curve_data, models, conc_col = "std_conc")
```

## Arguments

- curve_data:

  A tibble with data for the curve, with the column referenced by
  `conc_col`. Must be the same data used to fit `models` (same row
  order/count) — e.g. via
  [`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md).
  Note: if `curve_data` contains rows with `NA` in the fitted
  value/concentration columns, [`lm()`](https://rdrr.io/r/stats/lm.html)
  silently drops them, which can misalign residuals against
  `curve_data`'s concentration values here. Not currently guarded
  against — worth keeping curve data free of `NA`s in the relevant
  columns.

- models:

  A named list with `linear` and `poly` elements, each an `lm` model
  object — typically the output of
  [`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md).

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

## Value

A ggplot object.

## See also

[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md),
[`plot_model_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_model_comparison.md)

## Examples

``` r
curve <- std_corrected_TDN |>
  dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
models <- fit_curve_models(curve)
plot_residual_comparison(curve, models)

# add a connecting line between points, e.g. useful when reviewing
# several curves at once (see review_model_choice())
plot_residual_comparison(curve, models) + ggplot2::geom_line(alpha = 0.5)
```
