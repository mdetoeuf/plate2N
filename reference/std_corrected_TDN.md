# Blank-corrected standard curve data for a Total Dissolved Nitrogen (TDN) experiment

Example dataset illustrating a case where a polynomial model fits better
than a linear one: standard curve concentrations were increased ten-fold
compared to a typical N-dosage experiment, producing highly concentrated
solutions and absorbance values above 3. Used throughout the
`abs-to-conc` vignette to illustrate choosing between a linear and
polynomial model, and as example data for
[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md),
[`plot_model_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_model_comparison.md),
[`plot_residual_comparison()`](https://mdetoeuf.github.io/plate2N/reference/plot_residual_comparison.md),
and
[`review_model_choice()`](https://mdetoeuf.github.io/plate2N/reference/review_model_choice.md).

## Usage

``` r
std_corrected_TDN
```

## Format

A tibble with 224 rows and 13 columns:

- row:

  Well row letter (A-H) on the 96-well plate.

- column:

  Well column number (1-12) on the 96-well plate.

- well_id:

  Well identifier (row + column, e.g. "B1").

- unique_well_id:

  Well identifier combined with `plate_id`, unique across the dataset.

- dataset:

  Name of the dataset ("TDN" throughout).

- plate_id:

  Identifier of the physical plate.

- unique_curve_id:

  Identifier of the standard curve a well belongs to (a plate can hold
  more than one curve).

- map:

  Well mapping/type (e.g. "Std" for standard curve wells).

- abs_corrected:

  Blank-corrected absorbance.

- std_sp:

  Standard curve species/analyte (e.g. "NO3").

- std_unit:

  Unit of the standard curve concentration.

- date:

  Date of the measurement.

- std_conc:

  Standard curve concentration.

## Source

Example data included with the package for demonstration and testing
purposes.
