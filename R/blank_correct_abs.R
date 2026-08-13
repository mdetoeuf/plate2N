#' Transform Raw Absorbance Data into Blank-corrected Absorbance
#'
#' @param raw_wells_data A tibble, based on `tidy_plates`, can contain metadata as well.
#'     `raw_wells_data` contains the raw absorbance data to be blank-corrected.
#'     Must contain the columns referenced by `value_col` and `map_col`.
#' @param per_plate_avg_blank Contains the per-plate average absorbance of the blank.
#'     Must contain the column referenced by `blank_avg_col` (rename it prior to
#'     function call if needed).
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map_col` column) of the plate. Defaults to "extr". Can be a vector
#'    containing several values (see examples)
#' @param map_to_exclude A vector of strings containing all `map_col` definitions of
#'     wells that are not data per se (e.g., empty wells, etc.).
#'     Defaults to `c("empty","Std","extr")`. If wells to exclude are not defined
#'     by a unique `map_col` value (e.g., blank wells of the standard curve), make sure to
#'     filter out those rows from `raw_wells_data` before the function call.
#' @param value_col Name of the column containing raw absorbance. Defaults
#'     to `"abs"`.
#' @param map_col Name of the column containing well mapping/type
#'     information, in both `raw_wells_data` and (if present)
#'     `per_plate_avg_blank`. Defaults to `"map"`.
#' @param blank_avg_col Name of the column in `per_plate_avg_blank`
#'     containing the per-plate average blank absorbance. Defaults to
#'     `"blank_avg"`.
#' @param dataset_col,plate_id_col Names of the columns identifying
#'     dataset and physical plate, used to join `raw_wells_data` with
#'     `per_plate_avg_blank`. Default to `"dataset"` and `"plate_id"`.
#' @param unique_well_id_col Name of the column uniquely identifying a
#'     well, used only to check for any accidentally-dropped rows after
#'     the join. Defaults to `"unique_well_id"`.
#'
#' @returns A tibble with the blank-corrected absorbance. It has the same structure
#'     as `raw_wells_data`, but the `value_col` column has been removed, and column
#'     `abs_corrected` has been added. The output tibble normally contains less rows
#'     than the input tibble (due to `map_to_exclude`)
#' @export
#'
#' @examples
#' data <- tidy_plates
#' extractant_average <- tidy_plates |> extractant_average()
#' blank_correct_abs(
#'     raw_wells_data = data,
#'     per_plate_avg_blank = extractant_average,
#'     map_to_exclude = c("empty","Std","extr"))
#'
#' # case of double extractant
#' data <- dbl_extr_plate
#' extractant_average <- dbl_extr_plate |> extractant_average(extr_def = c("extr_1", "extr_2"))
#' blank_correct_abs(
#'     raw_wells_data = data,
#'     per_plate_avg_blank = extractant_average,
#'     extr_def = c("extr_1", "extr_2"),
#'     map_to_exclude = c("empty","Std","extr_1", "extr_2"))
blank_correct_abs <- function(
    raw_wells_data,
    per_plate_avg_blank,
    extr_def = "extr",
    map_to_exclude = c("empty","Std","extr"),
    value_col = "abs",
    map_col = "map",
    blank_avg_col = "blank_avg",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    unique_well_id_col = "unique_well_id"
) {
  # Reformat raw_wells_data: filter out irrelevant wells, force
  # absorbance to numeric
  to_correct <-
    raw_wells_data |>
    dplyr::filter(!(.data[[map_col]] %in% map_to_exclude)) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(value_col), as.numeric))

  # add "extr_id" column if missing (case when there is only 1 extractant)
  if (!("extr_id" %in% names(to_correct))) {
    to_correct <- to_correct |> dplyr::mutate(extr_id = rep(extr_def))
  }

  # only join on extr_id when per_plate_avg_blank genuinely distinguishes
  # blanks per extractant (i.e. it originally had a map-like column) -
  # otherwise (e.g. a standard-curve blank average, with no extractant
  # concept at all) the blank applies uniformly, and forcing extr_id
  # into the join key would require an exact match that was never
  # meaningful to begin with - restores the original implicit join's
  # actual behavior, just made explicit instead of accidental
  blank_has_extr_id <- map_col %in% names(per_plate_avg_blank)
  if (blank_has_extr_id) {
    per_plate_avg_blank <- per_plate_avg_blank |> dplyr::rename(extr_id = dplyr::all_of(map_col))
  }

  join_key <- c(dataset_col, plate_id_col)
  if (blank_has_extr_id) join_key <- c(join_key, "extr_id")

  # blank correction
  corrected_data <-
    to_correct |>
    dplyr::right_join(per_plate_avg_blank, by = join_key) |>
    dplyr::mutate(
      abs_corrected = .data[[value_col]] - .data[[blank_avg_col]],
      .keep = "unused", .after = dplyr::all_of(map_col)) |>
    # remove rows where no corrected absorbance data (untrusted or blanks)
    dplyr::filter(!is.na(abs_corrected))

  # check that no row has been lost (could happen, e.g., if "map_to_exclude" was incomplete)
  if (nrow(to_correct |>
           dplyr::anti_join(corrected_data, by = unique_well_id_col) |>
           dplyr::select(dplyr::all_of(map_col))) != 0) {
    warning("Some rows have been lost in the process.
               To find lost rows, walk through the source code of `blank_correct_abs()`
               and observe the output of
               `to_correct |> anti_join(corrected_data) |> select(map))`")
  }
  return(corrected_data)
}
