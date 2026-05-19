# Display one or more standard curve(s)

Plots raw absorbance (y-axis) vs concentration (x-axis), grouping the
data by `plate_id`. Uses the `ggplot2` package.

## Usage

``` r
plot_std(std_data)
```

## Arguments

- std_data:

  The table containing the data to be plotted. Must contain the columns
  `std_conc`, `abs`, `plate_id` and `well_id`. If the plot shows too
  many curves, consider filtering the input data frame or adding a
  ggplot layer to facet (see `?facet_wrap()` or `?facet_grid()`).

## Value

A plot of one or several standard curves.

## Examples

``` r
data <- tidy_plates |> dplyr::left_join(metadata, by = dplyr::join_by(plate_id))
curve_concentration <- extract_curve(metadata)
std_data <- data |>
  extract_std_data() |>
  dplyr::select(!std_conc) |>
  dplyr::left_join(curve_concentration, by = dplyr::join_by(row, plate_id))
plot_std(std_data) + ggplot2::facet_wrap(~plate_id)
```
