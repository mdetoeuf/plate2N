#** This file contains several functions relevant to *
#** QC and blank-correction of standard curves *
#** as well as some helpers *
#*
#** First, helpers *
#*



pipette_to_row <- function(pipetting_direction) {
  if (pipetting_direction == "top_down") {
    blank_should_be_in <- "A"
  } else if (pipetting_direction == "bottom_up") {
    blank_should_be_in <- "H"
  } else {stop("Unknown pipetting direction. Choose between `top-down` and `bottom_up`")}
  return(blank_should_be_in)
}


#** Then, standard curve functions*



#' Keeps only wells corresponding to standard curves
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     dataset, map, plate_id, column
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#'
#' @import dplyr
#'
#' @returns A smaller tible than `data`, keeping only rows where the column `map`
#'     contain the value definind standard curve wells (default is `std_def = "Std"`)
#' @export
#'
#' @examples
#' tidy_plates
#' extract_std_data(tidy_plates)
extract_std_data <- function(data, std_def = "Std") {
  std_data <- data |>
    # take only plate-columns with standard curves
    dplyr::filter(map == std_def) |>
    dplyr::group_by(dataset, plate_id) |>
    dplyr::mutate(unique_curve_id = paste0(plate_id, "_col", column), .after = plate_id)
  return(std_data)
}




utils::globalVariables(c("row", "column", "well_id", "unique_well_id", "dataset", "plate_id", "map", "abs", "blank_sdev", "blank_avg", "unique_curve_id", "well_min"))

#' Extraction and Quality Check (QC) of blank values for standard curves
#'
#' In cases where the blank of the standard curve is not the same as the blank of the samples,
#' a separate blank correction must happen for both subsets of the data.
#' Here, each standard curve only has one well containing the blank value,
#' usually pipetted in row A (`pipetting_direction = "top_down"`), or in row H (`pipetting_direction = "bottom_up"`).
#'
#' `extract_std_blank()` works in a few steps:
#'     - First, data corresponding to wells containing the standard curve is extracted (as defined by parameter `std_def`)
#'     - Second, within this "standard data", for each dataset, plate and column (= 1 curve), the smallest absorbance value is extracted.
#'     - We then check that the smallest per-curve value is indeed found in plate row "A"
#'       (top_down pipetting) or row "H" (bottom_up pipetting).
#'     - Should that not be the case, those wells are considered "untrusted" and are removed from the "trusted" blank values.
#'     - Per-plate averages for blank values are then computed
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     row, column, well_id, unique_well_id, dataset, plate_id, map, abs
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#'
#' @import dplyr
#'
#' @returns A list of 4 elements characterizing blank wells:
#'     - `list$all` contains all supposed blank values (minimum values from each curve)
#'     - `list$trusted` contains all trusted blank values (minimum values and wells in the "correct" row (A or H))
#'     - `list$untrusted` contains all untrusted wells
#'     - `list$average` contains a summarized table with a per-plate computation of average,
#'       standard deviation and coefficient of variation of blank values.
#'       Note that a coefficient of variation has little value when computed on 2 values,
#'       especially when the values are small numbers (typically, blank absorbances are often lower than 0.1)
#'
#' @export
#'
#' @examples
#' # reconstruct a proper data table to start from
#' # map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
#' # abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
#' # map_tibble <- csv_to_tibble(map_file)
#' # abs_tibble <- txt_to_tibble(abs_folder)
#' # joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
#' # tidy_data <- vertical_to_tidy(joined_vertical)
#'
#' # check out input table
#' tidy_plates
#'
#' # run the function
#' std_blank <- tidy_plates |> extract_std_blank(std_def = "Std")
#' std_blank$all ; std_blank$trusted ; std_blank$untrusted
#'
extract_std_blank <- function(
    data, # data <- tidy_data
    std_def = "Std",
    pipetting_direction = "top_down"
) {

  # blank_should_be_in <- pipette_to_row(pipetting_direction)

  # in case still character, correct absorbance values to be numerical
  data <- data |>
    dplyr::mutate(abs = as.numeric(abs))

  # extract std data (only wells where the standard solutions have been pipetted)
  std_data <- extract_std_data(data, std_def)

  # std_blank_all <- std_data |>
  #   # 1 group = 1 std curve
  #   dplyr::group_by(dataset, plate_id, column) |>
  #   dplyr::slice_min(
  #     abs,
  #     with_ties = FALSE
  #   )

  #** Tentative *
  std_min <- std_data |>
    # 1 group = 1 std curve
    dplyr::group_by(dataset, plate_id, column) |>
    dplyr::select(!unique_well_id) |>
    dplyr::slice_min(
      abs,
      with_ties = FALSE
    ) |>
    dplyr::rename(well_min = well_id) |>
    dplyr::select(well_min, dataset, plate_id, column, unique_curve_id)

  if (pipetting_direction == "top_down") {
    std_blank_all <- std_data |>
      # 1 group = 1 std curve
      dplyr::group_by(dataset, plate_id, column) |>
      dplyr::filter(row == "A") |>
      dplyr::select(well_id, dataset, plate_id, row, column, unique_well_id,unique_curve_id, abs)
  } else if (pipetting_direction == "bottom_up") {
    std_blank_all <- std_data |>
      # 1 group = 1 std curve
      dplyr::group_by(dataset, plate_id, column) |>
      dplyr::filter(row == "H") |>
      dplyr::select(well_id, dataset, plate_id, row, column, unique_well_id, unique_curve_id, abs)
  }

  blank_min_check <- std_min |>
    dplyr::left_join(
      std_blank_all,
      by = dplyr::join_by(column, dataset, plate_id, unique_curve_id)) |>
    dplyr::relocate(well_id, .after = well_min)

  #blank_min_check$well_min[2] <- "test"
  std_blank_untrusted <- blank_min_check |>
    dplyr::filter(well_id != well_min) |>
    dplyr::select(!well_min)

  std_blank_trusted <- std_blank_all |>
    dplyr::anti_join(
      std_blank_untrusted,
      by = dplyr::join_by(column, well_id, dataset, plate_id, unique_curve_id)) |>
    dplyr::ungroup()

  #** End Tentative *


  # std_blank_untrusted <- std_blank_all |> dplyr::filter(row != pipette_to_row(pipetting_direction))
  #
  # std_blank_trusted <- std_blank_all |>
  #   dplyr::anti_join(
  #     std_blank_untrusted,
  #     by = dplyr::join_by(row, column, well_id, unique_well_id, dataset, plate_id, map, abs)) |>
  #   dplyr::ungroup()



  std_blank <- list(
    "all" = std_blank_all,
    "trusted" = std_blank_trusted,
    "untrusted" = std_blank_untrusted
   # "average" = std_blank_avg
  )

  return(std_blank)
}


