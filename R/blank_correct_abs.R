utils::globalVariables(c("map", "abs", "blank_avg", "abs_corrected"))


#' Transform Raw Absorbance Data into Blank-corrected Absorbance
#'
#' @param raw_wells_data A tibble, based on `tidy_plates`, can contain metadata as well.
#'     `raw_wells_data` contains the raw absorbance data to be blank-corrected.
#'     Must contain columns "abs" and "map".
#' @param per_plate_avg_blank Contains the per-plate average absorbance of the blank
#'     Must contain column "blank_avg" (rename it prior to function call if needed)
#' @param map_to_exclude A vector of strings containing all `map` definitions of
#'     wells that are not data per se (e.g., empty wells, etc.).
#'     Defaults to `c("empty","Std","extr")`. If wells to exclude are not defined
#'     by a unique "map" (e.g., blank wells of the standard curve), make sure to
#'     filter out those rows from `raw_wells_data` before the function call.
#'
#' @import dplyr
#' @importFrom roperators %ni%
#'
#' @returns A tibble with the blank-corrected absorbance. It has the same structure
#'     as `raw_wells_data`, but the `abs` column has been removed, and column
#'     `abs_corrected` has been added. The output tibble normally contains less rows
#'     than the input tibble (due to `map_to_exclude`)
#' @export
#'
#' @examples
#' data <- tidy_plates
#' extractant_average <- tidy_plates |> extractant_average()
#' blank_correct_abs(
#'     raw_wells_data = data,
#'     per_plate_avg_blank = extractant_average |> dplyr::rename(blank_avg = extr_avg),
#'     map_to_exclude = c("empty","Std","extr"))
blank_correct_abs <- function(
    raw_wells_data,
    per_plate_avg_blank,
    map_to_exclude = c("empty","Std","extr")
) {

  # Reformat raw_wells_data
  to_correct <-
    raw_wells_data |>
    # filter out irrelevant wells
    dplyr::filter(map %ni% map_to_exclude) |>
    dplyr::mutate(abs = as.numeric(abs))

  # Reformat blank_avg_data
  if ("map" %in% names(per_plate_avg_blank)) {
    blank_avg_data <- per_plate_avg_blank |> dplyr::select(!map)
  } else {
    blank_avg_data <- per_plate_avg_blank
  }


  # blank correction
  corrected_data <-
    to_correct |>
    # dplyr::mutate(abs = as.numeric(abs)) |>
    dplyr::right_join(blank_avg_data) |>
    dplyr::mutate(abs_corrected = abs - blank_avg, .keep = "unused", .after = map) |>
    # remove rows where no corrected absorbance data (untrusted or blancs)
    dplyr::filter(!is.na(abs_corrected))

  # check that no row has been lost (could happen, e.g., if "map_to_exclude" was incomplete)
  if(nrow(to_correct |> dplyr::anti_join(corrected_data) |> dplyr::select(map)) != 0) {
    warning("Some rows have been lost in the process.
               To find lost rows, walk through the source code of `blank_correct_abs()`
               and observe the output of
               `to_correct |> anti_join(corrected_data) |> select(map))`")
  }

  return(corrected_data)
}
