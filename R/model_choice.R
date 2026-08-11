#' Fit one model (linear or polynomial) for a single standard curve
#'
#' The shared, single-model fitting logic behind [fit_curve_models()]
#' (which fits both at once, for comparison purposes) — call this
#' directly if you only need one model type.
#'
#' @param curve_data A tibble containing data for a single standard
#'     curve, with the columns referenced by `conc_col` and `value_col`.
#' @param model Which model to fit: `"linear"` or `"poly"`.
#' @param conc_col Name of the column containing concentration.
#'     Defaults to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param through_origin Whether to force the model through the origin.
#'     Defaults to `TRUE`.
#'
#' @returns An `lm` model object.
#' @seealso [fit_curve_models()]
#' @export
#'
#' @examples
#' curve <- std_corrected_TDN |>
#'   dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
#' fit_curve_model(curve, model = "poly")
fit_curve_model <- function(
    curve_data,
    model = c("linear", "poly"),
    conc_col = "std_conc",
    value_col = "abs_corrected",
    through_origin = TRUE
) {
  model <- match.arg(model)

  terms <- if (model == "linear") conc_col else paste0(conc_col, " + I(", conc_col, "^2)")
  if (through_origin) terms <- paste0("0 + ", terms)

  stats::lm(stats::reformulate(terms, response = value_col), data = curve_data)
}



#' Fit both linear and polynomial models for one standard curve
#'
#' Fits two models relating absorbance to concentration for a single
#' standard curve, both forced through the origin (blank-corrected
#' absorbance should read zero at zero concentration): a linear model
#' (`value ~ 0 + conc`) and a polynomial model
#' (`value ~ 0 + conc + I(conc^2)`). Used to help decide which model fits
#' better for a given dataset — see [plot_model_comparison()] and
#' [plot_residual_comparison()] to visualize the two fits, or
#' [review_model_choice()] to do this across several curves at once.
#'
#' @param curve_data A tibble containing data for a single standard
#'     curve (e.g. one `unique_curve_id`), with the columns referenced
#'     by `conc_col` and `value_col`.
#' @param conc_col Name of the column containing concentration.
#'     Defaults to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param through_origin Whether to force both models through the origin
#'     (`0 +` in the model formula). Defaults to `TRUE`, appropriate
#'     when blank-corrected absorbance should read zero at zero
#'     concentration. Set to `FALSE` if that assumption doesn't hold for
#'     your data (e.g. if the standard curve and samples share the same
#'     blank, matching `plot_std()`'s own `through_origin` argument).
#'
#' @returns A named list with two elements, `linear` and `poly`, each an
#'     `lm` model object.
#' @seealso [plot_model_comparison()], [plot_residual_comparison()], [review_model_choice()]
#' @export
#'
#' @examples
#' curve <- std_corrected_TDN |>
#'   dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
#' models <- fit_curve_models(curve)
#' summary(models$linear)
#' summary(models$poly)
fit_curve_models <- function(
    curve_data,
    conc_col = "std_conc",
    value_col = "abs_corrected",
    through_origin = TRUE
) {
  list(
    linear = fit_curve_model(curve_data, "linear", conc_col, value_col, through_origin),
    poly = fit_curve_model(curve_data, "poly", conc_col, value_col, through_origin)
    )
}


