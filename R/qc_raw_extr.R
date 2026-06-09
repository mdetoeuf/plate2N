
#' Quality check of raw absorbance data for extractant wells
#'
#' Extracts plate ID's where it is suspected that raw absorbance
#'     data for extractant (sample blank) still contain some outliers.
#'     The criterion for a plate to be deemed "suspicious" is defined by max_coeff
#'
#' `qc_raw_extr()` is not yet optimized for the case where there are 2 exractant:
#'     it works, but it returns a list of problematic plates without telling which
#'     extractant is problematic on that plate
#'
#' @param data A tibble, as in `tidy_plates`, optional. It is only used if argument
#'     `extractant_data` is `NULL` to compute it with `extractant_average()` and
#'     the argument `extr_def`.
#' @param extractant_average Defaults to NULL, where it is computed from `data`
#'     using `extractant_average(data)`
#' @param extr_def Optional: is needed to compute `extractant_average` if needed.
#'     Defaults to "extr"
#' @param max_coeff User-defined, in % (defaults at 5): determines the threshold
#'     coefficient of variation for raw absorbance of extractant wells, above which
#'     plates will be considered "suspicious"
#' @param suppress_message Logical, whether or not to suppress the "success" message (given when no plate is above the `max_coeff`)
#' @param suppress_warning Logical, whether or not to suppress the warning (given when some plate are above the `max_coeff`)
#'
#' @import dplyr
#' @importFrom magrittr extract2
#' @returns ID's of suspicious plates. (+ a message or warning if not suppressed)
#'
#' @export
#'
#' @examples
#' # example code
#' data <- tidy_plates
#' extractant_average <- tidy_plates |> extractant_average()
#' (suspicious_plate_id <- qc_raw_extr(data, max_coeff = 5))
#'
#' # example with 2 extractants
#' dbl_extr_plate
#' (suspicious_extr_per_plate <- qc_raw_extr(
#'     dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
#'     max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE))
#'
#'
qc_raw_extr <- function(
    #extractant_average = NULL, # must be a tibble in format as `extractant_average(tidy_plates)$blank_avg`
    data = NULL,
    extractant_average = NULL,
    extr_def = "extr",
    max_coeff = 5,
    suppress_message = FALSE,
    suppress_warning = FALSE
) {

  # compute extractant average if missing
  if (is.null(extractant_average)) {
    extractant_average <- extractant_average(data, extr_def = extr_def)
    }

  # if all coefficient of variation below threshold --> YAY
  if (max(extractant_average$blank_coeff_var_percent) < max_coeff) {
    if (!suppress_message) {
      message(paste0(
        "
        Good news: all plates show a satisfactorily small variation ",
        "for raw blank (extractant) absorbance values. ",
        "This means that the coefficient of variation is below the threshold of ",
        max_coeff,
        "%."))
    }

  # ELSE, if threshold is passed
  } else if (max(extractant_average$blank_coeff_var_percent) >= max_coeff)  {

    # store id of problematic plates
    # suspicious_plate_id <- extractant_average |>
    #   dplyr::filter(blank_coeff_var_percent > max_coeff) |>
    #   dplyr::select(plate_id) |> as.vector() |> magrittr::extract2(1)

    suspicious_extr <- extractant_average |>
      dplyr::filter(blank_coeff_var_percent > max_coeff) |>
      dplyr::select(plate_id, map)

    # send a warning
    if (!suppress_warning) {
      warning(paste0(
        "
        There is a big variation in absorbance values for the blank (more than ",
        max_coeff,
        "%).
        Remove the most unlikely values / remove outliers manually.
        Suspicious plate ID's are returned"))
    }

    return(suspicious_extr)
  }
}


utils::globalVariables(c("map", "abs", "plate_id"))
#' Extract suspicious extractant wells
#'
#' @param data A tibble, as in `tidy_plates`.
#' @param extr_def Needed to compute `extractant_average`. Defaults to "extr"
#' @param suspicious_extr_per_plate If NULL (default), computed from `data` with
#'     `qc_raw_extr(data, max_coeff = max_coeff)`. Should be a tibble with 2 columns:
#'     `plate_id` and `map`
#' @param max_coeff User-defined threshold value, defaults at 5%. All plates for which
#'     the coefficient of variation for extractant raw absorbance is above this threshold
#'     will be considered "suspicious plates"
#'
#' @import dplyr ggplot2
#'
#' @returns A subset of `data` containing only plates where raw extractant values
#'     should be reviewed (because their coefficient of variation is above the
#'     user-defined threshold)
#'
#' @export
#'
#' @examples
#' data <- tidy_plates
#' # 0.5 is unreasonable in most uses, but is used here to ensure some output
#' suspicious_plate_id <- qc_raw_extr(data, max_coeff = 5,
#'     suppress_message = TRUE, suppress_warning = TRUE)
#' (suspicious_extr <- suspicious_extr(data, max_coeff = 0.5,
#'     suspicious_extr_per_plate = suspicious_plate_id))
#'
#' # example with 2 extractants
#' dbl_extr_plate
#' (suspicious_extr_per_plate <- qc_raw_extr(
#'     dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
#'     max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE))
#' (suspicious_extr <- suspicious_extr(
#'     dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
#'     max_coeff = 5, suspicious_extr_per_plate = suspicious_extr_per_plate))
suspicious_extr <- function(
    data,# = NULL,
    # extractant_average = NULL,
    extr_def = "extr",
    suspicious_extr_per_plate = NULL, # suspicious_plate_id <- qc_raw_extr(data)
    max_coeff = 5

) {
  # compute extractant average if missing
#  if (is.null(extractant_average)) {
    extractant_average <- extractant_average(data, extr_def = extr_def)
 # }

  if (is.null(suspicious_extr_per_plate)) {
    suspicious_extr_per_plate <- qc_raw_extr(
      extractant_average = extractant_average,
      max_coeff = max_coeff, suppress_message = TRUE, suppress_warning = TRUE)
    }

  # suspicious_extractant <- extract_extractant(data, extr_def = extr_def) |>
  #   dplyr::group_by(plate_id, map) |>
  #   dplyr::filter(plate_id %in% suspicious_extr) |>
  #   dplyr::arrange(plate_id) |>
  #   mutate(abs = as.numeric(abs))

    suspicious_extractant <- extract_extractant(data, extr_def = extr_def) |>
      dplyr::right_join(suspicious_extr_per_plate) |>
      dplyr::arrange(plate_id, map) |>
      dplyr::mutate(abs = as.numeric(abs))

  return(suspicious_extractant)
}



#' Multiple distribution plot to review suspicious extractant values and spot outliers
#'
#' @param suspicious_extractant A tibble as generated by `suspicious_extr()`,
#'     can be computed from `data` with `suspicious_extr()`
#' @param data Defaults to NULL. If provided, must be a tibble formatted as `tidy_plates`
#' @param max_coeff User-defined threshold value, defaults at 5%. All plates for which
#'     the coefficient of variation for extractant raw absorbance is above this threshold
#'     will be considered "suspicious plates". ! Be consistent with previous steps
#'
#' @importFrom patchwork wrap_plots
#' @importFrom patchwork plot_annotation
#'
#' @returns A multiple plot for quality checking of extractant wells distribution
#'     and definition of threshold values
#' @export
#'
#' @examples
#' data <- tidy_plates
#' # 0.5 is unreasonable in most uses, but is used here to ensure some output
#' suspicious_extr_per_plate <- qc_raw_extr(data, max_coeff = 5,
#'     suppress_message = TRUE, suppress_warning = TRUE)
#' suspicious_extr <- suspicious_extr(data, max_coeff = 5,
#'     suspicious_extr_per_plate = suspicious_extr_per_plate)
#' multiplot_outlier_extr(suspicious_extractant = suspicious_extr, max_coeff = 5)
#' ## Tip: if too many curves appear, consider cutting `suspicious_extractant`
#' ##.     into several subsets, to be given as input for multiple runs of `multiplot_outlier_extr()`
multiplot_outlier_extr <- function(
    suspicious_extractant = NULL,
    data = NULL, # must be provided if suspicious_extractant is NULL
    max_coeff = 5

){
  if (is.null(suspicious_extractant)) {
    suspicious_extractant <- suspicious_extr(data, max_coeff = max_coeff)
  }

  plots <- suspicious_extractant |>
    dplyr::group_map(
      .f = ~ggplot2::ggplot(.x, ggplot2::aes(x = abs)) +
        ggplot2::geom_histogram() +
        ggplot2::theme_minimal() +
        ggplot2::labs(title = .y)
    )

  multiple_plot <- patchwork::wrap_plots(plots, axis_titles = "collect") +
    patchwork::plot_annotation(title = "Distribution of absorbance of extractant",
                               subtitle = paste0(
                                 "Only displays plates for which the coefficient of variation\nfor the extractant is above ",
                                 max_coeff)
    )

  return(multiple_plot)
}


utils::globalVariables(c("abs", "plate_id", "dataset", "well_id", "plate_nb"))
#' Identify outlier-wells within plates containing suspicious extractant data
#'
#' @param suspicious_extractant A tibble as generated by `suspicious_extr()`,
#'     can be computed with `suspicious_extr()`
#' @param max_coeff User-defined threshold value, defaults at 5%. All plates for which
#'     the coefficient of variation for extractant raw absorbance is above this threshold
#'     will be considered "suspicious plates". ! Be consistent with previous steps
#'
#' @import ggplot2
#' @importFrom forcats fct_rev
#' @importFrom ggrepel geom_text_repel
#'
#'
#' @returns A boxplot generated by ggplot, highlighting information necessary to
#'     create a tibble of wells to be removed with `remove_wells()`, i.e.,
#'     for each boxplot: plate_ids, well_ids and plate number (corresponding to
#'     the order of plate ids in `suspicious_extractant`)
#' @export
#'
#' @examples
#' data <- tidy_plates
#' suspicious_plate_id <- qc_raw_extr(
#'    data, max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE)
#' suspicious_extr <- suspicious_extr(
#'    data, max_coeff = 5, suspicious_extr_per_plate = suspicious_plate_id)
#' boxplot_outlier_extr(
#'     suspicious_extractant = suspicious_extr,
#'     max_coeff = 5)
#'
#' # case with 2 extractants
#' dbl_extr_plate
#' (suspicious_extr_per_plate <- qc_raw_extr(
#'     dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
#'     max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE))
#' (suspicious_extr <- suspicious_extr(
#'     dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
#'     max_coeff = 5, suspicious_extr_per_plate = suspicious_extr_per_plate))
#' boxplot_outlier_extr(
#'     suspicious_extractant = suspicious_extr,
#'     max_coeff = 5)
boxplot_outlier_extr <- function(
    suspicious_extractant, #suspicious_extractant = suspicious_extr
    max_coeff = 5
) {


  nb_plates <- suspicious_extractant |>
    ungroup() |>
    select(dataset, plate_id) |>
    unique() |>
    nrow()

  nb_different_extr <- suspicious_extractant |> select(map) |> unique() |> nrow()

  plate_numbers <- suspicious_extractant |>
    select(plate_id) |>
    unique() |>
    mutate(plate_nb = seq(1, nb_plates))

  suspicious_extractant <- suspicious_extractant |> left_join(plate_numbers)

  text_data <- suspicious_extractant |> select(plate_id, plate_nb) |> unique()

  boxplot <- suspicious_extractant |>
#    ggplot2::ggplot(ggplot2::aes(x = abs, y = plate_id)) +
    ggplot2::ggplot(ggplot2::aes(x = abs, y = forcats::fct_rev(plate_id))) +
    ggplot2::theme_minimal() +
    ggplot2::geom_boxplot(
      fill = "grey90", color = "grey70",
      outliers = FALSE,
      # outlier.colour = "grey50",
      # outlier.fill = "grey50",
      # outlier.alpha = 0.6#,
      #outlier.shape = 1
    ) +
    ggplot2::geom_jitter(colour = "grey30", alpha = 0.7, shape = 1, height = 0.1) +
    ggrepel::geom_text_repel(ggplot2::aes(label = well_id), colour = "purple", alpha = 1, min.segment.length = 1) +
    geom_text(
      data = text_data,
      aes(x = 0, y = plate_id, label = paste0("plate", plate_nb), hjust = 0, vjust = -2),
      colour = "grey20") +
    ggplot2::ylab("Plate id") + ggplot2::xlab("raw absorbance of extractant wells") +
    ggplot2::labs(title = "Identifying outliers for extractant wells",
         subtitle = paste0("Only plates with outliers are displayed here\n(coefficient of variation of absorbance > ", max_coeff, "%)")) +
    ggplot2::facet_wrap(~map)

  boxplot

  return(boxplot)

}

