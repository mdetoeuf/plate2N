#' Import 96-well plate data in csv format
#'
#' Can be either comma-delimited ("normal csv" = default setting) or semi-colon delimited ("French version" with commas used for digits and semi-colons as separators).
#' The format must follow strictly the following structure, and content can be numerical (e.g., absorbance data) or strings (e.g., plate mapping):
#'   - plates must be directly on top of each other (no empty rows between the plates)
#'   - the first plate must be at the top of the document (no empty row above it)
#'   - plates must be at the utmost left of the document (first 13 columns of the sheet)
#'   - No data must be recorded beyond plate data (nothing below the plates or further right)
#'   - the plate name must be in the first cell (top left) of the plate, just above "A", marking the first row of data, and just left of "1", marking the first column of data
#' For csv files that do fit neither this structure nor the "Skanit" structure (see ?skanit_to_plate for more details), an alternative is to use read_csv() or read_csv2 and rearrange the resulting tibble to fit the output given here, so that it can be inputted in the downstream steps.
#'
#' @param filepath The path to the file.
#' @param delim Value separator of the .csv document. Default value is ",". ";" is also accepted.
#'
#' @returns A tibble with the plate data, all plates are still on top of each other (see examples)
#' @export
#'
#' @examples
#' example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
#' plate_data <- csv_to_tibble(example_csv)
#' plate_data

csv_to_tibble <- function(
    filepath,
    delim = ","      # alternative is ";"
) {
  # import csv
  if (delim == ",") {
    raw_tibble <-  readr::read_csv(
    filepath,
    col_names = FALSE,
    show_col_types = FALSE)
  } else {
    raw_tibble <-  readr::read_csv2(
      filepath,
      col_names = FALSE,
      show_col_types = FALSE)
  }

  return(raw_tibble)
}
