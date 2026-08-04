
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


#' Identify outlier-wells within plates containing suspicious extractant data
#'
#' @param suspicious_extractant A tibble as generated by `suspicious_extr()`,
#'     can be computed with `suspicious_extr()`
#' @param max_coeff User-defined threshold value, defaults at 5%. All plates for which
#'     the coefficient of variation for extractant raw absorbance is above this threshold
#'     will be considered "suspicious plates". ! Be consistent with previous steps
#' @param max_plates_per_panel Maximum number of plates shown per panel,
#'     used to determine how many panels are needed. Plates are spread as
#'     evenly as possible across that many panels. Defaults to `10`.
#' @param max_nb_panels Maximum number of panels combined into a single
#'     figure. If more panels than this are needed, they are grouped evenly
#'     into multiple pages instead, and a named list of plots is returned
#'     (one per page) rather than a single plot. Defaults to `4`.
#' @param nrow,ncol How panels are arranged within a page, passed through to
#'     `patchwork::wrap_plots()`. If only one is given, the other is
#'     computed automatically (same behavior as `ggplot2::facet_wrap()`).
#'     If neither is given, defaults to a single row (`nrow = 1`), with
#'     `ncol` computed automatically from the number of panels.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param dataset_col Name of the column identifying the dataset. Defaults
#'     to `"dataset"`.
#' @param value_col Name of the numeric column plotted (raw absorbance).
#'     Defaults to `"abs"`.
#' @param label_col Name of the column used to label individual points.
#'     Defaults to `"well_id"`.
#' @param map_col Name of the column identifying extractants/layers, used
#'     for faceting. Defaults to `"map"`.
#' @param suppress_warning Whether to suppress the warning issued when the
#'     output is split into multiple pages (see `max_nb_panels`). Defaults
#'     to `FALSE`.
#'
#' @import ggplot2
#' @importFrom forcats fct_rev
#' @importFrom ggrepel geom_text_repel
#'
#' @returns A boxplot generated by ggplot, highlighting information necessary to
#'     create a tibble of wells to be removed with `remove_wells()`, i.e.,
#'     for each boxplot: plate_ids, well_ids and plate number (corresponding to
#'     the order of plate ids in `suspicious_extractant`). If the number of
#'     panels needed exceeds `max_nb_panels`, a named list of plots (one per
#'     page, e.g. `page_1`, `page_2`, ...) is returned instead of a single
#'     plot — see `max_nb_panels`.
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
    suspicious_extractant,
    max_coeff = 5,
    max_plates_per_panel = 10,
    max_nb_panels = 4,
    nrow = NULL,
    ncol = NULL,
    plate_id_col = "plate_id",
    dataset_col = "dataset",
    value_col = "abs",
    label_col = "well_id",
    map_col = "map",
    suppress_warning = FALSE
) {
  nb_plates <- suspicious_extractant |>
    dplyr::ungroup() |>
    dplyr::select(dplyr::all_of(c(dataset_col, plate_id_col))) |>
    unique() |>
    nrow()

  plate_numbers <- suspicious_extractant |>
    dplyr::select(dplyr::all_of(plate_id_col)) |>
    unique() |>
    dplyr::mutate(plate_nb = seq_len(nb_plates))

  suspicious_extractant <- suspicious_extractant |>
    dplyr::left_join(plate_numbers, by = plate_id_col)

  # split plates evenly across ceiling(n/max_plates_per_panel) panels
  all_plates <- suspicious_extractant |>
    dplyr::select(dplyr::all_of(plate_id_col)) |>
    unique() |>
    dplyr::pull(.data[[plate_id_col]])
  n_panels <- ceiling(length(all_plates) / max_plates_per_panel)
  idx_groups <- parallel::splitIndices(length(all_plates), n_panels)
  plate_chunks <- lapply(idx_groups, function(idx) all_plates[idx])

  # fix the absorbance-axis range across all panels, so plates are compared
  # fairly regardless of which panel they land in
  abs_range <- range(suspicious_extractant[[value_col]], na.rm = TRUE)

  panel_plots <- list()

  for (j in seq_along(plate_chunks)) {
    subset_panel <- suspicious_extractant |>
      dplyr::filter(.data[[plate_id_col]] %in% plate_chunks[[j]])
    text_data <- subset_panel |>
      dplyr::select(dplyr::all_of(c(plate_id_col, "plate_nb"))) |>
      unique()

    panel_plots[[j]] <- subset_panel |>
      ggplot2::ggplot(ggplot2::aes(x = .data[[value_col]], y = forcats::fct_rev(.data[[plate_id_col]]))) +
      ggplot2::theme_minimal() +
      ggplot2::geom_boxplot(
        fill = "grey90", color = "grey70",
        outliers = FALSE) +
      ggplot2::geom_jitter(colour = "grey30", alpha = 0.7, shape = 1, height = 0.1) +
      ggrepel::geom_text_repel(ggplot2::aes(label = .data[[label_col]]), colour = "purple", alpha = 1, min.segment.length = 1) +
      ggplot2::geom_text(
        data = text_data,
        ggplot2::aes(x = 0, y = .data[[plate_id_col]], label = paste0("plate", .data[["plate_nb"]]), hjust = 0, vjust = -2),
        colour = "grey20") +
      ggplot2::coord_cartesian(xlim = abs_range) +
      ggplot2::ylab("Plate id") + ggplot2::xlab("raw absorbance of extractant wells") +
      {if (length(plate_chunks) > 1) ggplot2::labs(subtitle = paste("Panel", j, "of", length(plate_chunks)))} +
      ggplot2::facet_wrap(ggplot2::vars(.data[[map_col]]))
  }

  # default to a single row only if the user specified neither dimension;
  # if only one was given, leave the other NULL so patchwork can compute it
  if (is.null(nrow) && is.null(ncol)) {
    nrow <- 1
    }

  # group panels into pages of at most max_nb_panels panels each,
  # spread evenly for the same reason plates were spread evenly above
  n_pages <- ceiling(length(panel_plots) / max_nb_panels)
  page_idx_groups <- parallel::splitIndices(length(panel_plots), n_pages)

  pages <- lapply(page_idx_groups, function(idx) {
    patchwork::wrap_plots(panel_plots[idx], nrow = nrow, ncol = ncol) +
      patchwork::plot_annotation(
        title = "Identifying outliers for extractant wells",
        subtitle = paste0("Only plates with outliers are displayed here\n(coefficient of variation of absorbance > ", max_coeff, "%)"))
  })

  if (n_pages == 1) {
    return(pages[[1]])
  } else {
    if (!suppress_warning) {
      warning(
        "Output split into ", n_pages, " pages (", length(panel_plots),
        " panels total, max_nb_panels = ", max_nb_panels, "). ",
        "Returning a list of ", n_pages, " plots instead of a single plot. ",
        "Set suppress_warning = TRUE to silence this message.")
    }
    names(pages) <- paste0("page_", seq_along(pages))
    return(pages)
  }
}
