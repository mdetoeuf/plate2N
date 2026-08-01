#' Boxplot of values by sample, with optional colour and point labels
#'
#' Plots a boxplot of a numeric column, grouped by sample on the x-axis, with
#' individual points overlaid and labelled by name (labels placed via
#' `ggrepel` to avoid overlap). This is the companion function to
#' [plot_ridges_values()]: a ridgeline plot is often the easier way to
#' visually spot an outlier, but doesn't tell you which well to remove —
#' this boxplot does, since each point is labelled, so the labelled outlier
#' can be passed directly to [remove_wells()].
#'
#' @param data A tibble containing the columns referenced by `x_col`,
#'     `value_col`, `label_col`, and (if used as a column name) `colour`.
#' @param x_col Name of the column identifying samples, plotted on the x-axis
#'     (coerced to a factor). Defaults to `"sample_id"` — replace with
#'     whatever column identifies your own sample units.
#' @param value_col Name of the numeric column plotted on the y-axis.
#'     Defaults to `"conc_mgN_L"`, but this can equally be raw absorbance
#'     data (e.g. `"abs"` or `"abs_corrected"`) if you'd rather spot outliers
#'     before inferring concentration. For a linear model this gives
#'     identical results either way; for a polynomial model, averaging
#'     absorbance before vs. after concentration inference isn't exactly
#'     equivalent (though the difference is typically small).
#' @param colour If `NULL` (the default), all points are coloured
#'     `"purple"`. Otherwise, either a literal colour name (applied to every
#'     point) or the name of a column in `data`, in which case points are
#'     coloured according to that column's values.
#' @param label_col Name of the column used to label individual points.
#'     Defaults to `"well_id"`.
#'
#' @returns A ggplot object.
#' @seealso [plot_ridges_values()], [remove_wells()]
#' @export
#'
#' @examples
#' # boxplot_values(my_data, x_col = "plate_id", value_col = "co2_g_h")
boxplot_values <- function(
    data,
    x_col = "sample_id",
    value_col = "conc_mgN_L",
    colour = NULL,
    label_col = "well_id"
) {
  if (!requireNamespace("ggrepel", quietly = TRUE)) {
    stop("Package \"ggrepel\" is needed for this function. Please install it.", call. = FALSE)
  }

  colour_as_aesthetics <- FALSE

  if (is.null(colour)) {
    colour <- "purple"
  } else if (colour %in% names(data)) {
    colour <- data[[colour]]
    colour_as_aesthetics <- TRUE
  }

  plot <- data |>
    ggplot2::ggplot(ggplot2::aes(x = as.factor(.data[[x_col]]), y = .data[[value_col]])) +
    ggplot2::theme_minimal() +
    ggplot2::geom_boxplot(outliers = FALSE) +
    {if (colour_as_aesthetics) ggplot2::geom_point(alpha = 0.4, ggplot2::aes(colour = colour))} +
    {if (!colour_as_aesthetics) ggplot2::geom_point(alpha = 0.4, colour = colour)} +
    {if (colour_as_aesthetics) ggrepel::geom_text_repel(
      ggplot2::aes(label = .data[[label_col]], colour = colour),
      size = 2, alpha = 1, min.segment.length = 1)} +
    {if (!colour_as_aesthetics) ggrepel::geom_text_repel(
      ggplot2::aes(label = .data[[label_col]]), colour = colour,
      size = 2, alpha = 1, min.segment.length = 1)}

  return(plot)
}