#' Plot linear and polynomial model fits side by side for one or more curves
#'
#' Wraps `plot_std()`, called once with `model = "linear"` and once with
#' `model = "poly"`, combined side by side. `plot_std()` fits its own
#' model internally purely for drawing — this function doesn't use
#' [fit_curve_models()]'s output, since that's a separate (if
#' equivalent) fit done for a different purpose (inspecting the actual
#' model object, e.g. for [plot_residual_comparison()]).
#'
#' @param curve_data A tibble with data for one curve, or several curves
#'     at once (grouped/coloured by `curve_id_col`) if you want an
#'     overplotted comparison across multiple curves.
#' @param conc_col Name of the column containing concentration. Defaults
#'     to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param curve_id_col Name of the column identifying which curve a row
#'     belongs to, used for grouping/colouring. Defaults to
#'     `"unique_curve_id"`.
#' @param colour_col Name of the column used for colour/fill. If `NULL`
#'     (the default), uses `curve_id_col`. Set independently to colour
#'     by something more meaningful when comparing several curves at
#'     once (e.g. date, dilution factor).
#' @param through_origin Whether to force both fits through the origin.
#'     Defaults to `TRUE`. See [fit_curve_models()] for the same
#'     argument's meaning.
#' @param unit_col Passed through to `plot_std()` — optionally shows a
#'     concentration unit on the x-axis. `NULL` (the default) shows no
#'     unit. See `plot_std()`'s own `unit_col` argument for the full
#'     behavior (literal string or column name).
#' @param smooth_alpha,smooth_linewidth,smooth_linetype Passed through
#'     to `plot_std()` — control the fitted smooth-curve's visibility.
#'     Defaults match `plot_std()`'s own defaults.
#' @param legend_position Standard `ggplot2` `legend.position` value for
#'     the colour legend. Defaults to `"none"`. Only meaningful when
#'     `colour_col` (or the default curve-id grouping) produces a
#'     legend worth showing — e.g. when comparing multiple curves at
#'     once via [review_model_choice()]'s `overplot = TRUE` mode.
#'
#' @returns A combined `patchwork` figure (linear model plot next to
#'     polynomial model plot).
#' @seealso [fit_curve_models()], [plot_residual_comparison()], [plot_std()]
#' @export
#'
#' @examples
#' curve <- std_corrected_TDN |>
#'   dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
#' plot_model_comparison(curve, unit_col = "std_unit")
plot_model_comparison <- function(
    curve_data,
    conc_col = "std_conc",
    value_col = "abs_corrected",
    curve_id_col = "unique_curve_id",
    colour_col = NULL,
    through_origin = TRUE,
    unit_col = NULL,
    smooth_alpha = 0.3,
    smooth_linewidth = 0.5,
    smooth_linetype = 2,
    legend_position = "right"
) {
  # when no colour_col is given, default each panel to a fixed colour
  # matching the residual plot's own scheme (grey30 = linear, magenta =
  # poly) - done via a synthetic constant column + a manual scale
  # override, reusing plot_std()'s existing colour_col mechanism as-is
  use_default_colours <- is.null(colour_col)
  effective_colour_col <- colour_col

  linear_data <- curve_data
  poly_data <- curve_data
  if (use_default_colours) {
    linear_data <- linear_data |> dplyr::mutate(.model_colour = "grey30")
    poly_data <- poly_data |> dplyr::mutate(.model_colour = "magenta")
    effective_colour_col <- ".model_colour"
  }

  p_linear <- linear_data |>
    plot_std(
      through_origin = through_origin, model = "linear",
      conc_col = conc_col, value_col = value_col, group_col = curve_id_col,
      colour_col = effective_colour_col, unit_col = unit_col,
      smooth_alpha = smooth_alpha, smooth_linewidth = smooth_linewidth,
      smooth_linetype = smooth_linetype) +
    {if (use_default_colours) ggplot2::scale_colour_manual(values = c("grey30" = "grey30"), guide = "none")} +
    {if (use_default_colours) ggplot2::scale_fill_manual(values = c("grey30" = "grey30"), guide = "none")} +
    ggplot2::labs(title = "Linear model") +
    ggplot2::theme(plot.title = ggplot2::element_text(colour = "grey30"))

  p_poly <- poly_data |>
    plot_std(
      through_origin = through_origin, model = "poly",
      conc_col = conc_col, value_col = value_col, group_col = curve_id_col,
      colour_col = effective_colour_col, unit_col = unit_col,
      smooth_alpha = smooth_alpha, smooth_linewidth = smooth_linewidth,
      smooth_linetype = smooth_linetype) +
    {if (use_default_colours) ggplot2::scale_colour_manual(values = c("magenta" = "magenta"), guide = "none")} +
    {if (use_default_colours) ggplot2::scale_fill_manual(values = c("magenta" = "magenta"), guide = "none")} +
    ggplot2::labs(title = "Polynomial model") +
    ggplot2::theme(plot.title = ggplot2::element_text(colour = "magenta"))

  combined <- patchwork::wrap_plots(p_linear, p_poly, axis_titles = "collect", guides = "collect")
  combined & ggplot2::theme(legend.position = legend_position)
}
# internal helper, not exported - builds the actual residual plot from an
# already-prepared long-format table (columns: curve_id, conc, residual,
# model). Used by both plot_residual_comparison() and
# review_model_choice()'s overplot mode, so the plotting logic itself
# only exists in one place. Does not add a connecting line between
# points - add ggplot2::geom_line() as an extra layer if useful (e.g.
# to trace one curve's residual pattern when several are shown at once)
plot_residuals_from_long <- function(residuals_long) {
  residuals_long |>
    ggplot2::ggplot(ggplot2::aes(
      x = .data[["conc"]], y = .data[["residual"]], colour = .data[["model"]],
      group = interaction(.data[["curve_id"]], .data[["model"]]))) +
    ggplot2::theme_minimal() +
    ggplot2::geom_hline(yintercept = 0, colour = "red", linetype = 2) +
    ggplot2::geom_point(ggplot2::aes(shape = .data[["model"]]), size = 2) +
    ggplot2::scale_colour_manual(
      values = c(linear = "grey30", poly = "magenta"),
      labels = c(linear = "linear model", poly = "polynomial model")) +
    ggplot2::scale_shape_manual(
      values = c(linear = 16, poly = 15),
      labels = c(linear = "linear model", poly = "polynomial model")) +
    ggplot2::xlab("Concentration") + ggplot2::ylab("Residuals") +
    ggplot2::labs(title = "Residuals Analysis", colour = NULL, shape = NULL)
}


