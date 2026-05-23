# Compute per-dilution Averages for Standard Curves

This needs better documentation!!

## Usage

``` r
std_dilution_average(std_data)
```

## Arguments

- std_data:

  A tibble of std data

## Value

Same, with less rows (bc average of same-dilution wells per plate).
Artificial column 13

## Examples

``` r
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
std_dilution_average(std_corrected)
#> # A tibble: 35 × 25
#> # Groups:   plate_id [5]
#>    plate_id row   column well_id unique_curve_id abs_mean dataset map   date 
#>    <chr>    <chr>  <dbl> <chr>   <chr>              <dbl> <chr>   <chr> <lgl>
#>  1 NO3_1F1  B         13 B13     NO3_1F1_col13    0.00700 Nmin    Std   NA   
#>  2 NO3_1F1  C         13 C13     NO3_1F1_col13    0.0145  Nmin    Std   NA   
#>  3 NO3_1F1  D         13 D13     NO3_1F1_col13    0.0295  Nmin    Std   NA   
#>  4 NO3_1F1  E         13 E13     NO3_1F1_col13    0.0645  Nmin    Std   NA   
#>  5 NO3_1F1  F         13 F13     NO3_1F1_col13    0.142   Nmin    Std   NA   
#>  6 NO3_1F1  G         13 G13     NO3_1F1_col13    0.293   Nmin    Std   NA   
#>  7 NO3_1F1  H         13 H13     NO3_1F1_col13    0.446   Nmin    Std   NA   
#>  8 NO3_1F2  B         13 B13     NO3_1F2_col13    0.00800 Nmin    Std   NA   
#>  9 NO3_1F2  C         13 C13     NO3_1F2_col13    0.0145  Nmin    Std   NA   
#> 10 NO3_1F2  D         13 D13     NO3_1F2_col13    0.0345  Nmin    Std   NA   
#> # ℹ 25 more rows
#> # ℹ 16 more variables: time <lgl>, sampling_time <chr>, std_column <chr>,
#> #   std_sp <chr>, std_unit <chr>, std_prep <chr>, sample_dilution <chr>,
#> #   extractant_column <lgl>, extractant_sp <chr>, extractant_unit <chr>,
#> #   extractant_conc <dbl>, empty_column <lgl>, wait_min <chr>, std_conc <chr>,
#> #   blank_sdev <dbl>, blank_coeff_var_percent <dbl>
```
