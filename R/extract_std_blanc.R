# helper function
extract_std_data <- function(data, std_def = "Std") {
  std_data <- data |>
    # take only plate-columns with standard curves
    filter(map == std_def) |>
    group_by(dataset, plate_id)
  std_data
}

utils::globalVariables(c("row", "column", "well_id", "unique_well_id", "dataset", "plate_id", "map", "abs", "blanc_sdev", "blanc_avg"))

#' Extraction and Quality Check (QC) of blank values for standard curves
#'
#' In cases where the blank of the standard curve is not the same as the blank of the samples,
#' a separate blank correction must happen for both subsets of the data.
#' Here, each standard curve only has one well containing the blank value,
#' usually pipetted in row A (`pipetting_direction = "top_down"`), or in row H (`pipetting_direction = "bottom_up"`).
#'
#' `extract_std_blanc()` works in a few steps:
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
#' map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
#' abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
#' map_tibble <- csv_to_tibble(map_file)
#' abs_tibble <- txt_to_tibble(abs_folder)
#' joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
#' tidy_data <- vertical_to_tidy(joined_vertical)
#'
#' # run the function
#' list <- tidy_data |> extract_std_blanc(std_def = "Std")
#'
extract_std_blanc <- function(
    data,
    std_def = "Std",
    pipetting_direction = "top_down"
) {

  if (pipetting_direction == "top_down") {
    blanc_should_be_in <- "A"
  } else if (pipetting_direction == "bottom_up") {
    blanc_should_be_in <- "H"
  } else {stop("Unknown pipetting direction. Choose between `top-down` and `bottom_up`")}

  # in case still character, correct absorbance values to be numerical
  data <- data |> dplyr::mutate(abs = as.numeric(abs))

  # extract std data (only wells where the standard solutions have been pipetted)
  std_data <- extract_std_data(data, std_def)

  std_blanc_all <- std_data |>
    # 1 group = 1 std curve
    dplyr::group_by(dataset, plate_id, column) |>
    dplyr::slice_min(
      abs,
      with_ties = FALSE
    )

  std_blanc_untrusted <- std_blanc_all |> dplyr::filter(row != blanc_should_be_in)

  std_blanc_trusted <- std_blanc_all |>
    dplyr::anti_join(
      std_blanc_untrusted,
      by = dplyr::join_by(row, column, well_id, unique_well_id, dataset, plate_id, map, abs)) |>
    dplyr::ungroup()

  # compute intra-plate mean for the blanc, st-dev and coefficient of variation in %
  std_blanc_avg <- std_blanc_trusted |>
    dplyr::summarise(
      .by = c(dataset, plate_id),
      blanc_avg = mean(abs),
      blanc_sdev = stats::sd(abs)
    ) |>
    dplyr::mutate(blanc_coeff_var_percent = 100 * blanc_sdev / blanc_avg)

  std_blanc <- list(
    "all" = std_blanc_all,
    "trusted" = std_blanc_trusted,
    "untrusted" = std_blanc_untrusted,
    "average" = std_blanc_avg
  )

  return(std_blanc)
}
