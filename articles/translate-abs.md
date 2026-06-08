# translate-abs

``` r

library(plate2N)
```

## **TO DO**

### introduce example data (tidy_plates, tidy_table, lm_outputs, molar_masses)

## TEST for extractant_average in case of several extractants per plate

``` r

# TEST CHUNK
#tidy_plates <- tidy_plates

# replace "extr" by "extr_1", and create "extr_2"
tidy_2_extr <- tidy_plates |> 
  dplyr::mutate(
    map = dplyr::case_when(
      column == 8 ~ "extr_1",
      column == 4 ~ "extr_2",
      .default = map),
  extr_id = dplyr::case_when(
      as.double(stringr::str_extract(map, "(\\d)_t1_", group = 1)) < 5 ~ "extr_1",
      map == "Std" ~ "",
      map %in% c("extr_1", "extr_2") ~ map,
      .default = "extr_2"
    ))

# check it out
tidy_2_extr |> print(n = 50)
#> # A tibble: 480 × 9
#>    row   column well_id unique_well_id dataset plate_id map       abs   extr_id 
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>     <chr> <chr>   
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std       0.092 ""      
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std       0.091 ""      
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std       0.110 ""      
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std       0.092 ""      
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std       0.113 ""      
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2  0.114 "extr_1"
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1  0.107 "extr_2"
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3  0.095 "extr_2"
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1  0.118 "extr_1"
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1  0.167 "extr_2"
#> 11 A     3      A3      A3_NO3_1F1     Nmin    NO3_1F1  82_t1_z2  0.128 "extr_1"
#> 12 A     3      A3      A3_NO3_1F2     Nmin    NO3_1F2  98_t1_z1  0.104 "extr_2"
#> 13 A     3      A3      A3_NO3_1F3     Nmin    NO3_1F3  90_t1_z3  0.097 "extr_1"
#> 14 A     3      A3      A3_NO3_1F4     Nmin    NO3_1F4  82_t1_z3  0.138 "extr_1"
#> 15 A     3      A3      A3_NO3_1F5     Nmin    NO3_1F5  98_t1_z3  0.107 "extr_2"
#> 16 A     4      A4      A4_NO3_1F1     Nmin    NO3_1F1  extr_2    0.110 "extr_2"
#> 17 A     4      A4      A4_NO3_1F2     Nmin    NO3_1F2  extr_2    0.093 "extr_2"
#> 18 A     4      A4      A4_NO3_1F3     Nmin    NO3_1F3  extr_2    0.102 "extr_2"
#> 19 A     4      A4      A4_NO3_1F4     Nmin    NO3_1F4  extr_2    0.108 "extr_2"
#> 20 A     4      A4      A4_NO3_1F5     Nmin    NO3_1F5  extr_2    0.101 "extr_2"
#> 21 A     5      A5      A5_NO3_1F1     Nmin    NO3_1F1  84_t1_z1  0.108 "extr_1"
#> 22 A     5      A5      A5_NO3_1F2     Nmin    NO3_1F2  100_t1_z1 0.104 "extr_1"
#> 23 A     5      A5      A5_NO3_1F3     Nmin    NO3_1F3  92_t1_z2  0.094 "extr_1"
#> 24 A     5      A5      A5_NO3_1F4     Nmin    NO3_1F4  84_t1_z2  0.098 "extr_1"
#> 25 A     5      A5      A5_NO3_1F5     Nmin    NO3_1F5  100_t1_z2 0.093 "extr_1"
#> 26 A     6      A6      A6_NO3_1F1     Nmin    NO3_1F1  85_t1_z1  0.106 "extr_2"
#> 27 A     6      A6      A6_NO3_1F2     Nmin    NO3_1F2  101_t1_z3 0.103 "extr_1"
#> 28 A     6      A6      A6_NO3_1F3     Nmin    NO3_1F3  93_t1_z2  0.093 "extr_1"
#> 29 A     6      A6      A6_NO3_1F4     Nmin    NO3_1F4  85_t1_z2  0.104 "extr_2"
#> 30 A     6      A6      A6_NO3_1F5     Nmin    NO3_1F5  101_t1_z2 0.103 "extr_1"
#> 31 A     7      A7      A7_NO3_1F1     Nmin    NO3_1F1  86_t1_z3  0.101 "extr_2"
#> 32 A     7      A7      A7_NO3_1F2     Nmin    NO3_1F2  102_t1_z3 0.101 "extr_1"
#> 33 A     7      A7      A7_NO3_1F3     Nmin    NO3_1F3  94_t1_z3  0.099 "extr_1"
#> 34 A     7      A7      A7_NO3_1F4     Nmin    NO3_1F4  86_t1_z1  0.107 "extr_2"
#> 35 A     7      A7      A7_NO3_1F5     Nmin    NO3_1F5  102_t1_z1 0.120 "extr_1"
#> 36 A     8      A8      A8_NO3_1F1     Nmin    NO3_1F1  extr_1    0.083 "extr_1"
#> 37 A     8      A8      A8_NO3_1F2     Nmin    NO3_1F2  extr_1    0.083 "extr_1"
#> 38 A     8      A8      A8_NO3_1F3     Nmin    NO3_1F3  extr_1    0.084 "extr_1"
#> 39 A     8      A8      A8_NO3_1F4     Nmin    NO3_1F4  extr_1    0.084 "extr_1"
#> 40 A     8      A8      A8_NO3_1F5     Nmin    NO3_1F5  extr_1    0.084 "extr_1"
#> 41 A     9      A9      A9_NO3_1F1     Nmin    NO3_1F1  87_t1_z3  0.119 "extr_2"
#> 42 A     9      A9      A9_NO3_1F2     Nmin    NO3_1F2  103_t1_z1 0.105 "extr_1"
#> 43 A     9      A9      A9_NO3_1F3     Nmin    NO3_1F3  95_t1_z2  0.098 "extr_2"
#> 44 A     9      A9      A9_NO3_1F4     Nmin    NO3_1F4  87_t1_z1  0.121 "extr_2"
#> 45 A     9      A9      A9_NO3_1F5     Nmin    NO3_1F5  103_t1_z3 0.113 "extr_1"
#> 46 A     10     A10     A10_NO3_1F1    Nmin    NO3_1F1  88_t1_z3  0.113 "extr_2"
#> 47 A     10     A10     A10_NO3_1F2    Nmin    NO3_1F2  104_t1_z1 0.091 "extr_1"
#> 48 A     10     A10     A10_NO3_1F3    Nmin    NO3_1F3  96_t1_z3  0.102 "extr_2"
#> 49 A     10     A10     A10_NO3_1F4    Nmin    NO3_1F4  88_t1_z1  0.119 "extr_2"
#> 50 A     10     A10     A10_NO3_1F5    Nmin    NO3_1F5  104_t1_z3 0.099 "extr_1"
#> # ℹ 430 more rows


tidy_extr_1 <- tidy_2_extr |> dplyr::filter(extr_id == "extr_1")  
tidy_extr_2 <- tidy_2_extr |> dplyr::filter(extr_id == "extr_2")  

extr_1_data <- tidy_extr_1 |> dplyr::filter(map == "extr_1")
extr_2_data <- tidy_extr_2 |> dplyr::filter(map == "extr_2")

extr_1_avg <- extractant_average(extractant_data = extr_1_data, extr_def = "extr_1")
extr_2_avg <- extractant_average(extractant_data = extr_2_data, extr_def = "extr_2")
```
