#** This file contains several functions relevant to *
#** - verticalization of plate data *
#** - tidying of verticalized plate data (long format) *
#** - and joining of several plate-shaped data (e.g., absorbance and mapping) *
#**   and/or joining of plate-shaped data with plate metadata (one row per plate) *

utils::globalVariables(c("row", "column", "X1", "X12"))


#' Tidying plate data (verticalization)
#'
#' `verticalize_plates` brings plate data (absorbance or mapping data) into a vertical, tidy format.
#' It starts from a tibble in plate format (as rendered by `txt_to_tibble()`, `csv_to_tibble()` and `skanit_to_tibble()`),
#' and ends with a tidy tibble of 96 rows (row per well) and one column per plate, as well as structural columns allowing well identification (row, column)
#'
#' @param tibble The tibble containing the raw plate-formatted data to be tidied.
#'               tibble must fit the following criteria:
#'               - Plate ids **cannot** be a single capital letter (e.g., "A", "B", ...)
#'               - Plates must be complete (96 wells accounted for, set up in 12 columns x 8 rows), but may contain NA's
#'               - Plate data in the tibble **must be** structured exactly as in example files (see also `txt_to_tibble()`, `csv_to_tibble()` or `skanit_to_tibble()`).
#' @param coerce_numeric Whether or not to force data entries to be numerical. The default is set to `FALSE`, so that data will be outputted as strings
#' @param prefix Defaults as an empty string. A `prefix` can be added to all column names, which can be useful to join tables from distinct datasets
#'
#' @import dplyr tidyr tidyselect
#' @importFrom roperators %ni%
#'
#' @returns A tidy tibble (verticalized plate data), with 1 column per plate
#' @seealso [skanit_to_tibble()], [csv_to_tibble()], [txt_to_tibble()] that can generate the input needed
#' @export
#'
#' @examples
#' # check out input
#' tibble_example
#' (verticalize_plates(tibble_example))
#' (verticalize_plates(tibble_example, coerce_numeric = TRUE))
#' (verticalize_plates(tibble_example, prefix = "prefix_"))

#'
verticalize_plates <- function(
    tibble,
    coerce_numeric = FALSE,
    prefix = NULL
) {

  # initialize the tidy table format by verticalizing a empty plate and store in a tibble
  vertic_plates <- verticalized_empty

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
      dplyr::filter(row != plate_id)

    # force data (now as strings) to become numeric (if coerce_numeric == TRUE)
    if (coerce_numeric) {
      plate_abs[2:13] <- lapply(plate_abs[2:13], as.numeric)
    } else { #(default, if coerce_numeric == FALSE)
      plate_abs[2:13] <- lapply(plate_abs[2:13], as.character)
    }

    # verticalize the absorbance data and append it to the dataframe in construction
    vertic_plates <- vertic_plates |>
      dplyr::mutate(
        plate_abs |>
          tidyr::pivot_longer(cols = X1:X12, names_to = "column", values_to = plate_id) |>
          dplyr::select(tidyselect::any_of(plate_id))
      )
  }
  #print(i)
  #i = i+1
  if (!is.null(prefix)) {
    vertic_plates <- vertic_plates |>
      rename_with(~ paste0(prefix, .x, recycle0 = TRUE), .cols = !row:column)
  } # end of for-loop

  return(vertic_plates)
}



#' From vertical plate data to tidy data using the tidyr package
#'
#' See also [`vertical_plates`] and [`tidy_table`] to understand input and output data structure
#'
#' @param vertical_data As generated from either [`verticalize_plates()`] or [`join_abs_map()`].
#'
#' @returns A table in a tidy format for downstream analysis
#' @export
#'
#' @examples
#' map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
#' abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
#' map_tibble <- csv_to_tibble(map_file)
#' abs_tibble <- txt_to_tibble(abs_folder)
#' joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
#' tidy_data <- vertical_to_tidy(joined_vertical)
vertical_to_tidy <- function(
    vertical_data
) {
  tidy_data <- vertical_data |>
    pivot_longer(
      cols = !any_of(c("row", "column")),
      names_to = c("dataset", "abs_map", "plate_id"),
      names_sep = "-",
      values_to = "value"
    ) |>
    pivot_wider(
      names_from = "abs_map",
      values_from = "value"
    ) |>
    relocate(map, .before = "abs" ) |>
    mutate(
      well_id = paste0(row, column),
      unique_well_id = paste0(well_id, "_", plate_id),
      .before = 3
    )
}


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



utils::globalVariables(c("row", "column"))

#' Merging 2 vertical plates into one
#'
#' The function `join_abs_map()` was thought to merge absorbance data with their mapping counterparts,
#' coming from 2 separate import occurrences, into a single, vertical tibble.
#' It takes profit of the `dplyr::left_join()` function, connected to our `verticalize_plates()` function,
#' so that it provides a 2-in-1 feature of verticalizing plates while joining them.
#'
#' The first purpose of this function is to join an absorbance tibble and a mapping tibble, which is how the default setup is organized.
#' Still, it offers enough flexibility in its parameters to be adapted to the joining of any 2 tibbles, so long as they fit the proper `tibble_example`-like structure.
#'
#'
#' @param abs_tibble,map_tibble The first and second tibble (will appear on the left and right, respectively). Must have the same structure as `tibble_example`.
#' @param dataset An optional string to be added as a prefix to all column names (from both tibbles), with the exception of the first 2 columns describing well id ("row" and "column"). It is originally meant to record the name of the dataset for later uses.
#' @param abs_map A string vector to add additional prefixes. The default value is set to c("abs", "map"), so that the "abs" data (corresponding to argument `abs_tibble`) will receive the first prefix, and the "map" data (corresponding to argument `map_tibble`) will receive the second prefix. Set this to c("", "") to prevent prefix addition.
#' @param coerce_numeric A logical vector to decide whether the function `verticalize_plates()`, called separately for `abs_tibble` and `map_tibble`, should coerce data to become numeric or not. The default value is set to `c(FALSE, FALSE)`, so that eventually all data can be pivotted in a single column (see later steps in the pipeline).
#'
#' @returns A unique verticalized table containing the data from both data sets.
#' @seealso [verticalize_plates()]
#' @export
#'
#' @examples
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' skanit_tibbles <- skanit_to_tibble(skanit_csv)
#' join_abs_map(skanit_tibbles$abs_tibble, skanit_tibbles$map_tibble)
join_abs_map <- function(
    abs_tibble, # abs_tibble = skanit_tibble_abs
    map_tibble, # map_tibble = skanit_tibble_map
    dataset = "",
    abs_map = c("abs-", "map-"),
    coerce_numeric = c(FALSE, FALSE)
) {
  joined_vertical <- dplyr::left_join(
    verticalize_plates(
      abs_tibble,
      coerce_numeric = coerce_numeric[1],
      prefix = paste0(dataset, abs_map[1])
    ),
    verticalize_plates(
      map_tibble,
      coerce_numeric = coerce_numeric[2],
      prefix = paste0(dataset, abs_map[2])
    ),
    by = dplyr::join_by(row, column)
  )
  return(joined_vertical)
}

