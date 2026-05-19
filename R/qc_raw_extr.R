
#' Quality check of raw absorbance data for extractant wells
#'
#' Extracts plate ID's where it is suspected that raw absorbance
#'     data for extractant (sample blank) still contain some outliers.
#'     The criterion for a plate to be deemed "suspicious" is defined by max_coeff
#'
#' @param data A tibble, as in `tidy_plates`
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
#' suspicious_plate_id <- qc_raw_extr(data, max_coeff = 0.5)
qc_raw_extr <- function(
    #extractant_average = NULL, # must be a tibble in format as `extractant_average(tidy_plates)$extr_avg`
    data = NULL, #either data or extractant_avg must be provided
    max_coeff = 5,
    suppress_message = FALSE,
    suppress_warning = FALSE
) {

  # compute extractant average if missing
  #if (is.null(extractant_average)) {
    extractant_average <- extractant_average(data)
 # }

  # if all coefficient of variation below thrsehold --> YAY
  if (max(extractant_average$extr_coeff_var_percent) < max_coeff) {
    if (!suppress_message) {
      message(paste0(
        "Good news: all plates show a satisfactorily small variation ",
        "for raw blank (extractant) absorbance values. ",
        "This means that the coefficient of variation is below the threshold of ",
        max_coeff,
        "%."))
    }

  # ELSE, if threshold is passed
  } else if (max(extractant_average$extr_coeff_var_percent) >= max_coeff)  {

    # store id of problematic plates
    suspicious_plate_id <- extractant_average |>
      dplyr::filter(extr_coeff_var_percent > max_coeff) |>
      dplyr::select(plate_id) |> as.vector() |> magrittr::extract2(1)

    # send a warning
    if (!suppress_warning) {
      warning(paste0(
        "There is a big variation in absorbance values for the blanc (more than ",
        max_coeff,
        "%).
        Remove the most unlikely values / remove outliers manually.
        Suspicious plate ID's are returned"))
    }

    return(suspicious_plate_id)
  }
}


utils::globalVariables(c("map", "abs", "plate_id"))
#' Review suspicious extractant values and spot outliers
#'
#' @param data Tibble formatted as `tidy_plates`
#' @param suspicious_plate_id If NULL (default), computed from `data` with `qc_raw_extr(data, max_coeff = max_coeff)`
#' @param max_coeff User-defined threshold value, defaults at 5%. All plates for which
#'     the coefficient of variation for extractant raw absorbance is above this threshold
#'     will be considered "suspicious plates"
#'
#' @import dplyr ggplot2
#' @importFrom patchwork wrap_plots
#' @importFrom patchwork plot_annotation
#'
#' @returns A list with 2 elements.
#'     `$suspicious_extractant`, a subset of `data` containing only plates where
#'     raw extractant values should be reviewed
#'     `$multiple_plot`, a collection of distributions of those raw absorbance values,
#'     to help spotting outlier wells
#'
#' @export
#'
#' @examples
#' data <- tidy_plates
#' # 0.5 is unreasonable in most uses, but is used here to ensure some output
#' suspicious_extr <- suspicious_extr(data, max_coeff = 0.5)
#' suspicious_extr$suspicious_extractant
#' suspicious_extr$multiple_plot
#'
suspicious_extr <- function(
    data,
    suspicious_plate_id = NULL, # suspicious_plate_id <- qc_raw_extr(data)
    max_coeff = 5

) {

  if (is.null(suspicious_plate_id)) {
    suspicious_plate_id <- qc_raw_extr(data, max_coeff = max_coeff)
    }

  suspicious_extractant <- extract_extractant(data) |>
    dplyr::group_by(plate_id, map) |>
    dplyr::filter(plate_id %in% suspicious_plate_id) |>
    dplyr::arrange(plate_id) |>
    mutate(abs = as.numeric(abs))

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

  return(list(
    "suspicious_extractant" = suspicious_extractant,
    "multiple_plot" = multiple_plot
  ))
}




