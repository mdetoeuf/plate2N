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
#'     `value_col`, `label_col`, and (if used as a column name) `colour_col`.
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
#' @param colour_col If `NULL` (the default), all points are coloured
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
    colour_col = NULL,
    label_col = "well_id"
) {
  if (!requireNamespace("ggrepel", quietly = TRUE)) {
    stop("Package \"ggrepel\" is needed for this function. Please install it.", call. = FALSE)
  }
   # decide whether colour_col names an actual data column (map it as an
   # aesthetic) or is a literal colour/NULL (use it as a single fixed colour)
  colour_as_aesthetics <- FALSE

  if (is.null(colour_col)) {
     colour_col <- "purple"
   } else if (colour_col %in% names(data)) {
     colour_col <- data[[colour_col]]
     colour_as_aesthetics <- TRUE
  }

  plot <- data |>
    # x-axis: one category per sample; y-axis: the value of interest
    ggplot2::ggplot(ggplot2::aes(x = as.factor(.data[[x_col]]), y = .data[[value_col]])) +
    ggplot2::theme_minimal() +
    ggplot2::xlab(x_col) +
    # per-sample summary; individual wells (below) already show every
    # point labelled, so boxplot's own outlier markers would be redundant
    ggplot2::geom_boxplot(outliers = FALSE) +
    # one point per well, coloured either by the chosen column or by a
    # single fixed colour, depending on colour_as_aesthetics
    {if (colour_as_aesthetics) ggplot2::geom_point(alpha = 0.4, ggplot2::aes(colour = colour_col))} +
    {if (!colour_as_aesthetics) ggplot2::geom_point(alpha = 0.4, colour = colour_col)} +
    # well-id labels, repelled apart to stay legible - this is what lets
    # you read the exact well to remove straight off the plot
    {if (colour_as_aesthetics) ggrepel::geom_text_repel(
      ggplot2::aes(label = .data[[label_col]], colour = colour_col),
      size = 2, alpha = 1, min.segment.length = 1)} +
    {if (!colour_as_aesthetics) ggrepel::geom_text_repel(
      ggplot2::aes(label = .data[[label_col]]), colour = colour_col,
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
#'     colour. Otherwise, either a literal colour name (applied to every
#'     ridge) or the name of a column in `data` used for colour/fill
#'     aesthetics (e.g. to distinguish ridges by run or batch). Defaults to
#'     `NULL`.
#' @param y_col Name of the column defining the vertical ridge position.
#'     Defaults to `"sample_id"`.
#' @param scale How far each ridge is allowed to visually extend beyond its
#'     own row (passed to `ggridges::geom_density_ridges()`). Values above 1
#'     let curves overlap into neighboring rows (the classic ridgeline
#'     look); values at or below 1 keep each curve within its own row,
#'     useful when ridges need to align precisely with the rows of a paired
#'     plot (see [boxplot_values()]). Defaults to `1`.
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
    y_col = "sample_id",
    scale = 1
) {
  if (!requireNamespace("ggridges", quietly = TRUE)) {
    stop("Package \"ggridges\" is needed for this function. Please install it.", call. = FALSE)
  }

  # decide whether colour_col names an actual data column (map it as an
  # aesthetic) or is a literal colour/NULL (use a fixed default fill/outline)
  colour_as_aesthetics <- FALSE

  if (is.null(colour_col)) {
    fill_val <- "steelblue"
    outline_val <- "steelblue4"
  } else if (colour_col %in% names(data)) {
    colour_as_aesthetics <- TRUE
  } else {
    fill_val <- colour_col
    outline_val <- colour_col
  }

  # x-axis: the value of interest; groups: one density curve per unique
  # value of groups_col
  base_aes <- ggplot2::aes(
    x = .data[[value_col]],
    groups = as.factor(.data[[groups_col]]))

  plot <- data |>
    ggplot2::ggplot(base_aes) +
    # map colour/fill to the chosen column only when it's a real column name;
    # otherwise a fixed fill/outline is used in the geom call below
    {if (colour_as_aesthetics) ggplot2::aes(color = .data[[colour_col]], fill = .data[[colour_col]])} +
    ggplot2::theme_minimal() +
    {if (colour_as_aesthetics) ggridges::geom_density_ridges(ggplot2::aes(y = .data[[y_col]]), alpha = 0.3, scale = scale)} +
    {if (!colour_as_aesthetics) ggridges::geom_density_ridges(ggplot2::aes(y = .data[[y_col]]), alpha = 0.3, fill = fill_val, colour = outline_val, scale = scale)}

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

    # fix the value axis range once per substrate, so every panel for this
    # substrate is comparable on the same scale (not independently rescaled)
    value_range <- range(subset[[value_col]], na.rm = TRUE)

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
          ggplot2::coord_flip(ylim = value_range)

        ridges_panel <- subset_panel |>
          plot_ridges_values(
            value_col = value_col, y_col = plate_id_col,
            groups_col = panel_col, colour_col = panel_col) +
          ggplot2::scale_y_discrete(limits = rev) +
          ggplot2::facet_wrap(ggplot2::vars(.data[[panel_col]]), scales = "free_y", nrow = 2) +
          ggplot2::coord_cartesian(xlim = value_range) +
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
          ggplot2::coord_flip(ylim = value_range)

        ridges_panel <- subset_panel |>
          plot_ridges_values(
            value_col = value_col, y_col = plate_id_col,
            groups_col = plate_id_col, colour_col = NULL) +
          ggplot2::scale_y_discrete(limits = rev) +
          ggplot2::coord_cartesian(xlim = value_range) +
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


#' Interleave plots with spacer panels for visual gaps in patchwork layouts
#'
#' A small utility for adding a visible gap between plots combined with
#' `patchwork`. Simply increasing `plot.margin` does not create a gap
#' between adjacent panels that each have their own background (e.g. a
#' border drawn via `plot.background`), since the background fills the
#' whole panel's allocated space regardless of margin. This function
#' instead inserts `patchwork::plot_spacer()` panels between the real
#' plots, sized via `patchwork::plot_layout(widths =)`/`heights =`.
#'
#' @param plots A list of plot/patchwork objects to interleave with spacers.
#' @param gap_size Relative size of each spacer panel, compared to a real
#'     plot's size of `1`. Defaults to `0.002` (a thin visual gap).
#'
#' @returns A list with two elements: `plots` (the interleaved list,
#'     spacers included) and `sizes` (the matching relative-size vector),
#'     ready to pass to `patchwork::wrap_plots(result$plots)` and
#'     `patchwork::plot_layout(widths = result$sizes)` (or `heights =` for
#'     a vertical arrangement).
#' @export
#'
#' @examples
#' # spaced <- add_spacers(list(plot1, plot2, plot3))
#' # patchwork::wrap_plots(spaced$plots, nrow = 1) +
#' #   patchwork::plot_layout(widths = spaced$sizes)
add_spacers <- function(plots, gap_size = 0.002) {
  interleaved <- list()
  for (i in seq_along(plots)) {
    interleaved[[length(interleaved) + 1]] <- plots[[i]]
    # a spacer after every real plot except the last one
    if (i < length(plots)) {
      interleaved[[length(interleaved) + 1]] <- patchwork::plot_spacer()
    }
  }
  list(
    plots = interleaved,
    # real plots get relative size 1, spacers get gap_size
    sizes = rep(c(1, gap_size), length.out = length(interleaved))
  )
}


#' Boxplot + ridgeline pair for one chunk of samples
#'
#' Builds one combined QC figure for a chunk of samples: a labelled
#' boxplot ([boxplot_values()]) next to a ridgeline density plot
#' ([plot_ridges_values()]), sharing one centered axis of sample
#' identities between them. The ridge makes it easy to spot an outlier at
#' a glance; the paired boxplot then gives you the exact well_id to
#' remove via [remove_wells()]. The whole pair is enclosed in a border
#' box. Typically built once per chunk of samples by
#' [plot_list_qc_samples()] rather than called directly.
#'
#' @param chunk A vector of values of `y_col` to include in this pair (one
#'     "page" worth of samples).
#' @param data A tibble containing the columns referenced by `y_col`,
#'     `value_col`, and (if given) `colour_col`.
#' @param y_col Name of the column identifying samples — shared between
#'     the boxplot and the ridge plot as the row/category axis.
#' @param value_col Name of the numeric column to visualize.
#' @param value_range A length-2 numeric vector giving the shared
#'     value-axis range to use, so samples can be compared fairly
#'     regardless of which chunk they land in. Typically computed once
#'     (across the whole dataset) by [plot_list_qc_samples()] and passed
#'     down.
#' @param colour_col Optional colour: `NULL` for a default colour, a
#'     literal colour name, or the name of a column in `data` — passed
#'     through to both [boxplot_values()] and [plot_ridges_values()].
#' @param scale Passed to [plot_ridges_values()] — how far each ridge
#'     extends beyond its own row. Defaults to `0.8`, which keeps ridges
#'     close enough to their row to stay visually aligned with the paired
#'     boxplot.
#' @param title Optional title for this pair, shown centered above the
#'     shared axis. Defaults to `y_col`'s name if not given.
#' @param border_colour Colour of the border box drawn around the pair.
#'     Defaults to `"grey80"`.
#' @param legend_position Standard `ggplot2` `legend.position` value (e.g.
#'     `"none"`, `"right"`, `"bottom"`, `"left"`, `"top"`), applied to both
#'     the boxplot and the ridge, with duplicate legends automatically
#'     collected into one shared legend for the pair. Defaults to
#'     `"none"` (no legend shown).
#'
#' @returns A single combined plot (a flattened `patchwork` object).
#' @seealso [plot_list_qc_samples()], [boxplot_values()], [plot_ridges_values()]
#' @export
#'
#' @examples
#' # plot_qc_sample_pair(
#' #   chunk = c("s1", "s2"), data = my_data,
#' #   y_col = "sample_id", value_col = "conc_mgN_L",
#' #   value_range = c(0, 10))
plot_qc_sample_pair <- function(
    chunk,
    data,
    y_col,
    value_col,
    value_range,
    colour_col = NULL,
    scale = 0.8,
    title = NULL,
    border_colour = "grey80",
    legend_position = "none"
) {
  # keep only the samples assigned to this chunk/page
  subset_chunk <- data |> dplyr::filter(.data[[y_col]] %in% chunk)

  # boxplot: labelled points give the exact well_id of any outlier. y-axis
  # text hidden here since the ridge plot's axis (below) already shows
  # sample identities - it ends up sitting between the two plots once combined
  box <- subset_chunk |>
    boxplot_values(x_col = y_col, value_col = value_col, colour_col = colour_col) +
    ggplot2::coord_flip(ylim = value_range) +
    ggplot2::xlab(NULL) +
    ggplot2::scale_x_discrete(limits = rev, expand = ggplot2::expansion(add = 0.6)) +
    ggplot2::theme(
      legend.position = legend_position,
      axis.text.y = ggplot2::element_blank())

  # ridgeline: quickest way to visually spot an outlier sample. Axis text
  # centered so it reads naturally as belonging to both plots at once
  ridge <- subset_chunk |>
    plot_ridges_values(
      value_col = value_col, y_col = y_col,
      groups_col = y_col, colour_col = colour_col, scale = scale) +
    ggplot2::ylab(NULL) +
    ggplot2::coord_cartesian(xlim = value_range) +
    ggplot2::scale_y_discrete(limits = rev, expand = ggplot2::expansion(add = 0.6)) +
    ggplot2::theme(
      legend.position = legend_position,
      axis.text.y = ggplot2::element_text(hjust = 0.5))

  # title defaults to y_col's name if not supplied; added here (before
  # wrap_elements() below) so it survives being nested into a larger
  # combined figure later - patchwork drops titles on further-nested
  # objects unless the composition is flattened with wrap_elements() first
  pair_title <- if (is.null(title)) y_col else title

  pair <- patchwork::wrap_plots(box, ridge, ncol = 2, axis_titles = "collect", guides = "collect") +
    patchwork::plot_annotation(
      title = pair_title,
      theme = ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)))

  # flatten the pair into a single element (preserving its title) and draw
  # a border box around it, so the pair reads as one visual unit once
  # combined with others
  plot <- patchwork::wrap_elements(pair) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(
        color = border_colour,
        fill = "transparent",
        linewidth = 1.5
      ),
      plot.margin = ggplot2::margin(5, 5, 5, 5),
    )

  return(plot)
}


