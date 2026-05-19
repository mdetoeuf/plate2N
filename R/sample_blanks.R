


#' Extracting "extractant" data (blank for samples) from plate tidy table
#'
#' @param data A tibble like `tidy_plates`
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map`column) of the plate
#'
#' @returns A subset of `data`, containing only extractant data
#' @export
#'
#' @examples
#' data = tidy_plates
#' extract_extractant(data)
extract_extractant <- function(
    data,
    extr_def = "extr"
    ) {

  extractant_data <- data |>
    dplyr::filter(map == "extr")

  return(extractant_data)
}

utils::globalVariables(c("extr_sdev", "extr_avg", "plate_id", "map", "abs"))


#' Computing the per-plate average for raw absorbance of the extractant (blank for samples)
#'
#' @param data A tibble like `tidy_plates`
#' @param extractant_data Alternatively, A tibble containing only extractant data
#'    Defaults to NULL, where it would be computed from `data` using `extract_extractant(data)`
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map`column) of the plate
#'
#' @returns A tibble with one row per plate, contianing the average, standard
#'    deviation and coefficient of variation of raw absorbance of the extractant
#' @export
#'
#' @examples
#' data = tidy_plates
#' (extr_avg <- extractant_average(data))
extractant_average <- function(
    data = NULL, #either data or extractant_data must be provided
    extractant_data = NULL,
    extr_def = "extr"
) {

  # computing extractant data from data if missing
  if (is.null(extractant_data)) {
    extractant_data <- extract_extractant(data)
  }

  extractant_average <- extractant_data |>
    dplyr::mutate(abs = as.numeric(abs)) |>
    dplyr::summarise(
      .by = c(plate_id, map),
      extr_avg = mean(abs),
      extr_sdev = stats::sd(abs)) |>
    dplyr::mutate(extr_coeff_var_percent = 100 * extr_sdev / extr_avg)

  return(extractant_average)
}

utils::globalVariables(c("extr_coeff_var_percent"))




#' Plot dataset-wide distribution of withing-plate variation for extractant data
#'
#' Plots, the distribution for each plate of the coefficient of variation of raw
#'     absorbance of the extractant
#'
#' @param extractant_average Defaults to NULL, where it is computed from `data`
#'     using `extractant_average(data)`
#' @param data A tibble like `tidy_plates`, must be provided if `extractant_average` is NULL.
#'
#' @returns A plot of the distribution of the coefficient of variation of raw
#'     absorbance of the extractant
#'
#' @export
#'
#' @examples
#' # example code
#' tidy_plates |> extractant_average() |> plot_blank_var_distrib()
#'
plot_blank_var_distrib <- function(
    extractant_average = NULL, #either data or extractant_average must be provided
    data = NULL
    ) {

  if (is.null(extractant_average)) {
    extractant_average <- extractant_average(data)
  }

  plot_distrib <- extractant_average |>
    ggplot2::ggplot(aes(x = extr_coeff_var_percent)) +
    ggplot2::theme_minimal() +
    ggplot2::geom_histogram(bins = 100) +
    #geom_density() +
    #geom_boxplot() +
    ggplot2::labs(
      title = "Distribution of coefficient of variation of\nabsorbance of extractant (blank)") +
    ggplot2::xlab("intra-plate coefficient of variation [%]")

  return(plot_distrib)
}






