# Display one or more standard curve(s)

Plots raw absorbance (y-axis) vs concentration (x-axis), grouping the
data by `plate_id`. Uses the `ggplot2` package.

## Usage

``` r
plot_std(
  std_data,
  through_origin = TRUE,
  model = "linear",
  conc_col = "std_conc",
  value_col = "abs",
  group_col = "column",
  colour_col = NULL,
  label_col = "well_id",
  unit_col = NULL,
  smooth_alpha = 0.3,
  smooth_linewidth = 0.5,
  smooth_linetype = 2
)
```

## Arguments

- std_data:

  The table containing the data to be plotted. Must contain the columns
  referenced by `conc_col`, `value_col`, `group_col`, `label_col`, and
  `unit_col`. If the plot shows too many curves, consider filtering the
  input data frame or adding a ggplot layer to facet (see
  `?facet_wrap()` or `?facet_grid()`).

- through_origin:

  Whether the smooth curve should be constrained to go through the
  origin. Default to TRUE, which only makes sense for absorbance data
  that has already been blank-corrected

- model:

  Which model to use for the smooth curve. Accepts either `linear`
  (default) or `poly` for polynomial model (y = ax + bx^2 + c, with c =
  0 if `through_origin = TRUE`)

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

- value_col:

  Name of the column containing absorbance. Defaults to `"abs"`.

- group_col:

  Name of the column used to group/colour/fill curves (e.g. one curve
  per plate). Defaults to `"column"`.

- colour_col:

  Name of the column used for colour/fill. If `NULL` (the default), uses
  `group_col` (same variable drives both grouping and colour, as
  originally). Set independently to colour by something else meaningful
  (e.g. date, dilution factor) while still fitting one regression line
  per `group_col`.

- label_col:

  Name of the column used to label individual points. Defaults to
  `"well_id"`.

- unit_col:

  Optional: how to label the concentration unit on the x-axis. `NULL`
  (the default) shows no unit at all. Otherwise, either the name of a
  column in `std_data` to read the unit from, or a literal string (e.g.
  `"mg/L"`) applied uniformly.

- smooth_alpha:

  Transparency of the fitted smooth-curve ribbon/line. Defaults to
  `0.3`.

- smooth_linewidth:

  Width of the fitted smooth-curve line. Defaults to `0.5`.

- smooth_linetype:

  Line type of the fitted smooth-curve line (`ggplot2` linetype code).
  Defaults to `2` (dashed).

## Value

A plot of one or several standard curves.

## Examples

``` r
raw_meta <- tidy_plates |>
    dplyr::left_join(metadata, by = dplyr::join_by(dataset,plate_id))
curve_concentration <- extract_curve(metadata)
std_data <- raw_meta |>
  extract_std_data() |>
  dplyr::select(!std_conc) |>
  dplyr::left_join(curve_concentration, by = dplyr::join_by(row, dataset, plate_id))
plot_std(std_data, through_origin = FALSE, model = "linear", unit_col = "std_unit") +
  ggplot2::facet_wrap(dataset~plate_id)
```
