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
convert_molec(
  conc_data,
  masses = molar_masses,
  std_sp_col = "std_sp",
  target_sp_col = "target_sp",
  value_col = "conc_mgNsp_L",
  output_col = "conc_mgN_L"
)
```

## Arguments

- conc_data:

  A tibble containing the columns referenced by `std_sp_col`,
  `target_sp_col`, and `value_col`.

- masses:

  A named vector of molar masses (names of the elements = compounds.)

- std_sp_col:

  Name of the column identifying which compound to convert FROM (e.g.
  "NH4" for mg NH4 / L). Defaults to `"std_sp"`.

- target_sp_col:

  Name of the column identifying which compound to convert TO (e.g. "N"
  for mg N / L). Defaults to `"target_sp"`.

- value_col:

  Name of the column containing the concentration to convert. Defaults
  to `"conc_mgNsp_L"`.

- output_col:

  Name of the new column holding the converted concentration. Defaults
  to `"conc_mgN_L"`.

## Value

A tibble of the same format, with the converted concentration added as a
new column (see `output_col`).

## See also

molar_masses

## Examples

``` r
molar_masses
#>       N     NO3     NO2     NH4 
#> 14.0069 62.0051 46.0057 36.0775 

# small example: convert mg NH4/L to mg N/L
conc_data <- tibble::tibble(
  plate_id = c("P01", "P02"),
  std_sp = c("NH4", "NH4"),
  target_sp = c("N", "N"),
  conc_mgNsp_L = c(5.2, 3.8)
)
convert_molec(conc_data)
#> # A tibble: 2 × 5
#>   plate_id std_sp target_sp conc_mgNsp_L conc_mgN_L
#>   <chr>    <chr>  <chr>            <dbl>      <dbl>
#> 1 P01      NH4    N                  5.2       2.02
#> 2 P02      NH4    N                  3.8       1.48
```
