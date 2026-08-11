# Interleave plots with spacer panels for visual gaps in patchwork layouts

A small utility for adding a visible gap between plots combined with
`patchwork`. Simply increasing `plot.margin` does not create a gap
between adjacent panels that each have their own background (e.g. a
border drawn via `plot.background`), since the background fills the
whole panel's allocated space regardless of margin. This function
instead inserts
[`patchwork::plot_spacer()`](https://patchwork.data-imaginist.com/reference/plot_spacer.html)
panels between the real plots, sized via
`patchwork::plot_layout(widths =)`/`heights =`.

## Usage

``` r
add_spacers(plots, gap_size = 0.002)
```

## Arguments

- plots:

  A list of plot/patchwork objects to interleave with spacers.

- gap_size:

  Relative size of each spacer panel, compared to a real plot's size of
  `1`. Defaults to `0.002` (a thin visual gap).

## Value

A list with two elements: `plots` (the interleaved list, spacers
included) and `sizes` (the matching relative-size vector), ready to pass
to `patchwork::wrap_plots(result$plots)` and
`patchwork::plot_layout(widths = result$sizes)` (or `heights =` for a
vertical arrangement).

## Examples

``` r
# spaced <- add_spacers(list(plot1, plot2, plot3))
# patchwork::wrap_plots(spaced$plots, nrow = 1) +
#   patchwork::plot_layout(widths = spaced$sizes)
```