#' Computing per-plate average for raw absorbance of the standard blank
#'
#' This only makes sense for plates that have contain 2 or more standard curves for
#'     the same standard solution
#'
#' @param std_blank_data A tibble containing only rows that received standard blanks,
#'     i.e., row A (top_down_pipetting) or H (bottom_up_pipetting). It is normally
#'     generated by `extract_std_blank()` from which one element can be chosen and,
#'     if necessary, modified, based on the examination of "untrusted wells".
#'     Thus, use as input (a modified version of) `extract_std_blank(data)$all` or
#'     `extract_std_blank(data)$trusted`
#'
#' @returns A tibble with one row per plate, and columns `dataset`, `plate_id`,
#'     `blank_avg`, `blank_sdev`, `blank_coeff_var_percent`
#' @export
#'
#' @examples
#' tidy_plates
#' std_blank <- tidy_plates |> extract_std_blank(std_def = "Std")
#' std_blank$trusted |> std_blank_average()
#' # Don't be disturbed by the NA values: it is not possible to compute a
#' # standard deviation of coefficient of variation from only one data entry
std_blank_average <- function(
    std_blank_data # choose one (corrected) sub-element of std_blannk
){
  # compute intra-plate mean for the blank, st-dev and coefficient of variation in %
  std_blank_avg <- std_blank_data |>
    dplyr::ungroup() |>
    dplyr::summarise(
      .by = c(dataset, plate_id),
      blank_avg = mean(abs),
      blank_sdev = stats::sd(abs)
    ) |>
    dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)

  return(std_blank_avg)
}



