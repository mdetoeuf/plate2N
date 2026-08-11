# Ridge-line density plot of values, grouped by sample

Plots a ridgeline density plot of a numeric column, split into one ridge
per group. This is the companion function to
[`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md):
a ridge plot is often the easiest way to visually spot an outlier, but
doesn't identify which well to remove — pair it with
[`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md),
which labels individual points by name, to find the well to pass to
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md).

## Usage

``` r
plot_ridges_values(
  data,
  value_col = "conc_mgN_L",
  groups_col = "sample_id",
  colour_col = NULL,
  y_col = "sample_id",
  scale = 1
)
```

## Arguments

- data:

  A tibble containing the columns referenced by `value_col`,
  `groups_col`, `y_col`, and (if used as a column name) `colour_col`.

- value_col:

  Name of the numeric column whose density is plotted. Defaults to
  `"conc_mgN_L"`, but this can equally be raw absorbance data if you'd
  rather spot outliers before inferring concentration (see
  [`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)
  for the same note on linear vs. polynomial models).

- groups_col:

  Name of the column defining groups (one ridge per unique value).
  Defaults to `"sample_id"` — replace with whatever column identifies
  your own sample units.

- colour_col:

  If `NULL`, all ridges are drawn in a single, uniform colour.
  Otherwise, either a literal colour name (applied to every ridge) or
  the name of a column in `data` used for colour/fill aesthetics (e.g.
  to distinguish ridges by run or batch). Defaults to `NULL`.

- y_col:

  Name of the column defining the vertical ridge position. Defaults to
  `"sample_id"`.

- scale:

  How far each ridge is allowed to visually extend beyond its own row
  (passed to
  [`ggridges::geom_density_ridges()`](https://wilkelab.org/ggridges/reference/geom_density_ridges.html)).
  Values above 1 let curves overlap into neighboring rows (the classic
  ridgeline look); values at or below 1 keep each curve within its own
  row, useful when ridges need to align precisely with the rows of a
  paired plot (see
  [`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)).
  Defaults to `1`.

## Value

A ggplot object.

## See also

[`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md),
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md)

## Examples

``` r
# plot_ridges_values(my_data, value_col = "co2_g_h", y_col = "plate_id")
```
