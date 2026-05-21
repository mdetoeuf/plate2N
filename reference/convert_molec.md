# Converts Concentrations From Compound Weight to Target Weight

Convert units of concentrations from "mg Compound L-1" to "mg Target
L-1". This allows, for example, to convert concentrations expressed in
mg NH4 / L to mg N / L. This conversion requires a vector where molar
masses of both Compound and Target are stored. This function works in
bulk, on a tibble Target (e.g., nitrogen) will be expressed in the same
unit as the compound (origin, e.g. NH4). For example, we go from "mg NH4
/ L" to "mg N / L". We don't go from mg to g or kg...

## Usage

``` r
convert_molec(conc_data, masses = molar_masses)
```

## Arguments

- conc_data:

  A tibble containing columns "std_sp" (chr), "target_sp" (chr),
  "conc_mgNsp_L" (dbl). Columns "target_sp" means "to convert to" (e.g.,
  "N" for mg N / L), and "std_sp" means "to convert from" (e.g., "NH4"
  for mg NH4 / L)

- masses:

  A named vector of molar masses (names of the elements = compounds.)

## Value

A tibble of the same format, with an added column. For now, this new
column is named \`conc_mgN_L". But we could consider adding an argument
to define column names

## See also

molar_masses

## Examples

``` r
tidy_plates
#> # A tibble: 480 × 8
#>    row   column well_id unique_well_id dataset plate_id map      abs  
#>    <chr> <chr>  <chr>   <chr>          <chr>   <chr>    <chr>    <chr>
#>  1 A     1      A1      A1_NO3_1F1     Nmin    NO3_1F1  Std      0.092
#>  2 A     1      A1      A1_NO3_1F2     Nmin    NO3_1F2  Std      0.091
#>  3 A     1      A1      A1_NO3_1F3     Nmin    NO3_1F3  Std      0.093
#>  4 A     1      A1      A1_NO3_1F4     Nmin    NO3_1F4  Std      0.092
#>  5 A     1      A1      A1_NO3_1F5     Nmin    NO3_1F5  Std      0.092
#>  6 A     2      A2      A2_NO3_1F1     Nmin    NO3_1F1  81_t1_z2 0.114
#>  7 A     2      A2      A2_NO3_1F2     Nmin    NO3_1F2  97_t1_z1 0.107
#>  8 A     2      A2      A2_NO3_1F3     Nmin    NO3_1F3  89_t1_z3 0.095
#>  9 A     2      A2      A2_NO3_1F4     Nmin    NO3_1F4  81_t1_z1 0.118
#> 10 A     2      A2      A2_NO3_1F5     Nmin    NO3_1F5  Std_3_t1 0.167
#> # ℹ 470 more rows
molar_masses
#>       N     NO3     NO2     NH4 
#> 14.0069 62.0051 46.0057 36.0775 
```
