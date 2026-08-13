#** This file contains several functions relevant to *
#** - verticalization of plate data *
#** - tidying of verticalized plate data (long format) *
#** - and joining of several plate-shaped data (e.g., absorbance and mapping) *
#**   and/or joining of plate-shaped data with plate metadata (one row per plate) *


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
#' @param row_col Name of the column identifying plate row (A-H) in the
#'     raw input. Defaults to `"row"`.
#' @param column_cols A vector of the 12 column names holding plate
#'     columns 1-12 in the raw input, in order. Defaults to
#'     `paste0("X", 1:12)`.
#'
#' @import dplyr tidyr tidyselect
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
verticalize_plates <- function(
    tibble,
    coerce_numeric = FALSE,
    prefix = NULL,
    row_col = "row",
    column_cols = paste0("X", 1:12)
) {

  # accumulator always uses the package's standard "row"/"column" naming -
  # row_col/column_cols only control how the RAW INPUT is read, the
  # output stays normalized so everything downstream keeps working
  vertic_plates <- verticalized_empty

  plates <- tibble |>
    dplyr::filter(!(.data[[row_col]] %in% LETTERS)) |>
    dplyr::select(plate_id = dplyr::all_of(row_col))

  for (i in seq_len(nrow(plates))) {
    plate_id <- plates$plate_id[i]
    line <- which(tibble[[row_col]] == plate_id)

    # normalize back to the package's standard "row" name, regardless
    # of what row_col was called in the raw input
    plate_abs <- tibble[line:(line+8),] |>
      dplyr::rename(row = dplyr::all_of(row_col)) |>
      dplyr::filter(.data[["row"]] != plate_id)

    if (coerce_numeric) {
      plate_abs[column_cols] <- lapply(plate_abs[column_cols], as.numeric)
    } else {
      plate_abs[column_cols] <- lapply(plate_abs[column_cols], as.character)
    }

    vertic_plates <- vertic_plates |>
      dplyr::mutate(
        plate_abs |>
          tidyr::pivot_longer(cols = dplyr::all_of(column_cols), names_to = "column", values_to = plate_id) |>
          dplyr::select(tidyselect::any_of(plate_id))
      )
  }

  if (!is.null(prefix)) {
    vertic_plates <- vertic_plates |>
      dplyr::rename_with(~ paste0(prefix, .x, recycle0 = TRUE), .cols = !dplyr::all_of(c("row", "column")))
  }

  return(vertic_plates)
}


#utils::globalVariables(c("row", "column", "layout_type"))

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
#' @param dataset An optional string to be added as a prefix to all column names
#'     (from all tibbles), with the exception of the first 2 columns describing
#'     well id ("row" and "column"). It is originally meant to record the name of
#'     the dataset for later uses.
#' @param abs_map A string vector to add additional prefixes to plate names.
#'     The default value is set to c("abs", "map"), so that the "abs" data
#'     (corresponding to the first element of `tibble_list`) will receive the first
#'     prefix, and the "map" data (corresponding to the second element of `tibble_list`)
#'     will receive the second prefix. Set this to c("", "") to prevent prefix addition.
#'     The length of `abs_map` must be the same as `tibble_list`.
#' @param coerce_numeric A logical vector to decide whether the function `verticalize_plates()`,
#'     called separately for each element of `tibble_list`, should coerce data to
#'     become numeric or not. The default value is set to `FALSE` and will by default
#'     be applied to all elements. But a vector of the same length as `tibble_list`
#'     can be given insted. (e.g., `coerce_numeric = c(FALSE, FALSE)).
#'     WARNING: Eventually all data will be pivotted in a single column, and attributing
#'     numerics to some tibbles but not others may cause issues in the pivotting step
#' @param tibble_list A list containing all tibbles to be joined (e.g., absorbance
#'     tibble, mapping tibble, etc.). Can contain one or more tibble
#'
#' @returns A unique verticalized table containing the data from both data sets.
#' @seealso [verticalize_plates()]
#' @export
#'
#' @examples
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' skanit_tibbles <- skanit_to_tibble(skanit_csv)
#' join_abs_map(list(skanit_tibbles$abs_tibble, skanit_tibbles$map_tibble))
join_abs_map <- function(
    tibble_list = list(),
    dataset = "",
    abs_map = c("abs-", "map-"),
    coerce_numeric = FALSE # can be a vector of TRUE or FALSE, one item per element of tibble_list
) {

  # If length of coerce_numeric is 1, apply to all
  if (length(coerce_numeric) == 1) {
    coerce_numeric <- rep(coerce_numeric, length(tibble_list))
  }


  # check arguments and stop with warning if not fitting
  if (length(abs_map) != length(tibble_list)) {
    stop("length of argument `abs_map` must be the same as length of `tibble_list`")
  }
  if (length(coerce_numeric) != length(tibble_list)) {
    stop("length of argument `coerce_numeric` must be the same as length of `tibble_list`")
  }


  first_vertical_tibble <- verticalize_plates(
    tibble_list[[1]],
    coerce_numeric = coerce_numeric[1],
    prefix = paste0(dataset, abs_map[1])
  )

  # initialize
  joined_vertical <- first_vertical_tibble
  if (length(tibble_list) > 1) {
    for (i in 2:length(tibble_list)) {
      joined_vertical <- dplyr::left_join(
        joined_vertical,
        verticalize_plates(
          tibble_list[[i]],
          coerce_numeric = coerce_numeric[i],
          prefix = paste0(dataset, abs_map[i])
          ),
        by = c("row", "column")
      )
    }
    }

  return(joined_vertical)
}



#' From vertical plate data to tidy data using the tidyr package
#'
#' See also [`vertical_plates`] and [`tidy_table`] to understand input and output data structure
#'
#' @param vertical_data As generated from either [`verticalize_plates()`] or [`join_abs_map()`].
#' @param column_def Strings defining the types of data layout to be recovered.
#'     **Currently unused** — `pivot_wider()` already picks up whatever
#'     layout types are actually present in the data dynamically, so
#'     this parameter has no effect. Kept for backward compatibility
#'     with existing calls that pass it by name; may be deprecated in
#'     a future version. Defaults to `c("abs", "map")`.
#'
#' @returns A table in a tidy format for downstream analysis
#' @export
#'
#' @examples
#' map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
#' abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
#' map_tibble <- csv_to_tibble(map_file)
#' abs_tibble <- txt_to_tibble(abs_folder)
#' joined_vertical <- join_abs_map(
#'     list(abs_tibble, map_tibble),
#'     dataset = "Nmin-", abs_map = c("abs-", "map-"))
#' (tidy_data <- vertical_to_tidy(joined_vertical, column_def = c("abs", "map")))
vertical_to_tidy <- function(
    vertical_data,
    column_def = c("abs", "map")
) {


  tidy_data <- vertical_data |>
    tidyr::pivot_longer(
      cols = !tidyselect::any_of(c("row", "column")),
      names_to = c("dataset", "layout_type", "plate_id"),
      names_sep = "-",
      values_to = "value"
    ) |>
    tidyr::pivot_wider(
      names_from = "layout_type",
      values_from = "value"
    ) |>
    dplyr::mutate(
      well_id = paste0(.data[["row"]], .data[["column"]]),
      unique_well_id = paste0(well_id, "_", plate_id),
      .before = 3
    )

  return(tidy_data)
}
