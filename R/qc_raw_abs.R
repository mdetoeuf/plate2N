utils::globalVariables(c("map", "abs", "dataset", "plate_id", "well_id"))

#' Quality Check (QC) of raw absorbance data
#'
#' `qc_raw_abs()` extracts data relating to wells for which the absorbance is outside of a user-defined range.
#' Whereas there is a long-lasting tradition of setting "acceptable" absorbance values between 0.1 and 1 (default values for this function),
#' in reality, the acceptable range will depend on experiment, usage and quality of the spectrophotomer.
#' Note that values lower than 0.1 are not rare, especially for blank and lower values in the standard curve.
#'
#' @param data Tibble, in a similar form to our [`plate2N::tidy_table`].
#'     In particular, columns `map`, `abs`, `dataset`, `plate_id`, `well_id` must be present and named so.
#' @param empty_wells Character string corresponding to how empty wells are described in the plate mapping.
#'     Defaults to "empty", can also be a vector containing several values. Note that wells described as `NA`
#'     in the map column will also be ignored.
#' @param min_abs,max_abs Lowest and highest accepted value for absorbance, default at 0.1 and 1, respectively.
#' @param show_msg,show_warning Whether to keep (TRUE) or suppress (FALSE) the message or warning
#'     that are returned in the case of absence (message) or presence (warning) of suspicious, out-of-range, wells
#' @param show_plot Whether to display the associated plot (histogram of absorbance values).
#'     Default is `TRUE`. Note that the next arguments are only relevant is `show_plot = TRUE`.
#' @param plot_binwidth To set the binwidth of the histogram. Default is 0.01
#' @param plot_col_facet Which column to use to facet the plots. For no facetting,
#'     choose `plot_col_facet = "none"` (For now, only facet with 1 axis is possible)
#' @param export_plot Defaults to null. Set it to a string to save the plot in the global environment,
#'     the string will name the object (e.g., `export_plot = "abs_distrib"` will save an object called `abs_distrib`)
#'
#' @import dplyr ggplot2 tidyselect
#' @importFrom roperators %ni%
#'
#' @returns A table with 5 columns.
#'     The first 3 (dataset, plate_id, well_id) allow the unique identification of suspicious wells
#'     and can be used to run [`remove_wells()`]. The next 2 columns (map, abs) allow further visualization of those suspicious wells
#' @export
#'
#' @examples
#' # bring some NA (abs) and empty wells in tidy_table to check that those wells are removed
#' data <- tidy_table
#' data$abs[1] <- NA
#' data$map[2] <- "empty"
#' qc_raw_abs(data)
qc_raw_abs <- function(
    data, # data = tidy_table
    min_abs = 0.1,
    max_abs = 1,
    empty_wells = "empty",
    show_msg = TRUE,
    show_warning = TRUE,
    show_plot = TRUE,
    plot_binwidth = 0.01,
    plot_col_facet = "dataset",
    export_plot = NULL
) {

  # remove empty wells (marked as "empty" --> keep only "full" wells)
  # and remove NAs
  full <- data |>
    dplyr::filter(map %ni% empty_wells, !is.na(abs))

  # initiate data frame that will contain suspicious well ids
  # i = 1
  suspicious_rows <- c()
  for (i in 1:nrow(full)) {
    #  if (full$absorbance[i] < min_abs || full$absorbance[i] > max_abs) {
    if (full$abs[i] < min_abs | full$abs[i] > max_abs) {
      #print(full$absorbance[i])
      suspicious_rows <- append(suspicious_rows, i)
    }
  }

  # Send a warning message
  if (!is.null(suspicious_rows)) {
    if (show_warning) {
      warning(paste0(
        length(suspicious_rows),
        " wells out of ",
        nrow(full),
        " are out of range for absorbance, i.e., not in the set boundaries of [",
        min_abs,
        "; ",
        max_abs,
        "]. \nSee table to identify suspicious wells. "))
    }
  } else {
    if (show_msg) {
      message(paste0(
        "!! YAY !! All wells are in range for absorbance between ",
        min_abs,
        " and ",
        max_abs))
    }

  }
  suspicious_wells <- full |>
    dplyr::filter(dplyr::row_number() %in% suspicious_rows) |>
    dplyr::select(dataset, plate_id, well_id, map, abs)

  if (show_plot | !is.null(export_plot)) {
    # get number of plots (facets) = nb of N species in data set (for now dataset, still have to work N_sp in the table)
      plot_n_facets <- full |> dplyr::select(tidyselect::any_of(plot_col_facet)) |> unique() |> length()

    hist_abs <- full |>
      ggplot2::ggplot(ggplot2::aes(x = as.numeric(abs))) +
      ggplot2::theme_minimal() +
      ggplot2::geom_histogram(binwidth = plot_binwidth) +
      ggplot2::geom_vline(ggplot2::aes(xintercept = min_abs), color = "red", alpha = 0.5) +
      ggplot2::geom_vline(ggplot2::aes(xintercept = max_abs), color = "red", alpha = 0.5) +
      ggplot2::annotate(geom = "label", x = min_abs, y = -0.5, label = min_abs, color = "red", size = 2.5) +
      ggplot2::annotate(geom = "label", x = max_abs, y = -0.5, label = max_abs, color = "red", size = 2.5) +
      ggplot2::xlab("raw absorbance") +
      {if (plot_col_facet != "none") ggplot2::facet_wrap(~ .data[[plot_col_facet]], nrow = plot_n_facets) }+
      ggplot2::labs(title = "Distribution of absorbance, all data")

    if (show_plot) {plot(hist_abs)}

    if (!is.null(export_plot)) {
      assign(export_plot, hist_abs, envir = .GlobalEnv)
    }
  }

  return(suspicious_wells)
}
