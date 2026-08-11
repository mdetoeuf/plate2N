# Boxplot of values by sample, with optional colour and point labels

Plots a boxplot of a numeric column, grouped by sample on the x-axis,
with individual points overlaid and labelled by name (labels placed via
`ggrepel` to avoid overlap). This is the companion function to
[`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md):
a ridgeline plot is often the easier way to visually spot an outlier,
but doesn't tell you which well to remove — this boxplot does, since
each point is labelled, so the labelled outlier can be passed directly
to
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md).

## Usage

``` r
boxplot_values(
  data,
  x_col = "sample_id",
  value_col = "conc_mgN_L",
  colour_col = NULL,
  label_col = "well_id"
)
```

## Arguments

- data:

  A tibble containing the columns referenced by `x_col`, `value_col`,
  `label_col`, and (if used as a column name) `colour_col`.

- x_col:

  Name of the column identifying samples, plotted on the x-axis (coerced
  to a factor). Defaults to `"sample_id"` — replace with whatever column
  identifies your own sample units.

- value_col:

  Name of the numeric column plotted on the y-axis. Defaults to
  `"conc_mgN_L"`, but this can equally be raw absorbance data (e.g.
  `"abs"` or `"abs_corrected"`) if you'd rather spot outliers before
  inferring concentration. For a linear model this gives identical
  results either way; for a polynomial model, averaging absorbance
  before vs. after concentration inference isn't exactly equivalent
  (though the difference is typically small).

- colour_col:

  If `NULL` (the default), all points are coloured `"purple"`.
  Otherwise, either a literal colour name (applied to every point) or
  the name of a column in `data`, in which case points are coloured
  according to that column's values.

- label_col:

  Name of the column used to label individual points. Defaults to
  `"well_id"`.

## Value

A ggplot object.

## See also

[`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md),
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md)

## Examples

``` r
# boxplot_values(my_data, x_col = "plate_id", value_col = "co2_g_h")
```