#' Build per-sample QC plots (boxplot + ridgeline pairs), paginated
#'
#' Splits `data` into evenly-sized chunks of samples and builds a
#' [plot_qc_sample_pair()] figure for each chunk, combining them side by
#' side (with a small visual gap between chunks) into one figure. This is
#' the per-sample analog of [plot_list_qc_microresp()], generalized
#' beyond MicroResp: use it for any per-sample outlier-QC step (e.g.
#' abs-to-conc's downstream per-sample averaging).
#'
#' @param data A tibble containing the columns referenced by `y_col`,
#'     `value_col`, and (if given) `colour_col`.
#' @param y_col Name of the column identifying samples.
#' @param value_col Name of the numeric column to visualize. Defaults to
#'     `"conc_mgN_L"`, but can be set to any per-sample numeric value
#'     (e.g. raw or blank-corrected absorbance) for reuse beyond this
#'     default.
#' @param colour_col Optional colour: `NULL` for a default colour, a
#'     literal colour name, or the name of a column in `data` — passed
#'     through to every pair.
#' @param n_chunks Number of chunks (pages/panels) to split samples into.
#'     If `NULL` (the default), computed from `max_samples_per_chunk`
#'     instead.
#' @param max_samples_per_chunk Maximum number of samples per chunk, used
#'     to compute `n_chunks` when it isn't given directly. Ignored if
#'     `n_chunks` is given. Defaults to `25`.
#' @param value_range A length-2 numeric vector giving the shared
#'     value-axis range across all chunks, so samples are compared fairly
#'     regardless of which chunk they land in. If `NULL` (the default),
#'     computed from `data[[value_col]]`'s own range — pass this
#'     explicitly instead (e.g. computed from an unfiltered dataset) when
#'     comparing two versions of the same data side by side (such as
#'     before/after outlier removal), so both use the same scale.
#' @param scale Passed to [plot_ridges_values()] via each pair. Defaults
#'     to `0.8`.
#' @param gap_size Relative width of the visual gap between chunks,
#'     passed to [add_spacers()]. Defaults to `0.002`.
#' @param legend_position Standard `ggplot2` `legend.position` value (e.g.
#'     `"none"`, `"right"`, `"bottom"`, `"left"`, `"top"`), applied to both
#'     the boxplot and the ridge, with duplicate legends automatically
#'     collected into one shared legend for the pair. Defaults to
#'     `"none"` (no legend shown).
#' @param title Optional title, passed to every pair (identical across
#'     chunks). Defaults to `y_col`'s name if not given.
#'
#' @returns A single combined `patchwork` figure (one row, one pair-panel
#'     per chunk, evenly spaced) — ready to have an overall title added
#'     via `+ patchwork::plot_annotation(title = "...")`.
#' @seealso [plot_qc_sample_pair()], [plot_list_qc_microresp()]
#' @export
#'
#' @examples
#' # qc_plot <- plot_list_qc_samples(my_data, y_col = "sample_id", colour_col = "zone") +
#' #   patchwork::plot_annotation(title = "NO3")
plot_list_qc_samples <- function(
    data,
    y_col,
    value_col = "conc_mgN_L",
    colour_col = NULL,
    n_chunks = NULL,
    max_samples_per_chunk = 25,
    value_range = NULL,
    scale = 0.8,
    gap_size = 0.002,
    legend_position = "none",
    title = NULL
) {
  # catch a common mistake early: y_col/value_col arguments swapped
  stopifnot(
    "value_col must be a numeric column" = is.numeric(data[[value_col]]))

  # sort samples alphabetically - if the label is composed with the
  # higher-level grouping first (e.g. "plate_id (sample_id)"), plain
  # alphabetical order is already grouped the way a reader would expect,
  # and stays stable regardless of row order or which rows survive
  # outlier removal between two versions of the same data
  samples <- data |> dplyr::pull(.data[[y_col]]) |> unique() |> sort()

  # decide how many chunks: either given directly, or computed from a
  # maximum samples-per-chunk cap
  if (is.null(n_chunks)) {
    n_chunks <- ceiling(length(samples) / max_samples_per_chunk)
  }
  # split samples as evenly as possible across that many chunks
  idx_groups <- parallel::splitIndices(length(samples), n_chunks)
  sample_chunks <- lapply(idx_groups, function(idx) samples[idx])

  # fix the value-axis range once, so every chunk (and, if the caller
  # supplies the same range explicitly across separate calls, every
  # separately-built figure) is comparable on the same scale
  if (is.null(value_range)) {
    value_range <- range(data[[value_col]], na.rm = TRUE)
  }

  # build one boxplot+ridge pair per chunk
  chunk_plots <- lapply(
    sample_chunks, plot_qc_sample_pair,
    data = data, y_col = y_col, value_col = value_col,
    value_range = value_range, colour_col = colour_col,
    scale = scale, title = title, legend_position = legend_position)

  # combine all chunks into one row, with a small visual gap between them
  spaced <- add_spacers(chunk_plots, gap_size = gap_size)
  patchwork::wrap_plots(spaced$plots, nrow = 1) +
    patchwork::plot_layout(widths = spaced$sizes)
}
