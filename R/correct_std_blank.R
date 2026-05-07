utils::globalVariables(c("std_def", "abs_corrected"))

#' Replaces raw absorbance data from standard curves by blank-corrected absorbance values.
#'
#' `correct_std_blank()` relies on [`plate2N::extract_std_blanc()`].
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     row, column, well_id, unique_well_id, dataset, plate_id, map, abs
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#' @param std_blanc If NULL (default), std_blanc will be computed within the function call.
#'     Otherwise, `std_blanc` should be a tibble in the same format as `extract_std_blanc(data)$all`.
#'     Changing the default value of `std_blanc` may be relevant if the previous
#'     call to [`extract_std_blanc()`] has led the user to correct "trusted" blancs
#'     in any way (see `?extract_std_blanc()` for more details)
#'
#' @import dplyr
#'
#' @returns A tibble with blank-corrected absorbance values for standard curves.
#'     It has less rows than the input `data` because
#'       - `correct_std_blank()` extracts standard curves-related data and
#'       - for which it only keeps values for non-blank wells once the correction is done,
#'         which is why row A (top_down pipetting) or row H (bottom_up pipetting) are missing from this output table
#' @export
#' @seealso [extract_std_blanc()]
#'
#' @examples
#' #tidy_plates
#' #correct_std_blank(tidy_plates)
correct_std_blank <- function(
    data,
    std_def = "Std",
    pipetting_direction = "top_down",
    std_blanc = NULL
) {
  std_data <- extract_std_data(data)
  if (is.null(std_blanc)) {
    std_blanc <- extract_std_blanc(data, std_def = std_def, pipetting_direction = pipetting_direction)$all
  }

 # blank_should_be_in <- pipette_to_row(pipetting_direction)

  std_corrected <- std_data |>
    # keep only data that is not from blanc wells
    dplyr::filter(
      unique_well_id %ni% std_blanc$unique_well_id,
      row != pipette_to_row(pipetting_direction)
    ) |>
    dplyr::right_join(std_blanc$average) |>
    dplyr::mutate(abs_corrected = abs - blanc_avg, .keep = "unused") |>
    # remove rows where no corrected absorbance data (untrusted or blancs)
    dplyr::filter(!is.na(abs_corrected)) |>
    # create unique curve_id which will be needed for downstream analysis
    dplyr::mutate(unique_curve_id = paste0(plate_id, "_col", column), .after = plate_id)

  return(std_corrected)
}


