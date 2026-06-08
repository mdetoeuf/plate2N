


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
    dplyr::filter(map %in% extr_def)

  return(extractant_data)
}


# NON USER-FACING FUNCTION
extr_avg <- function(
    data = NULL, #either data or extractant_data must be provided
    extractant_data = NULL,
    extr_def = "extr"
) {
  # computing extractant data from data if missing
  if (is.null(extractant_data)) {
    extractant_data <- extract_extractant(data, extr_def = extr_def)
  }

  extr_avg <- extractant_data |>
      dplyr::mutate(abs = as.numeric(abs)) |>
      dplyr::summarise(
        .by = c(dataset, plate_id, map),
        blank_avg = mean(abs),
        blank_sdev = stats::sd(abs)) |>
      dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)

    return(extr_avg)
}




utils::globalVariables(c("blank_sdev", "blank_avg", "plate_id", "map", "abs"))


#' Computing the per-plate average for raw absorbance of the extractant (blank for samples)
#'
#' @param data A tibble like `tidy_plates`
#' @param extractant_data Alternatively, A tibble containing only extractant data
#'    Defaults to NULL, where it would be computed from `data` using `extract_extractant(data)`
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map`column) of the plate. Defaults to "extr". Can be a vector
#'    containing several values (see examples)
#'
#' @returns A tibble with one row per plate, contianing the average, standard
#'    deviation and coefficient of variation of raw absorbance of the extractant
#' @export
#'
#' @examples
#' data = tidy_plates
#' (blank_avg <- extractant_average(data, extr_def = "extr"))
#'
#' # artificially construct a tibble with 2 extractants and an additional column for extractant id
#' tidy_2_extr <- tidy_plates |>
#'   dplyr::mutate(
#'     map = dplyr::case_when(
#'       column == 8 ~ "extr_1",
#'       column == 4 ~ "extr_2",
#'       .default = map))
#' multiple_extractant_id # check it out
#' # joining with multiple_extractant_id
#' (dbl_extr_plate <- tidy_2_extr |> dplyr::left_join(multiple_extractant_id))
#' data <- dbl_extr_plate
#' (blank_avg <- extractant_average(data, extr_def = c("extr_1", "extr_2")))
extractant_average <- function(
    data = NULL, #either data or extractant_data must be provided
    extractant_data = NULL,
    extr_def = "extr" # extr_def = c("extr_1", "extr_2")
) {

  #if (length(extr_def) == 1) {
    # computing extractant data from data if missing
    if (is.null(extractant_data)) {
      extractant_data <- extract_extractant(data, extr_def = extr_def)
    }

    # extractant_average <- extr_avg(
    #   data = data,
    #   extractant_data = extractant_data,
    #   extr_def = extr_def)

    # extractant_average <- extractant_data |>
    #   dplyr::mutate(abs = as.numeric(abs)) |>
    #   dplyr::summarise(
    #     .by = c(plate_id, map),
    #     blank_avg = mean(abs),
    #     blank_sdev = stats::sd(abs)) |>
    #   dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)
 # } else {
    nb_extractant <- length(extr_def)

    #initiate an empty tibble
    extractant_average <- tibble(
      dataset = character(),
      plate_id = character(),
      map = character(),
      blank_avg = double(),
      blank_sdev = double(),
      blank_coeff_var_percent = double()
    )

    for (i in 1:nb_extractant) {
      extr_data_i <- extractant_data |> dplyr::filter(map == extr_def[i])
      extr_avg_i <- extr_avg(
        extractant_data = extr_data_i,
        extr_def = extr_def[i])
      extractant_average <- extractant_average |> bind_rows(extr_avg_i)
    }
  return(extractant_average)
}

utils::globalVariables(c("blank_coeff_var_percent"))




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
    ggplot2::ggplot(aes(x = blank_coeff_var_percent)) +
    ggplot2::theme_minimal() +
    ggplot2::geom_histogram(bins = 100) +
    #geom_density() +
    #geom_boxplot() +
    ggplot2::labs(
      title = "Distribution of coefficient of variation of\nabsorbance of extractant (blank)") +
    ggplot2::xlab("intra-plate coefficient of variation [%]")

  return(plot_distrib)
}