#' Ridge-line density plot of values, grouped by sample
#'
#' Plots a ridgeline density plot of a numeric column, split into one ridge
#' per group. This is the companion function to [boxplot_values()]: a ridge
#' plot is often the easiest way to visually spot an outlier, but doesn't
#' identify which well to remove — pair it with [boxplot_values()], which
#' labels individual points by name, to find the well to pass to
#' [remove_wells()].
#'
#' @param data A tibble containing the columns referenced by `value_col`,
#'     `groups_col`, `y_col`, and (if used as a column name) `colour_col`.
#' @param value_col Name of the numeric column whose density is plotted.
#'     Defaults to `"conc_mgN_L"`, but this can equally be raw absorbance
#'     data if you'd rather spot outliers before inferring concentration
#'     (see [boxplot_values()] for the same note on linear vs. polynomial
#'     models).
#' @param groups_col Name of the column defining groups (one ridge per unique
#'     value). Defaults to `"sample_id"` — replace with whatever column
#'     identifies your own sample units.
#' @param colour_col If `NULL`, all ridges are drawn in a single, uniform
#'     colour. Otherwise, the name of a column in `data` used for colour/fill
#'     aesthetics (e.g. to distinguish ridges by run or batch). Defaults to
#'     `NULL`.
#' @param y_col Name of the column defining the vertical ridge position.
#'     Defaults to `"sample_id"`.
#'
#' @returns A ggplot object.
#' @seealso [boxplot_values()], [remove_wells()]
#' @export
#'
#' @examples
#' # plot_ridges_values(my_data, value_col = "co2_g_h", y_col = "plate_id")
plot_ridges_values <- function(
    data,
    value_col = "conc_mgN_L",
    groups_col = "sample_id",
    colour_col = NULL,
    y_col = "sample_id"
) {
  if (!requireNamespace("ggridges", quietly = TRUE)) {
    stop("Package \"ggridges\" is needed for this function. Please install it.", call. = FALSE)
  }

  base_aes <- ggplot2::aes(
    x = .data[[value_col]],
    groups = as.factor(.data[[groups_col]]))

  plot <- data |>
    ggplot2::ggplot(base_aes) +
    {if (!is.null(colour_col)) ggplot2::aes(color = .data[[colour_col]], fill = .data[[colour_col]])} +
    ggplot2::theme_minimal() +
    {if (!is.null(colour_col)) ggridges::geom_density_ridges(ggplot2::aes(y = .data[[y_col]]), alpha = 0.3)} +
    {if (is.null(colour_col)) ggridges::geom_density_ridges(ggplot2::aes(y = .data[[y_col]]), alpha = 0.3, fill = "steelblue", colour = "steelblue4")}

  return(plot)
}


