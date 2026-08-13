# Compute per-dilution Averages for Standard Curves

Averages absorbance per plate, per row (dilution level), across several
standard curves pipetted on the same plate — useful when a plate holds
more than one curve of the same standard solution (e.g. one in column 1,
one in column 12). Averaging serves two purposes: reducing noise before
model fitting, and correcting for a systematic drift between curves
caused by pipetting order (a plate is typically pipetted left to right,
so column 1 and column 12 wells experience slightly different incubation
times before reading — averaging across the plate's curves compensates
for that, since same-row wells across curves are assumed to hold the
same concentration).

## Usage

``` r
std_dilution_average(
  std_data,
  plate_id_col = "plate_id",
  row_col = "row",
  value_col = "abs_corrected",
  std_conc_col = "std_conc",
  column_col = "column",
  well_id_col = "well_id",
  unique_well_id_col = "unique_well_id",
  fake_column_value = 13
)
```

## Arguments

- std_data:

  A tibble of std data

- plate_id_col:

  Name of the column identifying physical plates. Defaults to
  `"plate_id"`.

- row_col:

  Name of the column identifying plate row (A-H), used as the
  dilution-level grouping key. Defaults to `"row"`.

- value_col:

  Name of the numeric absorbance column averaged. Defaults to
  `"abs_corrected"`.

- std_conc_col:

  Name of the standard curve concentration column, used only to order
  rows before deduplicating other columns. Defaults to `"std_conc"`.

- column_col:

  Name of the column identifying the plate column (1-12). Defaults to
  `"column"`.

- well_id_col, unique_well_id_col:

  Names of the well-identifying columns. Default to `"well_id"` and
  `"unique_well_id"`.

- fake_column_value:

  The placeholder value used for `column_col` in the output, since
  averaged rows no longer correspond to a single real plate column.
  Defaults to `13` — deliberately outside the real 1-12 range, as a
  visible marker that this value doesn't represent an actual well.

## Value

Same, with less rows (bc average of same-dilution wells per plate).
Artificial column 13

## Details

Since the output no longer corresponds to a single real well, a
placeholder `column`/`well_id`/`unique_curve_id` is fabricated (see
`fake_column_value`) so the result still has the shape downstream
functions expect.

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
#> #   empty_column <lgl>, wait_min <chr>, std_conc <dbl>, blank_sdev <dbl>,
#> #   blank_coeff_var_percent <dbl>
std_dilution_average(std_corrected)
#> # A tibble: 35 × 25
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
#> #   extractant_conc <dbl>, empty_column <lgl>, wait_min <chr>, std_conc <dbl>,
#> #   blank_sdev <dbl>, blank_coeff_var_percent <dbl>
```
