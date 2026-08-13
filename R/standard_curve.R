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
  } else {stop("Unknown pipetting direction. Choose between `top_down` and `bottom_up`")}
  return(blank_should_be_in)
}


#** Then, standard curve functions*



#' Keeps only wells corresponding to standard curves
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     dataset, map, plate_id, column
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#' @param map_col Name of the column containing well mapping/type
#'     information. Defaults to `"map"`.
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param column_col Name of the column identifying the plate column
#'     (1-12). Defaults to `"column"`.
#' @import dplyr
#'
#' @returns A smaller tible than `data`, keeping only rows where the column `map`
#'     contain the value definind standard curve wells (default is `std_def = "Std"`)
#' @export
#'
#' @examples
#' tidy_plates
#' extract_std_data(tidy_plates)
extract_std_data <- function(
    data, std_def = "Std",
    map_col = "map",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    column_col = "column") {
  std_data <- data |>
    # take only plate-columns with standard curves
    dplyr::filter(.data[[map_col]] == std_def) |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(dataset_col, plate_id_col)))) |>
    dplyr::mutate(
      unique_curve_id = paste0(.data[[plate_id_col]], "_col", .data[[column_col]]),
      .after = dplyr::all_of(plate_id_col))
  return(std_data)
}



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
#'
#' Per-plate averages are computed separately, by [`std_blank_average()`] —
#' deliberately kept as its own step, taken on whichever of `$all`/
#' `$trusted`/`$untrusted` (possibly manually reviewed/edited) the user
#' decides to trust.
#'
#' @param data A tibble respecting the structure of [`tidy_table`]. `data` must have,
#'     though not necessarily in that order, the following column names:
#'     row, column, well_id, unique_well_id, dataset, plate_id, map, abs
#' @param std_def A string, defaults with `"Std"`: how data from wells containing the standard curve are referred to.
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#' @param row_col Name of the column containing well row (A-H). Defaults
#'     to `"row"`.
#' @param well_id_col Name of the column identifying wells. Defaults to
#'     `"well_id"`.
#' @param unique_well_id_col Name of the column identifying wells
#'     uniquely across plates. Defaults to `"unique_well_id"`.
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param column_col Name of the column identifying the plate column
#'     (1-12). Defaults to `"column"`.
#' @param map_col Name of the column containing well mapping/type
#'     information. Defaults to `"map"`.
#' @param value_col Name of the numeric absorbance column. Defaults to
#'     `"abs"`.
#'
#' @returns A list of 3 elements characterizing blank wells:
#'     - `list$all` contains all supposed blank values (minimum values from each curve)
#'     - `list$trusted` contains all trusted blank values (minimum values and wells in the "correct" row (A or H))
#'     - `list$untrusted` contains all untrusted wells
#'
#' @export
#'
#' @examples
#' tidy_plates
#' std_blank <- tidy_plates |> extract_std_blank(std_def = "Std")
#' std_blank$all ; std_blank$trusted ; std_blank$untrusted
extract_std_blank <- function(
    data,
    std_def = "Std",
    pipetting_direction = "top_down",
    row_col = "row",
    well_id_col = "well_id",
    unique_well_id_col = "unique_well_id",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    column_col = "column",
    map_col = "map",
    value_col = "abs"
) {

  # in case still character, correct absorbance values to be numerical
  data <- data |>
    dplyr::mutate(dplyr::across(dplyr::all_of(value_col), as.numeric))

  # extract std data (only wells where the standard solutions have been pipetted)
  std_data <- extract_std_data(
    data, std_def,
    map_col = map_col, dataset_col = dataset_col,
    plate_id_col = plate_id_col, column_col = column_col)

  # per curve, find the well with the smallest absorbance value - this
  # is where the blank is EXPECTED to be, checked against below
  std_min <- std_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(dataset_col, plate_id_col, column_col)))) |>
    dplyr::select(!dplyr::all_of(unique_well_id_col)) |>
    dplyr::slice_min(.data[[value_col]], with_ties = FALSE) |>
    dplyr::rename(well_min = dplyr::all_of(well_id_col)) |>
    dplyr::select(well_min, dplyr::all_of(c(dataset_col, plate_id_col, column_col, "unique_curve_id")))

  # extract the well that SHOULD contain the blank, based on the
  # declared pipetting direction (row A for top_down, row H for
  # bottom_up) - pipette_to_row() unifies what used to be two near-
  # identical branches into one
  std_blank_all <- std_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(dataset_col, plate_id_col, column_col)))) |>
    dplyr::filter(.data[[row_col]] == pipette_to_row(pipetting_direction)) |>
    dplyr::select(dplyr::all_of(c(
      well_id_col, dataset_col, plate_id_col, row_col, column_col,
      unique_well_id_col, "unique_curve_id", value_col)))

  # check whether the declared blank well actually matches the smallest
  # value found per curve; if not, that well is "untrusted"
  blank_min_check <- std_min |>
    dplyr::left_join(
      std_blank_all,
      by = c(column_col, dataset_col, plate_id_col, "unique_curve_id")) |>
    dplyr::relocate(dplyr::all_of(well_id_col), .after = dplyr::all_of("well_min"))

  std_blank_untrusted <- blank_min_check |>
    dplyr::filter(.data[[well_id_col]] != .data[["well_min"]]) |>
    dplyr::select(!dplyr::all_of("well_min"))

  std_blank_trusted <- std_blank_all |>
    dplyr::anti_join(
      std_blank_untrusted,
      by = c(column_col, well_id_col, dataset_col, plate_id_col, "unique_curve_id")) |>
    dplyr::ungroup()

  std_blank <- list(
    "all" = std_blank_all,
    "trusted" = std_blank_trusted,
    "untrusted" = std_blank_untrusted
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
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param value_col Name of the numeric absorbance column. Defaults to
#'     `"abs"`.
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
    std_blank_data,
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    value_col = "abs"
){
  std_blank_avg <- std_blank_data |>
    dplyr::ungroup() |>
    dplyr::summarise(
      .by = dplyr::all_of(c(dataset_col, plate_id_col)),
      blank_avg = mean(.data[[value_col]]),
      blank_sdev = stats::sd(.data[[value_col]])
    ) |>
    dplyr::mutate(blank_coeff_var_percent = 100 * .data[["blank_sdev"]] / .data[["blank_avg"]])

  return(std_blank_avg)
}


