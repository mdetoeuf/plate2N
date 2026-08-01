# Build per-substrate/treatment QC plots for MicroResp data, paginated into panels

For each unique value of `map_col` (e.g. one substrate, treatment, or
other layer's category), builds a combined boxplot
([`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)) +
ridgeline
([`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md))
QC plot, split into manageable panels — either by an existing run/batch
identifier (`run_id_col`), or, if none is given, into
automatically-sized chunks of at most `max_plates_per_panel` plates.
Panels are assembled side by side using the `patchwork` package.

## Usage

``` r
plot_list_qc_microresp(
  data,
  map_col = "map",
  plate_id_col = "plate_id",
  value_col = "co2_g_h",
  label_col = "well_id",
  run_id_col = NULL,
  max_plates_per_panel = 10
)
```

## Arguments

- data:

  A tibble containing the columns referenced by `map_col`,
  `plate_id_col`, `value_col`, `label_col`, and (if given) `run_id_col`.
  Must also contain a `dataset` column (used only in plot titles).

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

- run_id_col:

  Optional name of a column identifying experimental runs/batches. If
  given, one panel is produced per run, labelled by run id, and ridges
  are coloured by run. If `NULL` (the default), plates are automatically
  split into evenly-sized panels labelled "Panel X of Y", each capped at
  `max_plates_per_panel` plates, with ridges in a single uniform colour
  (no meaningful grouping to colour by in this case).

- max_plates_per_panel:

  Maximum number of plates shown per panel when `run_id_col` is `NULL`,
  used to determine how many panels are needed
  (`ceiling(n_plates / max_plates_per_panel)`) — plates are then spread
  as evenly as possible across that many panels, so the last panel is
  never left with a small, oddly emphasized remainder. Ignored if
  `run_id_col` is given. Defaults to `10`.

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
# plot_list_qc_microresp(MR_co2_g_h, run_id_col = "run_id")
# plot_list_qc_microresp(MR_co2_g_h, max_plates_per_panel = 8)
```