#' Plot residuals of linear vs. polynomial models for one curve
#'
#' Compares how each model's residuals scatter around zero across the
#' range of concentrations, for one standard curve. Residuals close to
#' zero with no systematic pattern indicate a good fit; a curved or
#' systematic pattern (typically in the linear model's residuals, when a
#' polynomial fit is actually needed) is a sign that model doesn't
#' capture the true shape of the curve.
#'
#' @param curve_data A tibble with data for the curve, with the column
#'     referenced by `conc_col`. Must be the same data used to fit
#'     `models` (same row order/count) — e.g. via [fit_curve_models()].
#'     Note: if `curve_data` contains rows with `NA` in the fitted
#'     value/concentration columns, `lm()` silently drops them, which
#'     can misalign residuals against `curve_data`'s concentration
#'     values here. Not currently guarded against — worth keeping curve
#'     data free of `NA`s in the relevant columns.
#' @param models A named list with `linear` and `poly` elements, each an
#'     `lm` model object — typically the output of [fit_curve_models()].
#' @param conc_col Name of the column containing concentration. Defaults
#'     to `"std_conc"`.
#'
#' @returns A ggplot object.
#' @seealso [fit_curve_models()], [plot_model_comparison()]
#' @export
#'
#' @examples
#' curve <- std_corrected_TDN |>
#'   dplyr::filter(unique_curve_id == unique(std_corrected_TDN$unique_curve_id)[9])
#' models <- fit_curve_models(curve)
#' plot_residual_comparison(curve, models)
#' # add a connecting line between points, e.g. useful when reviewing
#' # several curves at once (see review_model_choice())
#' plot_residual_comparison(curve, models) + ggplot2::geom_line(alpha = 0.5)
plot_residual_comparison <- function(
    curve_data,
    models,
    conc_col = "std_conc"
) {
  residuals_long <- dplyr::bind_rows(
    tibble::tibble(
      curve_id = "curve", conc = curve_data[[conc_col]],
      residual = stats::residuals(models$linear), model = "linear"),
    tibble::tibble(
      curve_id = "curve", conc = curve_data[[conc_col]],
      residual = stats::residuals(models$poly), model = "poly")
    )

  plot_residuals_from_long(residuals_long)
}



