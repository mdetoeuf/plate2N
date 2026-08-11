# Build per-sample QC plots (boxplot + ridgeline pairs), paginated

Splits `data` into evenly-sized chunks of samples and builds a
[`plot_qc_sample_pair()`](https://mdetoeuf.github.io/plate2N/reference/plot_qc_sample_pair.md)
figure for each chunk, combining them side by side (with a small visual
gap between chunks) into one figure. This is the per-sample analog of
[`plot_list_qc_microresp()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_qc_microresp.md),
generalized beyond MicroResp: use it for any per-sample outlier-QC step
(e.g. abs-to-conc's downstream per-sample averaging).

## Usage

``` r
plot_list_qc_samples(
  data,
  y_col,
  value_col = "conc_mgN_L",
  colour_col = NULL,
  n_chunks = NULL,
  max_samples_per_chunk = 25,
  value_range = NULL,
  scale = 0.8,
  gap_size = 0.002,
  legend_position = "none",
  title = NULL
)
```

## Arguments

- data:

  A tibble containing the columns referenced by `y_col`, `value_col`,
  and (if given) `colour_col`.

- y_col:

  Name of the column identifying samples.

- value_col:

  Name of the numeric column to visualize. Defaults to `"conc_mgN_L"`,
  but can be set to any per-sample numeric value (e.g. raw or
  blank-corrected absorbance) for reuse beyond this default.

- colour_col:

  Optional colour: `NULL` for a default colour, a literal colour name,
  or the name of a column in `data` — passed through to every pair.

- n_chunks:

  Number of chunks (pages/panels) to split samples into. If `NULL` (the
  default), computed from `max_samples_per_chunk` instead.

- max_samples_per_chunk:

  Maximum number of samples per chunk, used to compute `n_chunks` when
  it isn't given directly. Ignored if `n_chunks` is given. Defaults to
  `25`.

- value_range:

  A length-2 numeric vector giving the shared value-axis range across
  all chunks, so samples are compared fairly regardless of which chunk
  they land in. If `NULL` (the default), computed from
  `data[[value_col]]`'s own range — pass this explicitly instead (e.g.
  computed from an unfiltered dataset) when comparing two versions of
  the same data side by side (such as before/after outlier removal), so
  both use the same scale.

- scale:

  Passed to
  [`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md)
  via each pair. Defaults to `0.8`.

- gap_size:

  Relative width of the visual gap between chunks, passed to
  [`add_spacers()`](https://mdetoeuf.github.io/plate2N/reference/add_spacers.md).
  Defaults to `0.002`.

- legend_position:

  Standard `ggplot2` `legend.position` value (e.g. `"none"`, `"right"`,
  `"bottom"`, `"left"`, `"top"`), applied to both the boxplot and the
  ridge, with duplicate legends automatically collected into one shared
  legend for the pair. Defaults to `"none"` (no legend shown).

- title:

  Optional title, passed to every pair (identical across chunks).
  Defaults to `y_col`'s name if not given.

## Value

A single combined `patchwork` figure (one row, one pair-panel per chunk,
evenly spaced) — ready to have an overall title added via
`+ patchwork::plot_annotation(title = "...")`.

## See also

[`plot_qc_sample_pair()`](https://mdetoeuf.github.io/plate2N/reference/plot_qc_sample_pair.md),
[`plot_list_qc_microresp()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_qc_microresp.md)

## Examples

``` r
# qc_plot <- plot_list_qc_samples(my_data, y_col = "sample_id", colour_col = "zone") +
#   patchwork::plot_annotation(title = "NO3")
```
