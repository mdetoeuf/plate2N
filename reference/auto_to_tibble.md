# Automatically detect and extract 96-well plate layouts from a raw data file

Scans a file column by column, looking for the signature shape of a
96-well plate: eight consecutive rows reading `"A"` through `"H"`, with
the row immediately above holding `1` through `12` across the next 12
columns. Once found, that block (the anchor cell plus 8 rows and 12
columns) is extracted as one plate; scanning then continues down the
same column for further plates stacked below, before moving to the next
column. Useful for files that don't follow one of the package's other
fixed import formats.

## Usage

``` r
auto_to_tibble(
  filepath,
  format = NULL,
  delim = "\t",
  skip = 0,
  comment = "",
  col_select = NULL,
  sheet = 1,
  na = c("", "NA"),
  plate_id_in_anchor = TRUE,
  plate_ids = NULL,
  case_sensitive = TRUE,
  trim_whitespace = TRUE,
  output = "tibble"
)
```

## Arguments

- filepath:

  Path to the file to scan.

- format:

  One of `"csv"`, `"csv2"`, `"xlsx"`, or `"txt"`. If `NULL` (the
  default), guessed from the file extension for `.xlsx`/`.txt`. A `.csv`
  extension defaults to `"csv"` (comma-delimited) with a warning, since
  the extension alone can't distinguish it from a semicolon-delimited
  ("French locale") file — pass `format = "csv"` explicitly to silence
  the warning, or `format = "csv2"` if that's actually what you have.

- delim:

  Delimiter used when `format = "txt"`. Defaults to `"\t"`.

- skip, comment:

  Passed through to the underlying reader
  ([`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)/`read_csv2()`/`read_delim()`,
  or
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
  for `skip` only). `comment` is not supported for `format = "xlsx"` —
  `readxl` has no comment- skipping option, and passing a non-empty
  `comment` with `format = "xlsx"` errors rather than being silently
  ignored.

- col_select:

  Optionally restrict which columns of the raw file are scanned (e.g. if
  you know plate data only appears in a certain range). Defaults to
  `NULL` (scan every column). For `format = "xlsx"`, this expects column
  *positions* (a numeric vector), not names or `tidyselect` helpers —
  simpler than `readr`'s own `col_select`, which does accept full
  `tidyselect` syntax for the other formats.

- sheet:

  Which sheet to read, only relevant for `format = "xlsx"`. Accepts
  either a sheet name (character) or a 1-based position (integer).
  Defaults to `1` (the first sheet). Ignored for all other formats.

- na:

  Character vector of strings to treat as missing values. Defaults to
  `c("", "NA")`, applied consistently across every format (matches
  `readr`'s own default; `readxl` alone would otherwise only treat `""`
  as missing, so a literal `"NA"` text value could behave inconsistently
  depending on file format).

- plate_id_in_anchor:

  If `TRUE` (the default), each plate's ID is read from its anchor cell
  (the cell just above `"A"` and left of `"1"`). If `FALSE`, IDs come
  from `plate_ids` if given, or are auto-generated otherwise
  (`"plate1"`, `"plate2"`, ..., zero-padded to match however many plates
  are found in total).

- plate_ids:

  Optional character vector of plate IDs, used only when
  `plate_id_in_anchor = FALSE`, applied in the order plates are found
  (column by column, top to bottom). If its length doesn't match the
  number of plates actually found, a warning is issued (possibly
  indicating an incomplete/misaligned plate layout) and the vector is
  recycled/truncated to fit.

- case_sensitive:

  Whether `"A"`-`"H"` must match case exactly. Defaults to `TRUE`.

- trim_whitespace:

  Whether to trim leading/trailing whitespace before comparing cells.
  Defaults to `TRUE`.

- output:

  Either `"tibble"` (all plates stacked, default) or `"list"` (one named
  element per plate) — same convention as
  [`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md).

## Value

Depends on `output`, matching
[`txt_to_tibble()`](https://mdetoeuf.github.io/plate2N/reference/txt_to_tibble.md)'s
own convention.

## Details

**Only complete plates are detected** — a broken or partial `A`-`H` or
`1`-`12` run (e.g. a missing row) will not be recognized, and that data
will simply be skipped rather than flagged.

## Numeric precision

Values are read and returned as character strings, matching the rest of
the package's import functions. For `.xlsx` files specifically, this can
occasionally surface long floating-point artifacts (e.g.
`"0.31830000000000003"` instead of the displayed `"0.3183"`) — a known
`readxl` quirk when reading numeric cells as text, not something this
function rounds or otherwise adjusts. If this matters for your data,
round explicitly downstream.

## Examples

``` r
filepath <- system.file("extdata", "tecan_example/tecan1.xlsx", package = "plate2N")
auto_to_tibble(filepath)
#> # A tibble: 9 × 13
#>   row   X1     X2    X3    X4    X5    X6    X7    X8    X9    X10   X11   X12  
#>   <chr> <chr>  <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 <>    1      2     3     4     5     6     7     8     9     10    11    12   
#> 2 A     0.318… 0.35… 0.501 0.50… 0.47… 0.48… 0.50… 0.53… 0.46… 0.47… 0.49… 0.45…
#> 3 B     0.297… 0.31… 0.48… 0.49… 0.50… 0.5   0.46… 0.53… 0.46… 0.51… 0.45… 0.50…
#> 4 C     0.293… 0.32… 0.46… 0.44… 0.47… 0.50… 0.49… 0.50… 0.44… 0.60… 0.49… 0.45…
#> 5 D     0.273… 0.35… 0.42… 0.44… 0.45… 0.47… 0.47… 0.47… 0.46… 0.49… 0.52… 0.48…
#> 6 E     0.2944 0.32… 0.46… 0.45… 0.42… 0.46… 0.43… 0.46… 0.47… 0.44… 0.52… 0.46…
#> 7 F     0.3251 0.33… 0.46… 0.44… 0.48… 0.44… 0.42… 0.50… 0.49… 0.48… 0.47… 0.47…
#> 8 G     0.6331 0.59… 0.62… 0.61… 0.60… 0.58… 0.46… 0.53… 0.33… 0.29… 0.34… 0.37…
#> 9 H     0.679… 0.63… 0.66… 0.63… 0.62… 0.62… 0.60… 0.62… 0.66… 0.60… 0.64  0.63…
```
