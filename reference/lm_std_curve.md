# Perform Linear Model for Standard Curve

The linear model is based on the function
[`lm()`](https://rdrr.io/r/stats/lm.html) and fits the curve to go
through the origin (0,0), which only makes sense for blank-corrected
absorbance data.

## Usage

``` r
lm_std_curve(
  grouped_data,
  model = "linear",
  conc_col = "std_conc",
  value_col = "abs_corrected",
  curve_id_col = "unique_curve_id",
  dataset_col = "dataset",
  plate_id_col = "plate_id",
  std_sp_col = "std_sp",
  through_origin = TRUE
)
```

## Arguments

- grouped_data:

  A tibble, grouped per curve (e.g., use
  `dplyr::group_by(plate_id, column)` on your data before calling the
  function). Grouping is now applied internally by `curve_id_col`, so
  pre-grouping is no longer strictly required — but harmless if already
  grouped. Must contain the columns referenced by `conc_col`,
  `value_col`, `curve_id_col`, `dataset_col`, `plate_id_col`, and
  `std_sp_col`.

- model:

  Which model to use. Accepts either `linear` (default) or `poly` for
  polynomial model.

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

- value_col:

  Name of the column containing (blank-corrected) absorbance. Defaults
  to `"abs_corrected"`.

- curve_id_col:

  Name of the column identifying which curve a row belongs to. Defaults
  to `"unique_curve_id"`.

- dataset_col:

  Name of the column identifying the dataset. Defaults to `"dataset"`.

- plate_id_col:

  Name of the column identifying physical plates. Defaults to
  `"plate_id"`.

- std_sp_col:

  Name of the column identifying the standard species. Defaults to
  `"std_sp"`.

- through_origin:

  Whether to force the model through the origin. Defaults to `TRUE`. See
  [`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md)
  for the same argument's meaning.

## Value

A table containing relevant parameters of the linear model, with - 1 row
per "group" (e.g., plate \* column, which is relevant to spot
outliers). - columns: `unique_curve_id`, `slope`, `r_squared`,
`adj_r_squared`, `lm_p`, `normality_lm_residuals`, `shapiro_p`,
`homoscedasticity_lm_residuals`, `breusch_pagan_p`. When
`model = "poly"`, also `poly_a`/`poly_a_p` (the squared, `x^2`, term's
coefficient and p-value) and `poly_b`/`poly_b_p` (the linear, `x`,
term's coefficient and p-value).

## Details

Formula within [`lm()`](https://rdrr.io/r/stats/lm.html). For linear
model: `y = m*x + c`; For polynomial model: `y = a*x^2 + b*x + c`;
With - y = blank-corrected absorbance - x = concentration - c = 0
because we use blank-corrected absorbance data

Fitting itself is delegated to
[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md)
(the same function used by the `model-choice` toolkit), with diagnostic
statistics computed by
[`lm_diagnostics()`](https://mdetoeuf.github.io/plate2N/reference/lm_diagnostics.md)
— call that directly if you only need diagnostics for a single
already-fitted model.

## See also

[`fit_curve_model()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_model.md),
[`lm_diagnostics()`](https://mdetoeuf.github.io/plate2N/reference/lm_diagnostics.md)

## Examples

``` r
data <- std_corrected |> dplyr::group_by(plate_id, column)
lm_std_curve(data)
#> # A tibble: 10 × 12
#>    dataset plate_id unique_curve_id std_sp  slope r_squared adj_r_squared
#>    <chr>   <chr>    <chr>           <chr>   <dbl>     <dbl>         <dbl>
#>  1 Nmin    NO3_1F1  NO3_1F1_col1    NO3    0.0189     0.999         0.999
#>  2 Nmin    NO3_1F1  NO3_1F1_col12   NO3    0.0179     0.999         0.999
#>  3 Nmin    NO3_1F2  NO3_1F2_col1    NO3    0.0178     0.999         0.999
#>  4 Nmin    NO3_1F2  NO3_1F2_col12   NO3    0.0190     0.999         0.999
#>  5 Nmin    NO3_1F3  NO3_1F3_col1    NO3    0.0187     0.999         0.999
#>  6 Nmin    NO3_1F3  NO3_1F3_col12   NO3    0.0185     0.999         0.999
#>  7 Nmin    NO3_1F4  NO3_1F4_col1    NO3    0.0178     0.999         0.999
#>  8 Nmin    NO3_1F4  NO3_1F4_col12   NO3    0.0188     0.999         0.999
#>  9 Nmin    NO3_1F5  NO3_1F5_col1    NO3    0.0193     0.999         0.999
#> 10 Nmin    NO3_1F5  NO3_1F5_col12   NO3    0.0185     0.999         0.998
#> # ℹ 5 more variables: lm_p <dbl>, normality_lm_residuals <chr>,
#> #   shapiro_p <dbl>, homoscedasticity_lm_residuals <chr>, breusch_pagan_p <dbl>
```