#' Get concentration of standard curve from metadata
#'
#' @param metadata A tibble following a similar structure as [`metadata`], see documentation of `metadata for more details
#' @param pipetting_direction Can only be "top_down" (default) or "bottom_up".
#'     A top_down pipetting means that the curve was pipetted vertically (in a single column of the 96-well plate),
#'     with the smallest value (blank) in row A and the highest value in row H.
#'     Conversely, bottom_up pipetting would have the blank in row H and the most concentrated solution in row A
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param std_conc_col Name of the column containing the standard curve
#'     concentrations (dash-separated, one value per row A-H). Defaults
#'     to `"std_conc"`.
#' @param row_col Name of the output column identifying plate row (A-H).
#'     Defaults to `"row"`.
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
    pipetting_direction = "top_down",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    std_conc_col = "std_conc",
    row_col = "row"
) {
  if (pipetting_direction == "top_down") {
    row_curve <- LETTERS[1:8]
  } else if (pipetting_direction == "bottom_up") {
    row_curve <- LETTERS[8:1]
  }

  curve_concentration <- metadata |>
    dplyr::select(dplyr::all_of(c(dataset_col, plate_id_col, std_conc_col))) |>
    tidyr::separate_wider_delim(dplyr::all_of(std_conc_col), delim = "-", names = row_curve) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(row_curve),
      names_to = row_col,
      values_to = std_conc_col) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(std_conc_col), as.double))

  return(curve_concentration)
}



