# Quality check of raw absorbance data for extractant wells

Extracts plate ID's where it is suspected that raw absorbance data for
extractant (sample blank) still contain some outliers. The criterion for
a plate to be deemed "suspicious" is defined by max_coeff

## Usage

``` r
qc_raw_extr(
  data,
  max_coeff = 5,
  suppress_message = FALSE,
  suppress_warning = FALSE
)
```

## Arguments

- data:

  A tibble, as in `tidy_plates`

- max_coeff:

  User-defined, in % (defaults at 5): determines the threshold
  coefficient of variation for raw absorbance of extractant wells, above
  which plates will be considered "suspicious"

- suppress_message:

  Logical, whether or not to suppress the "success" message (given when
  no plate is above the `max_coeff`)

- suppress_warning:

  Logical, whether or not to suppress the warning (given when some plate
  are above the `max_coeff`)

## Value

ID's of suspicious plates. (+ a message or warning if not suppressed)

## Examples

``` r
# example code
data <- tidy_plates
extractant_average <- tidy_plates |> extractant_average()
suspicious_plate_id <- qc_raw_extr(data, max_coeff = 0.5)
#> Warning: There is a big variation in absorbance values for the blank (more than 0.5%).
#>         Remove the most unlikely values / remove outliers manually.
#>         Suspicious plate ID's are returned
```
