# Computing the per-plate average for raw absorbance of the extractant (blank for samples)

Computing the per-plate average for raw absorbance of the extractant
(blank for samples)

## Usage

``` r
extractant_average(data = NULL, extractant_data = NULL, extr_def = "extr")
```

## Arguments

- data:

  A tibble like `tidy_plates`

- extractant_data:

  Alternatively, A tibble containing only extractant data Defaults to
  NULL, where it would be computed from `data` using
  `extract_extractant(data)`

- extr_def:

  A string that characterizes wells containing the extractant in the
  mapping (`map`column) of the plate. Defaults to "extr". Can be a
  vector containing several values (see examples)

## Value

A tibble with one row per plate, contianing the average, standard
deviation and coefficient of variation of raw absorbance of the
extractant

## Examples

``` r
data = tidy_plates
(blank_avg <- extractant_average(data, extr_def = "extr"))
#> # A tibble: 5 × 6
#>   dataset plate_id map   blank_avg blank_sdev blank_coeff_var_percent
#>   <chr>   <chr>    <chr>     <dbl>      <dbl>                   <dbl>
#> 1 Nmin    NO3_1F1  extr     0.0828   0.000463                   0.559
#> 2 Nmin    NO3_1F2  extr     0.117    0.0657                    56.3  
#> 3 Nmin    NO3_1F3  extr     0.0846   0.00151                    1.78 
#> 4 Nmin    NO3_1F4  extr     0.0743   0.0268                    36.1  
#> 5 Nmin    NO3_1F5  extr     0.0838   0.000463                   0.553

# artificially construct a tibble with 2 extractants and an additional column for extractant id
tidy_2_extr <- tidy_plates |>
  dplyr::mutate(
    map = dplyr::case_when(
      column == 8 ~ "extr_1",
      column == 4 ~ "extr_2",
      .default = map))
multiple_extractant_id # check it out
#> # A tibble: 78 × 4
#>    dataset plate_id map      extr_id
#>    <chr>   <chr>    <chr>    <chr>  
#>  1 Nmin    NO3_1F1  Std      none   
#>  2 Nmin    NO3_1F2  Std      none   
#>  3 Nmin    NO3_1F3  Std      none   
#>  4 Nmin    NO3_1F4  Std      none   
#>  5 Nmin    NO3_1F5  Std      none   
#>  6 Nmin    NO3_1F1  81_t1_z2 extr_1 
#>  7 Nmin    NO3_1F2  97_t1_z1 extr_2 
#>  8 Nmin    NO3_1F3  89_t1_z3 extr_2 
#>  9 Nmin    NO3_1F4  81_t1_z1 extr_1 
#> 10 Nmin    NO3_1F5  Std_3_t1 extr_2 
#> # ℹ 68 more rows
# joining with multiple_extractant_id
(dbl_extr_plate <- tidy_2_extr |> dplyr::left_join(multiple_extractant_id))
#> Joining with `by = join_by(dataset, plate_id, map)`
#> # A tibble: 480 × 9
#>    row   column well_id unique_well_id dataset plate_id map      abs   extr_id
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr> <chr>  
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092 none   
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091 none   
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.110 none   
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092 none   
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.113 none   
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114 extr_1 
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107 extr_2 
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095 extr_2 
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118 extr_1 
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167 extr_2 
#> # ℹ 470 more rows
data <- dbl_extr_plate
(blank_avg <- extractant_average(data, extr_def = c("extr_1", "extr_2")))
#> # A tibble: 10 × 6
#>    dataset plate_id map    blank_avg blank_sdev blank_coeff_var_percent
#>    <chr>   <chr>    <chr>      <dbl>      <dbl>                   <dbl>
#>  1 Nmin    NO3_1F1  extr_1    0.0828   0.000463                   0.559
#>  2 Nmin    NO3_1F2  extr_1    0.117    0.0657                    56.3  
#>  3 Nmin    NO3_1F3  extr_1    0.0846   0.00151                    1.78 
#>  4 Nmin    NO3_1F4  extr_1    0.0743   0.0268                    36.1  
#>  5 Nmin    NO3_1F5  extr_1    0.0838   0.000463                   0.553
#>  6 Nmin    NO3_1F1  extr_2    0.101    0.00910                    9.01 
#>  7 Nmin    NO3_1F2  extr_2    0.0972   0.00539                    5.54 
#>  8 Nmin    NO3_1F3  extr_2    0.0974   0.00374                    3.84 
#>  9 Nmin    NO3_1F4  extr_2    0.111    0.00362                    3.26 
#> 10 Nmin    NO3_1F5  extr_2    0.0882   0.00774                    8.77 
```
