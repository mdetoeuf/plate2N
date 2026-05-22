# abs-to-conc

``` r

library(plate2N)
```

> **Work in progress**
>
> This vignette is still under development, bugs are to be expected

## Introduction

In this vignette, we cover the steps from blank-corrected absorbance to
concentration in nitrogen \[mg N / L\], although this can easily be used
for dosing other molecules, as long as the Beer-Lambert equation is
respected (the relationship between absorbance and concentration is
linear)[^1].

> **Prerequisites**
>
> - data has been imported and tidied, see
>   [`vignette("import-tidy", package = "plate2N")`](https://mdetoeuf.github.io/plate2N/articles/import-tidy.md)
>
> - data has been blank-corrected, see
>   [`vignette("blank-correction", package = "plate2N")`](https://mdetoeuf.github.io/plate2N/articles/blank-correction.md)
>
> - Outliers have been removed throughout that process, see previous
>   vignettes and also
>   [`vignette("handling-outliers", package = "plate2N")`](https://mdetoeuf.github.io/plate2N/articles/handling-outliers.md)

## 1 - Get blank-corrected data

Little reminder how how the blank-corrected data looks like (see
prerequisites)

``` r

sample_corrected
#> # A tibble: 264 × 25
#>    row   column well_id unique_well_id dataset plate_id map      abs_corrected
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>            <dbl>
#>  1 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2        0.0312
#>  2 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1        0.0249
#>  3 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3        0.0104
#>  4 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1        0.0342
#>  5 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1        0.0832
#>  6 A     3      A3      A3_NO3_1F1     Nmin    NO3_1F1  82_t1_z2        0.0452
#>  7 A     3      A3      A3_NO3_1F2     Nmin    NO3_1F2  98_t1_z1        0.0219
#>  8 A     3      A3      A3_NO3_1F3     Nmin    NO3_1F3  90_t1_z3        0.0124
#>  9 A     3      A3      A3_NO3_1F4     Nmin    NO3_1F4  82_t1_z3        0.0543
#> 10 A     3      A3      A3_NO3_1F5     Nmin    NO3_1F5  98_t1_z3        0.0232
#> # ℹ 254 more rows
#> # ℹ 17 more variables: blank_sdev <dbl>, blank_coeff_var_percent <dbl>,
#> #   date <lgl>, time <lgl>, sampling_time <chr>, std_column <chr>,
#> #   std_sp <chr>, std_unit <chr>, std_prep <chr>, std_conc <chr>,
#> #   sample_dilution <chr>, extractant_column <lgl>, extractant_sp <chr>,
#> #   extractant_unit <chr>, extractant_conc <dbl>, empty_column <lgl>,
#> #   wait_min <chr>

std_corrected
#> # A tibble: 70 × 26
#>    row   column well_id unique_well_id dataset plate_id unique_curve_id map  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>           <chr>
#>  1 B     1      B1      B1_NO3_1F1     Nmin    NO3_1F1  NO3_1F1_col1    Std  
#>  2 B     1      B1      B1_NO3_1F2     Nmin    NO3_1F2  NO3_1F2_col1    Std  
#>  3 B     1      B1      B1_NO3_1F3     Nmin    NO3_1F3  NO3_1F3_col1    Std  
#>  4 B     1      B1      B1_NO3_1F4     Nmin    NO3_1F4  NO3_1F4_col1    Std  
#>  5 B     1      B1      B1_NO3_1F5     Nmin    NO3_1F5  NO3_1F5_col1    Std  
#>  6 B     12     B12     B12_NO3_1F1    Nmin    NO3_1F1  NO3_1F1_col12   Std  
#>  7 B     12     B12     B12_NO3_1F2    Nmin    NO3_1F2  NO3_1F2_col12   Std  
#>  8 B     12     B12     B12_NO3_1F3    Nmin    NO3_1F3  NO3_1F3_col12   Std  
#>  9 B     12     B12     B12_NO3_1F4    Nmin    NO3_1F4  NO3_1F4_col12   Std  
#> 10 B     12     B12     B12_NO3_1F5    Nmin    NO3_1F5  NO3_1F5_col12   Std  
#> # ℹ 60 more rows
#> # ℹ 18 more variables: abs_corrected <dbl>, date <lgl>, time <lgl>,
#> #   sampling_time <chr>, std_column <chr>, std_sp <chr>, std_unit <chr>,
#> #   std_prep <chr>, sample_dilution <chr>, extractant_column <lgl>,
#> #   extractant_sp <chr>, extractant_unit <chr>, extractant_conc <dbl>,
#> #   empty_column <lgl>, wait_min <chr>, std_conc <chr>, blank_sdev <dbl>,
#> #   blank_coeff_var_percent <dbl>
```

## 2 - Compute linear model on Standard Curves

### lm_std_curve(), suspicious_lm() & plot_list_lm()

### reg_join_abs() & convert_molec()

### 2.1 - Compute linear model, round 1

### 2.2 - QC Standard curves - check conditions of linear model

### 2.3 - outlier removal

### 2.4 - Per-dilution averages (if 2+ curves per plate)

### 2.5 - Compute linear model + QC - round 2

### 2.6 - Multiple curve QC

## 3 - Infer sample concentration from regression equation

## 4 - Epilogue

[^1]: To adapt to other compounds, you may need to add molar masses into
    the data \`molar_masses\`, see later.