utils::globalVariables(c("dataset", "plate_id", "std_conc", "A", "H"))
#' Get concentration of standard curve from metadata
#'
#' @param metadata A tibble following a similar structure as [`metadata`], see documentation of `metadata for more details
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#'
#' @import dplyr tidyr
#'
#' @returns A tibble with 3 columns: `plate_id`, `row` (corresponding to plate-row,
#'     from A to H) and `std_conc` containing the concentrations as given in the `std_conc` column of `metadata`.
#' @export
#' @seealso [metadata]
#'
#' @examples
#' metadata
#' extract_curve(metadata)
extract_curve <- function(
    metadata,
    pipetting_direction = "top_down"
) {
  if (pipetting_direction == "top_down") {
    row_curve <- LETTERS[1:8]
  } else if (pipetting_direction == "bottom_up") {
    row_curve <- LETTERS[8:1]
  }

  curve_concentration <- metadata |>
    dplyr::select(dataset, plate_id, std_conc) |>
    tidyr::separate_wider_delim(std_conc, delim = "-", names = row_curve) |>
    tidyr::pivot_longer(
      cols = A:H,
      names_to = "row",
      values_to = "std_conc") |>
    dplyr::mutate(std_conc = as.double(std_conc))

  return(curve_concentration)
}



#' Display one or more standard curve(s)
#'
#' Plots raw absorbance (y-axis) vs concentration (x-axis), grouping the data by `plate_id`.
#' Uses the `ggplot2` package.
#'
#' @param std_data The table containing the data to be plotted. Must contain the
#'     columns `std_conc`, `abs`, `plate_id` and `well_id`. If the plot shows too
#'     many curves, consider filtering the input data frame or adding a ggplot layer
#'     to facet (see `?facet_wrap()` or `?facet_grid()`).
#' @param through_origin Whether the smooth curve should be constrained to go
#'     through the origin. Default to TRUE, which only makes sense for absorbance
#'     data that has already been blank-corrected
#' @param model Which model to use for the smooth curve. Accepts either `linear`
#'     (default) or `poly` for polynomial model (y = ax + bx^2 + c, with c = 0
#'     if `through_origin = TRUE`)
#'
#' @import ggplot2
#'
#' @returns A plot of one or several standard curves.
#' @export
#'
#' @examples
#' raw_meta <- tidy_plates |>
#'     dplyr::left_join(metadata, by = dplyr::join_by(dataset,plate_id))
#' curve_concentration <- extract_curve(metadata)
#' std_data <- raw_meta |>
#'   extract_std_data() |>
#'   dplyr::select(!std_conc) |>
#'   dplyr::left_join(curve_concentration, by = dplyr::join_by(row, dataset, plate_id))
#' plot_std(std_data, through_origin = FALSE, model = "linear") + ggplot2::facet_wrap(~plate_id)
plot_std <- function(
    std_data,
    through_origin = TRUE,
    model = "linear"
    #  show_pval = FALSE,
    # show_R2 = FALSE
) {

  # set parameters
  std_unit <- std_data$std_unit
  y_range <- max(as.numeric(std_data$abs))-min(as.numeric(std_data$abs))

  std_data |>
    ggplot2::ggplot(ggplot2::aes(
      x = as.numeric(std_conc), y = as.numeric(abs),
      group = column, colour = column, fill = column)) +
    ggplot2::theme_minimal() +
    ggplot2::ylab("Absorbance") +
    ggplot2::xlab(paste0("Concentration of Standard Curve")) +
    ggplot2::geom_smooth(
      method = "lm",
      formula =
        if (through_origin & model == "linear") (y ~ 0 + x)
      else if (through_origin & model == "poly") (y ~ 0 + x + I(x^2))
      else if (model == "linear") (y ~x)
      else if (model == "poly") (y ~ x + I(x^2)),
      alpha = 0.3,
      linewidth = 0.5, linetype = 2) +
    #geom_line()
    ggplot2::geom_point(aes(colour = column)) +
    # ggplot2::geom_line(ggplot2::aes(colour = column)) +
    ggplot2::geom_text(
      ggplot2::aes(label = well_id, colour = column),
      alpha = 1, position = ggplot2::position_nudge(y = y_range/20),
      size = 4, fontface = "plain")
}




utils::globalVariables(c("std_def", "abs_corrected"))

