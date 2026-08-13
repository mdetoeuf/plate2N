


#' Extracting "extractant" data (blank for samples) from plate tidy table
#'
#' @param data A tibble like `tidy_plates`
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map`column) of the plate
#' @param map_col Name of the column containing well mapping/type
#'     information. Defaults to `"map"`.
#'
#' @returns A subset of `data`, containing only extractant data
#' @export
#'
#' @examples
#' data = tidy_plates
#' extract_extractant(data)
extract_extractant <- function(
    data,
    extr_def = "extr",
    map_col = "map"
    ) {

  extractant_data <- data |>
    dplyr::filter(.data[[map_col]] %in% extr_def)

  return(extractant_data)
}


# NON USER-FACING FUNCTION
extr_avg <- function(
    data = NULL, #either data or extractant_data must be provided
    extractant_data = NULL,
    extr_def = "extr",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    map_col = "map",
    value_col = "abs"
) {
  # computing extractant data from data if missing
  if (is.null(extractant_data)) {
    extractant_data <- extract_extractant(data, extr_def = extr_def, map_col = map_col)
  }

  # renamed the local variable from extr_avg to avoid shadowing this
  # function's own name (purely internal, not a public parameter)
  avg_result <- extractant_data |>
    dplyr::mutate(dplyr::across(dplyr::all_of(value_col), as.numeric)) |>
    dplyr::summarise(
      .by = dplyr::all_of(c(dataset_col, plate_id_col, map_col)),
      blank_avg = mean(.data[[value_col]]),
      blank_sdev = stats::sd(.data[[value_col]])) |>
    dplyr::mutate(blank_coeff_var_percent = 100 * blank_sdev / blank_avg)

  return(avg_result)

  }



#' Computing the per-plate average for raw absorbance of the extractant (blank for samples)
#'
#' @param data A tibble like `tidy_plates`
#' @param extractant_data Alternatively, A tibble containing only extractant data
#'    Defaults to NULL, where it would be computed from `data` using `extract_extractant(data)`
#' @param extr_def A string that characterizes wells containing the extractant
#'    in the mapping (`map`column) of the plate. Defaults to "extr". Can be a vector
#'    containing several values (see examples)
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param map_col Name of the column containing well mapping/type
#'     information. Defaults to `"map"`.
#' @param value_col Name of the numeric absorbance column. Defaults to
#'     `"abs"`.
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
#' (blank_avg <- extractant_average(dbl_extr_plate, extr_def = c("extr_1", "extr_2")))
extractant_average <- function(
    data = NULL, #either data or extractant_data must be provided
    extractant_data = NULL,
    extr_def = "extr", # extr_def = c("extr_1", "extr_2")
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    map_col = "map",
    value_col = "abs"
) {

    # computing extractant data from data if missing
    if (is.null(extractant_data)) {
      extractant_data <- extract_extractant(data, extr_def = extr_def, map_col = map_col)
    }

  nb_extractant <- length(extr_def)

  # accumulate one row-set per extractant; bind_rows(NULL, x) == x, so
  # starting from NULL avoids needing to pre-construct an empty tibble
  # with matching column names just to bind onto
  extractant_avg <- NULL
  for (i in seq_len(nb_extractant)) {
    extr_data_i <- extractant_data |> dplyr::filter(.data[[map_col]] == extr_def[i])
    extr_avg_i <- extr_avg(
      extractant_data = extr_data_i,
      extr_def = extr_def[i],
      dataset_col = dataset_col, plate_id_col = plate_id_col,
      map_col = map_col, value_col = value_col)
    extractant_avg <- dplyr::bind_rows(extractant_avg, extr_avg_i)
    }
  return(extractant_avg)
}




#' Plot dataset-wide distribution of withing-plate variation for extractant data
#'
#' Plots, the distribution for each plate of the coefficient of variation of raw
#'     absorbance of the extractant
#'
#' @param extractant_average Defaults to NULL, where it is computed from `data`
#'     using `extractant_average(data)`
#' @param data A tibble like `tidy_plates`, must be provided if `extractant_average` is NULL.
#' @param var_col Name of the column holding the coefficient of variation
#'     to plot. Defaults to `"blank_coeff_var_percent"`.
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
    data = NULL,
    var_col = "blank_coeff_var_percent"
    ) {

  if (is.null(extractant_average)) {
    extractant_average <- extractant_average(data)
  }

  plot_distrib <- extractant_average |>
    ggplot2::ggplot(ggplot2::aes(x = .data[[var_col]])) +
    ggplot2::theme_minimal() +
    ggplot2::geom_histogram(bins = 100) +
    ggplot2::labs(
      title = "Distribution of coefficient of variation of\nabsorbance of extractant (blank)") +
    ggplot2::xlab("intra-plate coefficient of variation [%]")

  return(plot_distrib)
}