#' Display one or more standard curve(s)
#'
#' Plots raw absorbance (y-axis) vs concentration (x-axis), grouping the data by `plate_id`.
#' Uses the `ggplot2` package.
#'
#' @param std_data The table containing the data to be plotted. Must contain the
#'     columns referenced by `conc_col`, `value_col`, `group_col`, `label_col`,
#'     and `unit_col`. If the plot shows too many curves, consider filtering the
#'     input data frame or adding a ggplot layer to facet
#'     (see `?facet_wrap()` or `?facet_grid()`).
#' @param through_origin Whether the smooth curve should be constrained to go
#'     through the origin. Default to TRUE, which only makes sense for absorbance
#'     data that has already been blank-corrected
#' @param model Which model to use for the smooth curve. Accepts either `linear`
#'     (default) or `poly` for polynomial model (y = ax + bx^2 + c, with c = 0
#'     if `through_origin = TRUE`)
#' @param conc_col Name of the column containing concentration. Defaults to
#'     `"std_conc"`.
#' @param value_col Name of the column containing absorbance. Defaults to
#'     `"abs"`.
#' @param group_col Name of the column used to group/colour/fill curves
#'     (e.g. one curve per plate). Defaults to `"column"`.
#' @param colour_col Name of the column used for colour/fill. If `NULL`
#'     (the default), uses `group_col` (same variable drives both
#'     grouping and colour, as originally). Set independently to colour
#'     by something else meaningful (e.g. date, dilution factor) while
#'     still fitting one regression line per `group_col`.
#' @param label_col Name of the column used to label individual points.
#'     Defaults to `"well_id"`.
#' @param unit_col Optional: how to label the concentration unit on the
#'     x-axis. `NULL` (the default) shows no unit at all. Otherwise,
#'     either the name of a column in `std_data` to read the unit from,
#'     or a literal string (e.g. `"mg/L"`) applied uniformly.
#' @param smooth_alpha Transparency of the fitted smooth-curve
#'     ribbon/line. Defaults to `0.3`.
#' @param smooth_linewidth Width of the fitted smooth-curve line.
#'     Defaults to `0.5`.
#' @param smooth_linetype Line type of the fitted smooth-curve line
#'     (`ggplot2` linetype code). Defaults to `2` (dashed).
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
#' plot_std(std_data, through_origin = FALSE, model = "linear", unit_col = "std_unit") +
#'   ggplot2::facet_wrap(dataset~plate_id)
plot_std <- function(
    std_data,
    through_origin = TRUE,
    model = "linear",
    conc_col = "std_conc",
    value_col = "abs",
    group_col = "column",
    colour_col = NULL,
    label_col = "well_id",
    unit_col = NULL,
    smooth_alpha = 0.3,
    smooth_linewidth = 0.5,
    smooth_linetype = 2
) {
  # colour_col defaults to group_col when not given, preserving original
  # behaviour (same variable drives both grouping and colour); set it
  # independently to colour by something else meaningful (e.g. date,
  # dilution factor) while still fitting one line per group_col
  if (is.null(colour_col)) colour_col <- group_col

  # build the x-axis label, optionally including a unit: unit_col can be
  # NULL (no unit shown, matches original behaviour), a literal string
  # applied uniformly (e.g. "mg/L"), or the name of a column to read the
  # unit from
  if (is.null(unit_col)) {
    x_label <- "Concentration of Standard Curve"
    } else if (unit_col %in% names(std_data)) {
      unit_text <- paste(unique(std_data[[unit_col]]), collapse = ", ")
      x_label <- paste0("Concentration of Standard Curve [", unit_text, "]")
      } else {
        x_label <- paste0("Concentration of Standard Curve [", unit_col, "]")
        }

  y_range <- max(as.numeric(std_data[[value_col]])) - min(as.numeric(std_data[[value_col]]))

  std_data |>
    ggplot2::ggplot(ggplot2::aes(
      x = as.numeric(.data[[conc_col]]), y = as.numeric(.data[[value_col]]),
      group = .data[[group_col]], colour = .data[[colour_col]], fill = .data[[colour_col]])) +
    ggplot2::theme_minimal() +
    ggplot2::ylab("Absorbance") +
    ggplot2::xlab(x_label) +
    ggplot2::geom_smooth(
      method = "lm",
      formula =
        if (through_origin & model == "linear") (y ~ 0 + x)
      else if (through_origin & model == "poly") (y ~ 0 + x + I(x^2))
      else if (model == "linear") (y ~x)
      else if (model == "poly") (y ~ x + I(x^2)),
      alpha = smooth_alpha,
      linewidth = smooth_linewidth, linetype = smooth_linetype) +
    #geom_line()
    ggplot2::geom_point(ggplot2::aes(colour = .data[[colour_col]])) +
    ggplot2::geom_text(
      ggplot2::aes(label = .data[[label_col]], colour = .data[[colour_col]]),
      alpha = 1, position = ggplot2::position_nudge(y = y_range/20),
      size = 4, fontface = "plain")
}



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
#' @param row_col Name of the column containing well row (A-H). Defaults
#'     to `"row"`.
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param column_col Name of the column identifying the plate column
#'     (1-12). Defaults to `"column"`.
#' @param map_col Name of the column containing well mapping/type
#'     information. Defaults to `"map"`.
#' @param value_col Name of the numeric absorbance column. Defaults to
#'     `"abs"`.
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
    std_blank_average = NULL,
    std_blank_trusted = NULL,
    std_blank = NULL,
    row_col = "row",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    column_col = "column",
    map_col = "map",
    value_col = "abs"
) {
  ## Getting trusted blank average data

  if (is.null(std_blank_average)) {
    if (is.null(std_blank_trusted)) {
      if (is.null(std_blank)) {
        std_blank <- extract_std_blank(
          data, std_def = std_def, pipetting_direction = pipetting_direction,
          row_col = row_col, dataset_col = dataset_col,
          plate_id_col = plate_id_col, column_col = column_col,
          map_col = map_col, value_col = value_col)
      }
      std_blank_trusted <- std_blank$trusted
    }
    # calling the std_blank_average() FUNCTION here - R resolves this
    # correctly despite the same-named parameter above, since a name in
    # call position specifically looks for a function binding
    std_blank_average <- std_blank_average(
      std_blank_trusted, dataset_col = dataset_col,
      plate_id_col = plate_id_col, value_col = value_col)
  }

  std_corrected <- extract_std_data(
    data, std_def = std_def, map_col = map_col,
    dataset_col = dataset_col, plate_id_col = plate_id_col,
    column_col = column_col) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(value_col), as.numeric)) |>
    # keep only data that is not from blank wells
    dplyr::filter(
      .data[[row_col]] != pipette_to_row(pipetting_direction)
    ) |>
    dplyr::right_join(std_blank_average, by = c(dataset_col, plate_id_col)) |>
    dplyr::mutate(abs_corrected = .data[[value_col]] - .data[["blank_avg"]], .keep = "unused") |>
    # remove rows where no corrected absorbance data (untrusted or blanks)
    dplyr::filter(!is.na(abs_corrected))

  return(std_corrected)
}