#' Review linear vs. polynomial model choice across several standard curves
#'
#' Samples (or uses all of) the curves in `data`, fits both a linear and
#' polynomial model to each, and builds comparison + residual plots to
#' help decide which model is more appropriate. Two display modes: a
#' paginated list of individual per-curve plots (`overplot = FALSE`,
#' the default), or one combined figure overplotting all selected
#' curves together (`overplot = TRUE`), better suited to reviewing a
#' larger number of curves at once.
#'
#' @param data A tibble containing data for multiple standard curves,
#'     with the columns referenced by `curve_id_col`, `conc_col`, and
#'     `value_col`.
#' @param n_curves Number of curves to review. If `NULL` (the default),
#'     all curves in `data` are used. If greater than the number of
#'     available curves, a message is printed and all available curves
#'     are used instead.
#' @param curve_id_col Name of the column identifying which curve a row
#'     belongs to. Defaults to `"unique_curve_id"`.
#' @param conc_col Name of the column containing concentration. Defaults
#'     to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param through_origin Whether to force both models through the origin.
#'     Defaults to `TRUE`.
#' @param unit_col Passed through to [plot_model_comparison()] /
#'     `plot_std()`. Defaults to `NULL` (no unit shown).
#' @param colour_col Passed through to [plot_model_comparison()] — only
#'     meaningful when `overplot = TRUE` (the paginated mode shows one
#'     curve at a time, so colour is moot there). If `NULL` (the
#'     default), curves are coloured by `curve_id_col`, which can look
#'     like a rainbow with many curves, since curve IDs aren't ordered
#'     meaningfully. Set to something scientifically relevant instead —
#'     e.g. a date or dilution-factor column — to colour by what
#'     actually matters for interpreting the fit.
#' @param random_sample Whether to select curves randomly (`TRUE`, the
#'     default) or simply take the first `n_curves` as they appear in
#'     `data`.
#' @param seed Optional random seed, for reproducible sampling when
#'     `random_sample = TRUE`.
#' @param overplot If `FALSE` (the default), returns a named list with
#'     one comparison+residual pair per curve. If `TRUE`, returns one
#'     combined figure overplotting all selected curves together.
#' @param overplot_smooth_alpha,overplot_smooth_linewidth,overplot_smooth_linetype
#'     Smooth-curve styling used only when `overplot = TRUE` — the
#'     default `plot_std()` styling (thin, dashed, faint) is hard to see
#'     with many overlapping curves. Defaults to a more visible
#'     `alpha = 0.6`, `linewidth = 0.8`, `linetype = 1` (solid).
#' @param legend_position Passed through to [plot_model_comparison()] —
#'     `ggplot2` `legend.position` value for the comparison plot's
#'     colour legend, relevant when `colour_col` is set. Also applied to
#'     the overplot residual plot's own model-type legend (linear vs.
#'     polynomial), so both legends stay visually consistent. Defaults
#'     to `"none"`.
#'
#' @returns Either a named list (one entry per curve, each with
#'     `models`, `comparison_plot`, and `residual_plot`), or a single
#'     combined `patchwork` figure — see `overplot`.
#' @seealso [fit_curve_models()], [plot_model_comparison()], [plot_residual_comparison()]
#' @export
#'
#' @examples
#' paginated_review <- review_model_choice(std_corrected_TDN, n_curves = 5, seed = 1)
#' # Look at the polynomial model fit of a single curve
#' paginated_review$NO3_TDN_25_col1$models$poly
#' # Look at a single curve
#' paginated_review[[1]]$comparison_plot /
#'   (paginated_review[[1]]$residual_plot +
#'     ggplot2::theme(legend.position = "bottom")) +
#'   patchwork::plot_annotation(title = names(paginated_review[1]))
#' # Multiple curve observation
#' review_model_choice(
#'   std_corrected_TDN, n_curves = 10, overplot = TRUE,
#'   legend_position = "bottom", overplot_smooth_alpha = 0.2)
#' # Multiple curve observation with additional colour aesthetic
#' review_model_choice(std_corrected_TDN, n_curves = 10, overplot = TRUE, colour_col = "date")
review_model_choice <- function(
    data,
    n_curves = NULL,
    curve_id_col = "unique_curve_id",
    conc_col = "std_conc",
    value_col = "abs_corrected",
    through_origin = TRUE,
    unit_col = NULL,
    colour_col = NULL,
    random_sample = TRUE,
    seed = NULL,
    overplot = FALSE,
    overplot_smooth_alpha = 0.3,
    overplot_smooth_linewidth = 0.8,
    overplot_smooth_linetype = 1,
    legend_position = "right"
) {
  # decide which curves to review: all of them (n_curves = NULL), a
  # random sample, or simply the first n_curves found
  all_curve_ids <- data |> dplyr::pull(.data[[curve_id_col]]) |> unique()

  if (!is.null(n_curves) && n_curves > length(all_curve_ids)) {
    message(
      "n_curves (", n_curves, ") is larger than the number of available curves (",
      length(all_curve_ids), "). Using all ", length(all_curve_ids), " curves instead.")
    n_curves <- length(all_curve_ids)
  }

  if (is.null(n_curves)) {
    selected_ids <- all_curve_ids
  } else if (random_sample) {
    if (!is.null(seed)) set.seed(seed)
    selected_ids <- sample(all_curve_ids, size = n_curves)
  } else {
    selected_ids <- utils::head(all_curve_ids, n_curves)
  }

  selected_data <- data |> dplyr::filter(.data[[curve_id_col]] %in% selected_ids)

  if (overplot) {
    # comparison plot: plot_model_comparison() already handles multiple
    # curves natively, grouped/coloured by curve_id_col
    comparison_plot <- plot_model_comparison(
      selected_data, conc_col = conc_col, value_col = value_col,
      curve_id_col = curve_id_col, through_origin = through_origin,
      unit_col = unit_col, colour_col = colour_col,
      smooth_alpha = overplot_smooth_alpha,
      smooth_linewidth = overplot_smooth_linewidth,
      smooth_linetype = overplot_smooth_linetype,
      legend_position = legend_position)

    # residuals: fit each curve's models individually, then combine into
    # one long table for plot_residuals_from_long() - a line connecting
    # each curve's own points helps trace it visually across the plot
    residuals_all <- selected_ids |>
      lapply(function(id) {
        curve_data <- selected_data |> dplyr::filter(.data[[curve_id_col]] == id)
        models <- fit_curve_models(curve_data, conc_col, value_col, through_origin)
        dplyr::bind_rows(
          tibble::tibble(
            curve_id = id, conc = curve_data[[conc_col]],
            residual = stats::residuals(models$linear), model = "linear"),
          tibble::tibble(
            curve_id = id, conc = curve_data[[conc_col]],
            residual = stats::residuals(models$poly), model = "poly"))
      }) |>
      dplyr::bind_rows()

    residual_plot <- plot_residuals_from_long(residuals_all) +
      ggplot2::geom_line(alpha = 0.5) +
      ggplot2::theme(legend.position = legend_position)

    return(patchwork::wrap_plots(comparison_plot, residual_plot, ncol = 1))

  } else {
    # paginated: one comparison+residual pair per curve, individually
    # inspectable in a named list
    result <- selected_ids |>
      lapply(function(id) {
        curve_data <- selected_data |> dplyr::filter(.data[[curve_id_col]] == id)
        models <- fit_curve_models(curve_data, conc_col, value_col, through_origin)
        list(
          models = models,
          comparison_plot = plot_model_comparison(
            curve_data, conc_col = conc_col, value_col = value_col,
            curve_id_col = curve_id_col, through_origin = through_origin,
            unit_col = unit_col, colour_col = colour_col,
            legend_position = legend_position),
          residual_plot = plot_residual_comparison(curve_data, models, conc_col = conc_col))
      })
    names(result) <- selected_ids
    return(result)
  }
}