#' Replaces raw absorbance data from standard curves by blank-corrected absorbance values.
#'
#' `correct_std_blank()` relies on [`plate2N::extract_std_blank()`].
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     row, column, well_id, unique_well_id, dataset, plate_id, map, abs
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#' @param std_blank_average If NULL (default), it will be computed from `std_blank_trusted`.
#'     Otherwise, `std_blank_average` should be a tibble in the same format as `extract_std_blank(data)$average`
#'     Changing the default value of `std_blank_average` may be relevant if the previous
#'     call to [`extract_std_blank()`] has led the user to correct "trusted" blanks
#'     in any way (see `?extract_std_blank()` for more details)
#' @param std_blank_trusted If NULL (default), it will be extracted from `std_blank`
#' @param std_blank If NULL (default), it will be extracted/computed from `data`, using `extract_std_blank()`.
#'
#' @import dplyr
#' @importFrom roperators %ni%
#'
#' @returns A tibble with blank-corrected absorbance values for standard curves.
#'     It has less rows than the input `data` because
#'       - `correct_std_blank()` extracts standard curves-related data and
#'       - for which it only keeps values for non-blank wells once the correction is done,
#'         which is why row A (top_down pipetting) or row H (bottom_up pipetting) are missing from this output table
#' @export
#' @seealso [extract_std_blank()]
#'
#' @examples
#' #tidy_plates
#' #correct_std_blank(tidy_plates)
correct_std_blank <- function(
    data,
    std_def = "Std",
    pipetting_direction = "top_down",
    std_blank_average = NULL, # what we need, but can be computed from trusted
    std_blank_trusted = NULL, # can be extracted from blank
    std_blank = NULL # can be extracted/computed from data (but no user QC on untrusted wells)
) {
  ## Getting trusted blank average data

  # if no blank average table provided
  if (is.null(std_blank_average)) {
    # if trusted blank not explicitly provided, can be extracted from std_blank
    if (is.null(std_blank_trusted)) {
      # if std_blank not provided, then compute it from data
      if (is.null(std_blank)) {
        std_blank <- extract_std_blank(data, std_def = std_def, pipetting_direction = pipetting_direction)
      }
      # extract trusted
      std_blank_trusted <- std_blank$trusted
    }
    # compute average from trusted blanks (if not provided)
    std_blank_average <- std_blank_trusted |>
      dplyr::summarise(
        .by = c(dataset, plate_id),
        blank_avg = mean(abs),
        blank_sdev = stats::sd(abs)) |>
      dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)
  }

  std_corrected <- extract_std_data(data) |>
    dplyr::mutate(abs = as.numeric(abs)) |>
    # keep only data that is not from blank wells
    dplyr::filter(
      # unique_well_id %ni% std_blank_untrusted$unique_well_id,
      row != pipette_to_row(pipetting_direction)
    ) |>
    dplyr::right_join(std_blank_average, by = dplyr::join_by(dataset, plate_id)) |>
    dplyr::mutate(abs_corrected = abs - blank_avg, .keep = "unused") |>
    # remove rows where no corrected absorbance data (untrusted or blanks)
    dplyr::filter(!is.na(abs_corrected)) #|>
  # create unique curve_id which will be needed for downstream analysis
  #dplyr::mutate(unique_curve_id = paste0(plate_id, "_col", column), .after = plate_id)

  return(std_corrected)
}



#' Compute per-dilution Averages for Standard Curves
#'
#' This needs better documentation!!
#'
#' @param std_data A tibble of std data
#'
#' @import dplyr tidyselect
#'
#' @returns Same, with less rows (bc average of same-dilution wells per plate).
#'     Artificial column 13
#' @export
#'
#' @examples
#' std_corrected
#' std_dilution_average(std_corrected)
std_dilution_average <- function(
    std_data) {

  # compute per plate per std_conc mean
  std_mean <- std_data |>
    dplyr::group_by(plate_id, row) |>
    dplyr::summarise(abs_mean = mean(abs_corrected))

  # create a table to rejoin to the std mean, to get back the columns lost in the process
  lost_columns <- std_data |> dplyr::arrange(plate_id, std_conc) |>
    dplyr::select(!tidyselect::any_of(c("column", "unique_curve_id", "well_id", "unique_well_id", "abs_corrected"))) |> unique()

  # rejoin the mean with the relevant lost columns and recreate fake columns sometimes needed for downstream steps: column = 13; well_id ; unique_curve_id
  std_dilution_avg <- std_mean |>
    dplyr::left_join(lost_columns, by = dplyr::join_by(plate_id, row)) |>
    dplyr::mutate(
      column = rep(13),
      well_id = paste0(row, column),
      unique_curve_id = paste0(plate_id, "_col", column),
      .after = row)

  return(std_dilution_avg)
}