#' Compute per-dilution Averages for Standard Curves
#'
#' Averages absorbance per plate, per row (dilution level), across
#' several standard curves pipetted on the same plate — useful when a
#' plate holds more than one curve of the same standard solution (e.g.
#' one in column 1, one in column 12). Averaging serves two purposes:
#' reducing noise before model fitting, and correcting for a
#' systematic drift between curves caused by pipetting order (a plate
#' is typically pipetted left to right, so column 1 and column 12
#' wells experience slightly different incubation times before
#' reading — averaging across the plate's curves compensates for that,
#' since same-row wells across curves are assumed to hold the same
#' concentration).
#'
#' Since the output no longer corresponds to a single real well, a
#' placeholder `column`/`well_id`/`unique_curve_id` is fabricated (see
#' `fake_column_value`) so the result still has the shape downstream
#' functions expect.
#'
#' @param std_data A tibble of std data
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param row_col Name of the column identifying plate row (A-H), used
#'     as the dilution-level grouping key. Defaults to `"row"`.
#' @param value_col Name of the numeric absorbance column averaged.
#'     Defaults to `"abs_corrected"`.
#' @param std_conc_col Name of the standard curve concentration column,
#'     used only to order rows before deduplicating other columns.
#'     Defaults to `"std_conc"`.
#' @param column_col Name of the column identifying the plate column
#'     (1-12). Defaults to `"column"`.
#' @param well_id_col,unique_well_id_col Names of the well-identifying
#'     columns. Default to `"well_id"` and `"unique_well_id"`.
#' @param fake_column_value The placeholder value used for `column_col`
#'     in the output, since averaged rows no longer correspond to a
#'     single real plate column. Defaults to `13` — deliberately
#'     outside the real 1-12 range, as a visible marker that this
#'     value doesn't represent an actual well.
#'
#' @importFrom rlang :=
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
    std_data,
    plate_id_col = "plate_id",
    row_col = "row",
    value_col = "abs_corrected",
    std_conc_col = "std_conc",
    column_col = "column",
    well_id_col = "well_id",
    unique_well_id_col = "unique_well_id",
    fake_column_value = 13
    ) {

  # compute per plate per std_conc mean
  std_mean <- std_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(c(plate_id_col, row_col)))) |>
    dplyr::summarise(abs_mean = mean(.data[[value_col]]), .groups = "drop")


  # create a table to rejoin to the std mean, to get back the columns lost in the process
  lost_columns <- std_data |>
    dplyr::arrange(dplyr::across(dplyr::all_of(c(plate_id_col, std_conc_col)))) |>
    dplyr::select(!tidyselect::any_of(c(
      column_col, "unique_curve_id", well_id_col, unique_well_id_col, value_col))) |>
    unique()

  # rejoin the mean with the relevant lost columns and recreate fake columns sometimes needed for downstream steps: column = 13; well_id ; unique_curve_id
  std_dilution_avg <- std_mean |>
    dplyr::left_join(lost_columns, by = c(plate_id_col, row_col)) |>
    dplyr::mutate(
      "{column_col}" := fake_column_value,
      "{well_id_col}" := paste0(.data[[row_col]], .data[[column_col]]),
      unique_curve_id = paste0(.data[[plate_id_col]], "_col", .data[[column_col]]),
      .after = dplyr::all_of(row_col))

  return(std_dilution_avg)
}
