# Plot linear and polynomial model fits side by side for one or more curves

Wraps
[`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md),
called once with `model = "linear"` and once with `model = "poly"`,
combined side by side.
[`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)
fits its own model internally purely for drawing — this function doesn't
use
[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md)'s
output, since that's a separate (if equivalent) fit done for a different
purpose (inspecting the actual model object, e.g. for
[`plot_residual_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_residual_comparison.md)).

## Usage

``` r
plot_model_comparison(
  curve_data,
  conc_col = "std_conc",
  value_col = "abs_corrected",
  curve_id_col = "unique_curve_id",
  colour_col = NULL,
  through_origin = TRUE,
  unit_col = NULL,
  smooth_alpha = 0.3,
  smooth_linewidth = 0.5,
  smooth_linetype = 2,
  legend_position = "right"
)
```

## Arguments

- curve_data:

  A tibble with data for one curve, or several curves at once
  (grouped/coloured by `curve_id_col`) if you want an overplotted
  comparison across multiple curves.

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

- value_col:

  Name of the column containing (blank-corrected) absorbance. Defaults
  to `"abs_corrected"`.

- curve_id_col:

  Name of the column identifying which curve a row belongs to, used for
  grouping/colouring. Defaults to `"unique_curve_id"`.

- colour_col:

  Name of the column used for colour/fill. If `NULL` (the default), uses
  `curve_id_col`. Set independently to colour by something more
  meaningful when comparing several curves at once (e.g. date, dilution
  factor).

- through_origin:

  Whether to force both fits through the origin. Defaults to `TRUE`. See
  [`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md)
  for the same argument's meaning.

- unit_col:

  Passed through to
  [`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)
  — optionally shows a concentration unit on the x-axis. `NULL` (the
  default) shows no unit. See
  [`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)'s
  own `unit_col` argument for the full behavior (literal string or
  column name).

- smooth_alpha, smooth_linewidth, smooth_linetype:

  Passed through to
  [`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)
  — control the fitted smooth-curve's visibility. Defaults match
  [`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)'s
  own defaults.

- legend_position:

  Standard `ggplot2` `legend.position` value for the colour legend.
  Defaults to `"none"`. Only meaningful when `colour_col` (or the
  default curve-id grouping) produces a legend worth showing — e.g. when
  comparing multiple curves at once via
  [`review_model_choice()`](https://mdetoeuf.github.io/plate2N/reference/review_model_choice.md)'s
  `overplot = TRUE` mode.

## Value

A combined `patchwork` figure (linear model plot next to polynomial
model plot).

## See also

[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md),
[`plot_residual_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_residual_comparison.md),
[`plot_std()`](https://mdetoeuf.github.io/plate2N/reference/plot_std.md)

## Examples

``` r
curve <- std_corrected_TDN |>
  dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
plot_model_comparison(curve, unit_col = "std_unit")
```
