# Example of Outputs from the Linear Model of the Standard Curves

Example of Outputs from the Linear Model of the Standard Curves

## Usage

``` r
lm_output
```

## Format

List containing 3 elements, computed with
[`lm_std_curve()`](https://mdetoeuf.github.io/plate2N/reference/lm_std_curve.md),
[`suspicious_lm()`](https://mdetoeuf.github.io/plate2N/reference/suspicious_lm.md)
and
[`plot_list_lm()`](https://mdetoeuf.github.io/plate2N/reference/plot_list_lm.md).

- lm_data:

  Tibble, 1 row per curve, serves as summary for the linear model

- suspicious_lm:

  Subset of `lm_data`, keeping only "problematic" curves, i.e., either
  with p-value \> 0.5, or with non-normality or heteroscedasticity of
  residuals

- plot_list_suspicious:

  A list of ggplots displaying those problematic curves (only one plot
  in this data set)
