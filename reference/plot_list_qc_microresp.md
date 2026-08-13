# Build per-substrate/treatment QC plots for MicroResp data, paginated into panels

For each unique value of `map_col` (e.g. one substrate, treatment, or
other layer's category), builds a combined boxplot
([`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)) +
ridgeline
([`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md))
QC plot, split into manageable panels — either by an existing
panel-defining column (`panel_col`, e.g. a run or batch identifier), or,
if none is given, into automatically-sized chunks of at most
`max_plates_per_panel` plates. Panels are assembled side by side using
the `patchwork` package.

## Usage

``` r
plot_list_qc_microresp(
  data,
  map_col = "map",
  plate_id_col = "plate_id",
  value_col = "co2_g_h",
  label_col = "well_id",
  panel_col = NULL,
  dataset_col = "dataset",
  max_plates_per_panel = 10
)
```

## Arguments

- data:

  A tibble containing the columns referenced by `map_col`,
  `plate_id_col`, `value_col`, `label_col`, `dataset_col`, and (if
  given) `panel_col`.

- map_col:

  Name of the column identifying substrates/treatments/layers for this
  call — one QC plot is produced per unique value, and the returned list
  has one entry per value (see `Value`). Defaults to `"map"`.

- plate_id_col:

  Name of the column identifying physical plates. Defaults to
  `"plate_id"`.

- value_col:

  Name of the numeric column to visualize. Defaults to `"co2_g_h"`, but
  can be set to any per-sample numeric value for reuse beyond MicroResp.

- label_col:

  Name of the column used to label individual points (passed through to
  [`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)).
  Defaults to `"well_id"`.

- panel_col:

  Optional name of a column defining how plates are split into panels
  (e.g. an experimental run or batch identifier). If given, one panel is
  produced per unique value, labelled accordingly, and ridges are
  coloured by that value. If `NULL` (the default), plates are
  automatically split into evenly-sized panels labelled "Panel X of Y",
  each capped at `max_plates_per_panel` plates, with ridges in a single
  uniform colour (no meaningful grouping to colour by in this case).

- dataset_col:

  Name of the column identifying the dataset, used only in plot titles.
  Defaults to `"dataset"`.

- max_plates_per_panel:

  Maximum number of plates shown per panel when `panel_col` is `NULL`,
  used to determine how many panels are needed
  (`ceiling(n_plates / max_plates_per_panel)`) — plates are then spread
  as evenly as possible across that many panels, so the last panel is
  never left with a small, oddly emphasized remainder. Ignored if
  `panel_col` is given. Defaults to `10`.

## Value

A named list of combined plots, one per unique value of `map_col`. If
`map_col` has several distinct values (e.g. several substrates), you'll
get one list entry — one full page of plots — per value.

## Details

If `data` has more than one column representing a distinct layer (e.g.
separate substrate and treatment columns), call this function once per
column, passing the relevant column name as `map_col` each time.

## See also

[`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md),
[`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md)

## Examples

``` r
# # plot_list_qc_microresp(MR_co2_g_h, panel_col = "run_id")
# plot_list_qc_microresp(MR_co2_g_h, max_plates_per_panel = 8)
```
