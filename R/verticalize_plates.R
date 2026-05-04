utils::globalVariables(c("row", "X1", "X12"))


#' Tidying plate data (verticalization)
#'
#' `verticalize_plates`brings plate data (absorbance or mapping data) into a vertical, tidy format.
#' It starts from a tibble in plate format (as rendered by `txt_to_tibble()`, `csv_to_tibble()` and `skanit_to_tibble()`),
#' and ends with a tidy tibble of 96 rows (row per well) and one column per plate, as well as structural columns allowing well identification (row, column)
#'
#' @param tibble The tibble containing the raw plate-formatted data to be tidied.
#'               tibble must fit the following criteria:
#'               - Plate ids **cannot** be a single capital letter (e.g., "A", "B", ...)
#'               - Plates must be complete (96 wells accounted for, set up in 12 columns x 8 rows), but may contain NA's
#'               - Plate data in the tibble **must be** structured exactly as in example files (see also `txt_to_tibble()`, `csv_to_tibble()` or `skanit_to_tibble()`).
#'
#' @import dplyr roperators tidyr tidyselect
#'
#' @returns A tidy tibble (verticalized plate data), with 1 column per plate
#' @export
#'
#' @examples
#' # create tibble with skanit_to_tibble()
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' plate_data <- skanit_to_tibble(skanit_csv, delim = ",")
#' (tibble <- plate_data$abs_tibble)
#'
#' # run verticalize_plates()
#' (verticalize_plates(tibble))
#'
verticalize_plates <- function(
    tibble
) {
  # initialize the tidy table format by verticalizing a empty plate and store in a tibble
  vertical_plates <- verticalized_empty

  # extract plate_ids
  plates <- tibble |>
    # exclude rows where 1st column contains single capital letters
    # effectively keeping only header rows for each plate (containing plate_id and column nb (1 to 12))
    dplyr::filter(row %ni% LETTERS) |>
    # keep only 1st column --> create a tibble (1 column) with plate_ids
    dplyr::select(plate_id = row)

  # loop (1 iteration per plate)
  #i = 1
  for (i in 1:nrow(plates)) {
    # store plate id
    plate_id <- plates$plate_id[i]

    # extract line corresponding to plate_id
    line <- which(tibble$row == plate_id)

    # get plate data (absorbances or mapping, start at line of plate_id, and get next 8 lines)
    plate_abs <- tibble[line:(line+8),] |>
      # rename column with "A", "B", etc. Not vital, but kept here to reach same
      # format in all functions for interoperability
      dplyr::rename(row = tidyselect::any_of(plate_id)) |>
      filter(row != plate_id)

    # verticalize the absorbance data and append it to the dataframe in construction
    vertical_plates <- vertical_plates |>
      dplyr::mutate(
        plate_abs |>
          tidyr::pivot_longer(cols = X1:X12, names_to = "column", values_to = plate_id) |>
          dplyr::select(tidyselect::any_of(plate_id))
      )
    #print(i)
    #i = i+1
  } # end of for-loop

  return(vertical_plates)
}
