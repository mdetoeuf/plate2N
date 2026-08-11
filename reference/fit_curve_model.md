# Fit one model (linear or polynomial) for a single standard curve

The shared, single-model fitting logic behind
[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md)
(which fits both at once, for comparison purposes) — call this directly
if you only need one model type.

## Usage

``` r
fit_curve_model(
  curve_data,
  model = c("linear", "poly"),
  conc_col = "std_conc",
  value_col = "abs_corrected",
  through_origin = TRUE
)
```

## Arguments

- curve_data:

  A tibble containing data for a single standard curve, with the columns
  referenced by `conc_col` and `value_col`.

- model:

  Which model to fit: `"linear"` or `"poly"`.

- conc_col:

  Name of the column containing concentration. Defaults to `"std_conc"`.

- value_col:

  Name of the column containing (blank-corrected) absorbance. Defaults
  to `"abs_corrected"`.

- through_origin:

  Whether to force the model through the origin. Defaults to `TRUE`.

## Value

An `lm` model object.

## See also

[`fit_curve_models()`](https://mdetoeuf.github.io/plate2N/reference/fit_curve_models.md)

## Examples

``` r
curve <- std_corrected_TDN |>
  dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
fit_curve_model(curve, model = "poly")
#> 
#> Call:
#> stats::lm(formula = stats::reformulate(terms, response = value_col), 
#>     data = curve_data)
#> 
#> Coefficients:
#>      std_conc  I(std_conc^2)  
#>     1.672e-02     -2.127e-05  
#> 
```
