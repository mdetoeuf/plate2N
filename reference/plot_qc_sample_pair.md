# Boxplot + ridgeline pair for one chunk of samples

Builds one combined QC figure for a chunk of samples: a labelled boxplot
([`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md))
next to a ridgeline density plot
([`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md)),
sharing one centered axis of sample identities between them. The ridge
makes it easy to spot an outlier at a glance; the paired boxplot then
gives you the exact well_id to remove via
[`remove_wells()`](https://mdetoeuf.github.io/plate2N/reference/remove_wells.md).
The whole pair is enclosed in a border box. Typically built once per
chunk of samples by
[`plot_list_qc_samples()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_qc_samples.md)
rather than called directly.

## Usage

``` r
plot_qc_sample_pair(
  chunk,
  data,
  y_col,
  value_col,
  value_range,
  colour_col = NULL,
  scale = 0.8,
  title = NULL,
  border_colour = "grey80"
)
```

## Arguments

- chunk:

  A vector of values of `y_col` to include in this pair (one "page"
  worth of samples).

- data:

  A tibble containing the columns referenced by `y_col`, `value_col`,
  and (if given) `colour_col`.

- y_col:

  Name of the column identifying samples — shared between the boxplot
  and the ridge plot as the row/category axis.

- value_col:

  Name of the numeric column to visualize.

- value_range:

  A length-2 numeric vector giving the shared value-axis range to use,
  so samples can be compared fairly regardless of which chunk they land
  in. Typically computed once (across the whole dataset) by
  [`plot_list_qc_samples()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_qc_samples.md)
  and passed down.

- colour_col:

  Optional colour: `NULL` for a default colour, a literal colour name,
  or the name of a column in `data` — passed through to both
  [`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md)
  and
  [`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md).

- scale:

  Passed to
  [`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md)
  — how far each ridge extends beyond its own row. Defaults to `0.8`,
  which keeps ridges close enough to their row to stay visually aligned
  with the paired boxplot.

- title:

  Optional title for this pair, shown centered above the shared axis.
  Defaults to `y_col`'s name if not given.

- border_colour:

  Colour of the border box drawn around the pair. Defaults to
  `"grey80"`.

## Value

A single combined plot (a flattened `patchwork` object).

## See also

[`plot_list_qc_samples()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_qc_samples.md),
[`boxplot_values()`](https://mdetoeuf.github.io/plate2N/reference/boxplot_values.md),
[`plot_ridges_values()`](https://mdetoeuf.github.io/plate2N/reference/plot_ridges_values.md)

## Examples

``` r
# plot_qc_sample_pair(
#   chunk = c("s1", "s2"), data = my_data,
#   y_col = "sample_id", value_col = "conc_mgN_L",
#   value_range = c(0, 10))
```