#' Build per-substrate/treatment QC plots for MicroResp data, paginated into panels
#'
#' For each unique value of `map_col` (e.g. one substrate, treatment, or
#' other layer's category), builds a combined boxplot ([boxplot_values()]) +
#' ridgeline ([plot_ridges_values()]) QC plot, split into manageable panels —
#' either by an existing panel-defining column (`panel_col`, e.g. a run or
#' batch identifier), or, if none is
#' given, into automatically-sized chunks of at most `max_plates_per_panel`
#' plates. Panels are assembled side by side using the `patchwork` package.
#'
#' If `data` has more than one column representing a distinct layer (e.g.
#' separate substrate and treatment columns), call this function once per
#' column, passing the relevant column name as `map_col` each time.
#'
#' @param data A tibble containing the columns referenced by `map_col`,
#'     `plate_id_col`, `value_col`, `label_col`, and (if given) `panel_col`.
#'     Must also contain a `dataset` column (used only in plot titles).
#' @param map_col Name of the column identifying substrates/treatments/layers
#'     for this call — one QC plot is produced per unique value, and the
#'     returned list has one entry per value (see `Value`). Defaults to
#'     `"map"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param value_col Name of the numeric column to visualize. Defaults to
#'     `"co2_g_h"`, but can be set to any per-sample numeric value for reuse
#'     beyond MicroResp.
#' @param label_col Name of the column used to label individual points
#'     (passed through to [boxplot_values()]). Defaults to `"well_id"`.
#' @param panel_col Optional name of a column defining how plates are split
#'     into panels (e.g. an experimental run or batch identifier). If given,
#'     one panel is produced per unique value, labelled accordingly, and
#'     ridges are coloured by that value. If `NULL` (the default),
#'     plates are automatically split into evenly-sized panels labelled
#'     "Panel X of Y", each capped at `max_plates_per_panel` plates, with
#'     ridges in a single uniform colour (no meaningful grouping to colour
#'     by in this case).
#' @param max_plates_per_panel Maximum number of plates shown per panel when
#'     `panel_col` is `NULL`, used to determine how many panels are needed
#'     (`ceiling(n_plates / max_plates_per_panel)`) — plates are then spread
#'     as evenly as possible across that many panels, so the last panel is
#'     never left with a small, oddly emphasized remainder. Ignored if
#'     `panel_col` is given. Defaults to `10`.
#'
#' @returns A named list of combined plots, one per unique value of
#'     `map_col`. If `map_col` has several distinct values (e.g. several
#'     substrates), you'll get one list entry — one full page of plots —
#'     per value.
#' @seealso [boxplot_values()], [plot_ridges_values()]
#' @export
#'
#' @examples
#' # # plot_list_qc_microresp(MR_co2_g_h, panel_col = "run_id")
#' # plot_list_qc_microresp(MR_co2_g_h, max_plates_per_panel = 8)
plot_list_qc_microresp <- function(
    data,
    map_col = "map",
    plate_id_col = "plate_id",
    value_col = "co2_g_h",
    label_col = "well_id",
    panel_col = NULL,
    max_plates_per_panel = 10
) {
  substrates <- data |> dplyr::select(dplyr::all_of(map_col)) |> unique()
  dataset <- data$dataset |> unique()

  plot_list <- list()

  for (i in seq_len(nrow(substrates))) {

    subset <- data |>
      dplyr::filter(.data[[map_col]] == substrates[[map_col]][i])

    substrate_plots <- list()

    if (!is.null(panel_col)) {
      # one panel per unique value of panel_col
      panel_ids <- subset |> dplyr::select(dplyr::all_of(panel_col)) |> unique() |> dplyr::pull()

      for (j in seq_along(panel_ids)) {
        subset_panel <- subset |> dplyr::filter(.data[[panel_col]] == panel_ids[j])

        boxplot_panel <- subset_panel |>
          boxplot_values(x_col = plate_id_col, value_col = value_col, label_col = label_col) +
          ggplot2::facet_wrap(ggplot2::vars(.data[[panel_col]]), scales = "free_x", nrow = 2) +
          ggplot2::theme(legend.position = "none") +
          ggplot2::scale_x_discrete(limits = rev(c("", unique(subset_panel[[plate_id_col]])))) +
          ggplot2::xlab(plate_id_col) +
          ggplot2::coord_flip()

        ridges_panel <- subset_panel |>
          plot_ridges_values(
            value_col = value_col, y_col = plate_id_col,
            groups_col = panel_col, colour_col = panel_col) +
          ggplot2::scale_y_discrete(limits = rev) +
          ggplot2::facet_wrap(ggplot2::vars(.data[[panel_col]]), scales = "free_y", nrow = 2) +
          ggplot2::theme(legend.position = "none")

        panel_plot <- boxplot_panel + ridges_panel + patchwork::plot_layout(axis_titles = "collect")
        substrate_plots[[as.character(panel_ids[j])]] <- panel_plot
      }

    } else {
      # no panel_col: split plates evenly across ceiling(n/max_plates_per_panel) panels
      all_plates <- subset |> dplyr::select(dplyr::all_of(plate_id_col)) |> unique() |> dplyr::pull()
      #plate_chunks <- split(all_plates, ceiling(seq_along(all_plates) / max_plates_per_panel))
      n_panels <- ceiling(length(all_plates) / max_plates_per_panel)
      idx_groups <- parallel::splitIndices(length(all_plates), n_panels)
      plate_chunks <- lapply(idx_groups, function(idx) all_plates[idx])

      for (j in seq_along(plate_chunks)) {
        subset_panel <- subset |> dplyr::filter(.data[[plate_id_col]] %in% plate_chunks[[j]])

        boxplot_panel <- subset_panel |>
          boxplot_values(x_col = plate_id_col, value_col = value_col, label_col = label_col) +
          ggplot2::labs(subtitle = paste("Panel", j, "of", length(plate_chunks))) +
          ggplot2::theme(legend.position = "none") +
          ggplot2::scale_x_discrete(limits = rev(c("", unique(subset_panel[[plate_id_col]])))) +
          ggplot2::xlab(plate_id_col) +
          ggplot2::coord_flip()

        ridges_panel <- subset_panel |>
          plot_ridges_values(
            value_col = value_col, y_col = plate_id_col,
            groups_col = plate_id_col, colour_col = NULL) +
          ggplot2::scale_y_discrete(limits = rev) +
          ggplot2::theme(legend.position = "none")

        panel_plot <- boxplot_panel + ridges_panel + patchwork::plot_layout(axis_titles = "collect")
        substrate_plots[[paste0("panel_", j)]] <- panel_plot
      }
    }

    combined <- patchwork::wrap_plots(substrate_plots) +
      patchwork::plot_annotation(title = paste0(dataset, " - ", substrates[[map_col]][i]))

    plot_list[[substrates[[map_col]][i]]] <- combined
  }

  return(plot_list)
}
