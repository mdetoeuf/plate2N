utils::globalVariables("row")

#' Converts plates data from tibble to a list
#'
#' Converts a tibble (as outputted from csv_import() or skanit_to_plate()) containing all plate data into a list of tibbles (1 per plate)
#'
#' @param tibble The tibble containing all plate data. See output from examples under ?csv_import for a glimpse of the required tibble structure and column names
#'
#' @import tidyselect
#' @importFrom roperators %ni%
#'
#' @returns A list where each element contains the data of a single plate, and the name of each element is the plate identifier (plate name). This list format is the same as the output from txt_import()
#' @export
#'
#' @examples
#' tibble <- csv_to_tibble(system.file("extdata", "csv_example.csv", package = "plate2N"))
#' tibble
#' list <- tibble_to_list(tibble)
#' names(list)[1]; list[[1]]
#' names(list)[2]; list[[2]]
tibble_to_list <- function(tibble) {
  # extract header rows for each plate: contain plate_id and column nb (1 to 12)
  # to get to the plate_ids
  plates <- tibble |>
    # exclude rows where 1st column contains single capital letters
    dplyr::filter(row %ni% LETTERS) |>
    # keep only 1st column --> create a tibble (1 column) with plate_ids
    dplyr::select(plate_id = row)

  # initiate an empty list
  abs_data_list <- list()

  # in a loop: extract each plate and append the list
  # (1 file --> 1 plate --> 1 element of the list)
  for (i in 1:nrow(plates)) {
    # store plate id
    plate_id <- plates$plate_id[i]

    # extract line corresponding to plate_id
    line <- which(tibble$row == plate_id)

    # get plate absorbances (start at line of plate_id, and get next 8 lines)
    plate_abs <- tibble[line:(line+8),] |>
      janitor::row_to_names(row_number = 1) |>
      # rename column with "A", "B", etc. Not vital, but kept here to reach same
      # format in all functions for interoperability
      dplyr::rename(row = tidyselect::any_of(plate_id))

    abs_data_list[[i]] <- plate_abs
    names(abs_data_list)[i] <- plate_id

  }

  return(abs_data_list)

}
