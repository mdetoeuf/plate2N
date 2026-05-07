# Replaces raw absorbance data from standard curves by blank-corrected absorbance values.

`correct_std_blank()` relies on
[`extract_std_blanc()`](https://mdetoeuf.github.io/plate2N/reference/extract_std_blanc.md).

## Usage

``` r
correct_std_blank(
  data,
  std_def = "Std",
  pipetting_direction = "top_down",
  std_blanc = NULL
)
```

## Arguments

- data:

  A tibble respecting the structure of
  [`tidy_table`](https://mdetoeuf.github.io/plate2N/reference/tidy_table.md).
  `data` must have, though not necessarily in that order, the following
  column names: row, column, well_id, unique_well_id, dataset, plate_id,
  map, abs

- std_def:

  A string, defaults with `"Std"`: how data from wells containing the
  standard curve are referred to.

- pipetting_direction:

  Can only be "top_down" (default) or "bottom_up". A top_down pipetting
  means that the curve was pipetted vertically (in a single column of
  the 96-well plate), with the smallest value (blank) in row A and the
  highest value in row H. Conversely, bottom_up pipetting would have the
  blank in row H and the most concentrated solution in row A

- std_blanc:

  If NULL (default), std_blanc will be computed within the function
  call. Otherwise, `std_blanc` should be a tibble in the same format as
  `extract_std_blanc(data)$all`. Changing the default value of
  `std_blanc` may be relevant if the previous call to
  [`extract_std_blanc()`](https://mdetoeuf.github.io/plate2N/reference/extract_std_blanc.md)
  has led the user to correct "trusted" blancs in any way (see
  `?extract_std_blanc()` for more details)

## Value

A tibble with blank-corrected absorbance values for standard curves. It
has less rows than the input `data` because - `correct_std_blank()`
extracts standard curves-related data and - for which it only keeps
values for non-blank wells once the correction is done, which is why row
A (top_down pipetting) or row H (bottom_up pipetting) are missing from
this output table

## See also

[`extract_std_blanc()`](https://mdetoeuf.github.io/plate2N/reference/extract_std_blanc.md)

## Examples

``` r
#tidy_plates
#correct_std_blank(tidy_plates)
```
