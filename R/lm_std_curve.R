utils::globalVariables(c("std_conc", "unique_curve_id", "abs_corrected"))

#' Compute diagnostic statistics for a fitted standard curve model
#'
#' Extracts diagnostic statistics from an already-fitted model: R²,
#' adjusted R², overall model p-value, tests of residual normality
#' (Shapiro-Wilk) and homoscedasticity (Breusch-Pagan), and, for
#' polynomial models, the individual coefficients and their p-values —
#' `poly_a`/`poly_a_p` for the squared (`x²`) term, `poly_b`/`poly_b_p`
#' for the linear (`x`) term. Used internally by [lm_std_curve()], but
#' can be called directly on any [fit_curve_model()] output.
#'
#' @param model An `lm` model object, typically from [fit_curve_model()].
#' @param model_type Which kind of model `model` is: `"linear"` or
#'     `"poly"` — determines whether polynomial-specific coefficients
#'     are extracted.
#' @param conc_col Name of the concentration term in the model's
#'     original formula, used to extract polynomial coefficients by
#'     name. Defaults to `"std_conc"`. Only relevant when
#'     `model_type = "poly"`.
#'
#' @returns A one-row tibble of diagnostic statistics.
#' @seealso [fit_curve_model()], [lm_std_curve()]
#' @export
#'
#' @examples
#' curve <- std_corrected |> dplyr::filter(unique_curve_id == unique(std_corrected$unique_curve_id)[1])
#' model <- fit_curve_model(curve, model = "linear")
#' lm_diagnostics(model, model_type = "linear")
lm_diagnostics <- function(
    model,
    model_type = c("linear", "poly"),
    conc_col = "std_conc"
) {
  model_type <- match.arg(model_type)
  model_summary <- summary(model)

  r_squared <- model_summary$r.squared |> as.numeric() |> round(digits = 4)
  adj_r_squared <- model_summary$adj.r.squared |> as.numeric() |> round(digits = 4)

  shapiro_p <- (stats::residuals(model) |> stats::shapiro.test())$p.value |> round(digits = 3)
  normality_lm_residuals <- if (shapiro_p < 0.05) "Not Normal" else "Normal"

  breusch_pagan_p <- (car::ncvTest(model))$p |> round(digits = 3)
  homoscedasticity_lm_residuals <- if (breusch_pagan_p < 0.05) "Heteroscedasticity" else "Homoscedasticity"

  if (model_type == "linear") {
    slope <- model$coefficients |> as.numeric()
    lm_p <- model_summary$coefficients[, "Pr(>|t|)"] |> as.numeric() |> signif(digits = 4)

    diagnostics <- tibble::tibble(
      slope, r_squared, adj_r_squared, lm_p,
      normality_lm_residuals, shapiro_p,
      homoscedasticity_lm_residuals, breusch_pagan_p)

  } else {
    poly_term <- paste0("I(", conc_col, "^2)")
    poly_a <- model$coefficients[[poly_term]]
    poly_b <- model$coefficients[[conc_col]]
    poly_a_p <- model_summary$coefficients[poly_term, "Pr(>|t|)"]
    poly_b_p <- model_summary$coefficients[conc_col, "Pr(>|t|)"]

    lm_fstat <- model_summary$fstatistic["value"]
    lm_numdf <- model_summary$fstatistic["numdf"]
    lm_dendf <- model_summary$fstatistic["dendf"]
    lm_p <- stats::pf(lm_fstat, lm_numdf, lm_dendf, lower.tail = FALSE) |> signif(digits = 4)

    diagnostics <- tibble::tibble(
      poly_a, poly_a_p, poly_b, poly_b_p,
      r_squared, adj_r_squared, lm_p,
      normality_lm_residuals, shapiro_p,
      homoscedasticity_lm_residuals, breusch_pagan_p)
  }

  return(diagnostics)
}


#' Perform Linear Model for Standard Curve
#'
#' The linear model is based on the function `lm()` and fits the curve to go through
#'     the origin (0,0), which only makes sense for blank-corrected absorbance data.
#'
#' Formula within `lm()`.
#'     For linear model: `y = m*x + c`;
#'     For polynomial model: `y = a*x^2 + b*x + c`;
#'     With
#'       - y = blank-corrected absorbance
#'       - x = concentration
#'       - c = 0 because we use blank-corrected absorbance data
#'
#' Fitting itself is delegated to [fit_curve_model()] (the same function
#' used by the `model-choice` toolkit), with diagnostic statistics
#' computed by [lm_diagnostics()] — call that directly if you only need
#' diagnostics for a single already-fitted model.
#'
#' @param grouped_data A tibble, grouped per curve (e.g., use `dplyr::group_by(plate_id, column)`
#'     on your data before calling the function). Must contain the
#'     columns referenced by `conc_col`, `value_col`, `curve_id_col`,
#'     `dataset_col`, `plate_id_col`, and `std_sp_col`.
#' @param model Which model to use. Accepts either `linear` (default) or `poly`
#'     for polynomial model.
#' @param conc_col Name of the column containing concentration. Defaults
#'     to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param curve_id_col Name of the column identifying which curve a row
#'     belongs to. Defaults to `"unique_curve_id"`.
#' @param dataset_col Name of the column identifying the dataset.
#'     Defaults to `"dataset"`.
#' @param plate_id_col Name of the column identifying physical plates.
#'     Defaults to `"plate_id"`.
#' @param std_sp_col Name of the column identifying the standard species.
#'     Defaults to `"std_sp"`.
#' @param through_origin Whether to force the model through the origin.
#'     Defaults to `TRUE`. See [fit_curve_model()] for the same
#'     argument's meaning.
#'
#' @importFrom car ncvTest
#'
#' @returns A table containing relevant parameters of the linear model, with
#'     - 1 row per "group" (e.g., plate * column, which is relevant to spot outliers).
#'     - columns: `unique_curve_id`, `slope`, `r_squared`, `adj_r_squared`, `lm_p`,
#'       `normality_lm_residuals`, `shapiro_p`, `homoscedasticity_lm_residuals`,
#'       `breusch_pagan_p`. When `model = "poly"`, also `poly_a`/`poly_a_p`
#'       (the squared, `x^2`, term's coefficient and p-value) and
#'       `poly_b`/`poly_b_p` (the linear, `x`, term's coefficient and
#'       p-value).
#'
#' @seealso [fit_curve_model()], [lm_diagnostics()]
#' @export
#'
#' @examples
#' data <- std_corrected |> dplyr::group_by(plate_id, column)
#' lm_std_curve(data)
lm_std_curve <- function(
    grouped_data,
    model = "linear",
    conc_col = "std_conc",
    value_col = "abs_corrected",
    curve_id_col = "unique_curve_id",
    dataset_col = "dataset",
    plate_id_col = "plate_id",
    std_sp_col = "std_sp",
    through_origin = TRUE
) {
  full_data <- grouped_data |> dplyr::mutate(dplyr::across(dplyr::all_of(conc_col), as.numeric))

  splitted_data <- dplyr::group_split(full_data)

  lm_data <- NULL
  for (i in seq_len(dplyr::n_groups(full_data))) {

    curve <- splitted_data[[i]]

    fitted_model <- fit_curve_model(
      curve, model = model, conc_col = conc_col, value_col = value_col, through_origin = through_origin)

    diagnostics <- lm_diagnostics(fitted_model, model_type = model, conc_col = conc_col)

    new_row <- tibble::tibble(
      dataset = curve[[dataset_col]][1],
      plate_id = curve[[plate_id_col]] |> unique(),
      unique_curve_id = curve[[curve_id_col]] |> unique(),
      std_sp = curve[[std_sp_col]] |> unique()
    ) |> dplyr::bind_cols(diagnostics)

    lm_data <- dplyr::bind_rows(lm_data, new_row)
  }

  return(lm_data)
}



utils::globalVariables(c("lm_p", "normality_lm_residuals", "homoscedasticity_lm_residuals", "poly_a_p", "poly_b_p"))

#' Extract Suspicious Rows from Linear Model Data (non-significance, Non-normality, heteroscedasticity)
#'
#' This "bad" subset of linear model data (regression of standard curves) is useful
#'     in the case of numerous standard curves. It facilitates individual review
#'     of suspicious curves only.
#'
#' @param lm_data A tible containing data from the linear model. Structured as
#'     the output of `lm_std_curve()`
#' @param model Which model to use. Accepts either `linear` (default) or `poly`
#'     for polynomial model.
#'
#' @import dplyr
#' @returns A tible same structure as lm_data, but contains only "suspicious" standard curves
#'
#' @seealso [lm_std_curve()]
#' @seealso [plot_list_lm()]
#'
#' @export
#'
#' @examples
#' data <- std_corrected |> dplyr::group_by(plate_id, column)
#' lm_data <- lm_std_curve(data)
#' suspicious_lm(lm_data)
suspicious_lm <- function(lm_data, model = "linear") {

  # CASE 1 : LINEAR MODEL
  if (model == "linear") {
    suspicious_lm <- lm_data |>
      dplyr::filter_out(
        .data[["normality_lm_residuals"]] == "Normal" &
          .data[["homoscedasticity_lm_residuals"]] == "Homoscedasticity" &
          .data[["lm_p"]] < 0.05)

    # CASE 2 : POLYNOMIAL MODEL
  } else if (model == "poly") {
    suspicious_lm <- lm_data |>
      dplyr::filter_out(
        .data[["normality_lm_residuals"]] == "Normal" &
          .data[["homoscedasticity_lm_residuals"]] == "Homoscedasticity" &
          .data[["lm_p"]] < 0.05 &
          .data[["poly_a_p"]] < 0.05 &
          .data[["poly_b_p"]] < 0.05
      )

    # CASE 3 : WRONG MODEL SPECIFICATION
  } else stop('
  Argument "model" is not valid.
  Only `model = "linear"` and `model = "poly"` are accepted.
              See also `?suspicious_lm()`')

  return(suspicious_lm)
}





utils::globalVariables(c("std_conc", "abs_corrected"))

#' Compute a list of plots, one per standard curve
#'
#' @param lm_data lm_data in the shape as generated by `lm_std_curve()`,
#'     possibly as a subset to observe only suspicious curves
#' @param std_data tibble containing only standard data, as in `std_corrected`.
#'     Absorbance values should already by blank-corrected
#' @param model Which model to use. Accepts either `linear` (default) or `poly`
#'     for polynomial model.
#' @param conc_col Name of the column containing concentration. Defaults
#'     to `"std_conc"`.
#' @param value_col Name of the column containing (blank-corrected)
#'     absorbance. Defaults to `"abs_corrected"`.
#' @param curve_id_col Name of the column identifying which curve a row
#'     belongs to. Defaults to `"unique_curve_id"`.
#' @param dataset_col Name of the column identifying the dataset.
#'     Defaults to `"dataset"`.
#' @param unit_col Name of the column containing the concentration unit,
#'     shown in the x-axis label. Defaults to `"std_unit"`.
#'
#' @import dplyr ggplot2
#'
#' @returns A list of plots, one per curve, annotated with the issue:
#'     - non-significance of the linear modal (p-value > 0.05)
#'     - non-normality of residuals (shapiro test with threshold of p = 0.05)
#'     - heteroscedasticity of residuals (Breusch-Pagan test, threshold of p = 0.05)
#'     - if `model = "poly"`: non-significance of the `a` and `b` coefficients of the
#'       regression equation `y = ax^2 + bx` (p-value > 0.05)
#' @export
#'
#' @examples
#' lm_data <- lm_std_curve(std_corrected |> dplyr::group_by(plate_id, column))
#' plot_list <- plot_list_lm(
#'     lm_data,
#'     std_data = std_corrected)
#' plot_list[[1]] ; plot_list[[2]]
plot_list_lm <- function(
    lm_data,
    std_data,
    model = "linear",
    conc_col = "std_conc",
    value_col = "abs_corrected",
    curve_id_col = "unique_curve_id",
    dataset_col = "dataset",
    unit_col = "std_unit"
) {

  plots <- list()
  for (i in seq_len(nrow(lm_data))) {
    lm_curve <- lm_data[i,]
    curve_id <- lm_data[["unique_curve_id"]][i]
    dataset <- lm_data[[dataset_col]][i]

    curve_data <- std_data |>
      dplyr::filter(.data[[curve_id_col]] == curve_id) |>
      dplyr::mutate(dplyr::across(dplyr::all_of(conc_col), as.numeric))

    # gathering info to display
    if (lm_curve[["lm_p"]] < 0.05) { lm_p_msg <- ""} else {
      lm_p_msg <- paste0("lm: p_val = ", lm_curve[["lm_p"]], ", ")
    }
    if (lm_curve[["normality_lm_residuals"]] == "Normal") {norm_msg <- ""} else {
      norm_msg <- "Non-Normal, "
    }
    if (lm_curve[["homoscedasticity_lm_residuals"]] != "Heteroscedasticity") {
      homosced_msg <- ""} else {
        homosced_msg <- "Heteroscedasticity, "
      }

    annotation <- paste(lm_p_msg, norm_msg, homosced_msg)

    if (model == "poly") {
      if (lm_curve[["poly_a_p"]] < 0.05) {coeff_a <- ""} else {
        coeff_a <- paste0("a: p_val = ", signif(lm_curve[["poly_a_p"]], digits = 2), ", ")
      }
      if (lm_curve[["poly_b_p"]] < 0.05) {coeff_b <- ""} else {
        coeff_b <- paste0("b: p_val = ", signif(lm_curve[["poly_b_p"]], digits = 2), ", ")
      }

      annotation <- paste(annotation, coeff_a, coeff_b)
    }

    x_pos <- min(curve_data[[conc_col]])
    y_pos <- max(curve_data[[value_col]]) * 0.9

    plot <- plot_std(
      curve_data, model = model,
      conc_col = conc_col, value_col = value_col, unit_col = unit_col) +
      ggplot2::labs(title = curve_id, subtitle = dataset) +
      ggplot2::ylab("Blank-corrected Absorbance") +
      ggplot2::theme(legend.position = "none") +
      ggplot2::annotate(
        geom = "label", label = annotation,
        x = x_pos, y = y_pos, hjust = 0, colour = "red")

    plots[[curve_id]] <- plot
  }

  return(plots)
}

utils::globalVariables(c("std_sp", "lm_p", "adj_r_squared", "r_squared"))
#' Plot Distribution of Model QC Parameters (p-val, R2 and adjusted R2)
#'
#' @param lm_data lm_data in the shape as generated by `lm_std_curve()`,
#'     possibly as a subset to observe only suspicious curves. Must contain a
#'     column named `std_sp` (add it with `dplyr::left_join()` if necessary)
#' @param p_or_r Defines which parameter to plot Accepted values are `"p"`
#'     (default), `"adjR2"`and `"R2"`.
#' @param threshold Defaults at 0.05 (as a significance threshold of the p-value).
#'     Accepts any value. For R2 or adjusted R2, 0.95 or 0.98 might be good options.
#'     This is a graphical parameter only (defines the position of the vertical line)
#' @param facetting_std_sp Logical, defaults as `TRUE`. Whether to use faceting
#'     according to standard species
#' @param color_std_sp Logical, defaults as `TRUE`. Whether to group according to
#'     standard species (and overplot with several colours)
#'
#' @import dplyr ggplot2
#'
#' @returns A ggplot object
#' @export
#'
#' @examples
#' lm_data <- lm_output$lm_data # no column called "std_sp"
#' # get standard species from std_corrected
#' (std_sp <- std_corrected |> dplyr::select(plate_id, std_sp) |> unique())
#' # Artificially changing a std_sp for the sake of facetting
#' std_sp$std_sp[3:4] <- rep("NO2")
#' lm_data_full <- lm_data |> dplyr::left_join(std_sp, by = dplyr::join_by(plate_id))
#' density_lm_param(lm_data_full, facetting_std_sp = FALSE)
#' density_lm_param(
#'   lm_data_full,
#'   p_or_r = "adjR2", threshold = 0.95,
#'   color_std_sp = FALSE)
density_lm_param <- function(
    lm_data,
    p_or_r = "p", # or p_or_r <- "adjR2" or p_or_r <- "R2"
    threshold = 0.05, # for R: threshold = 0.95
    facetting_std_sp = TRUE,
    color_std_sp = TRUE
) {

  # SET UP GRAPHICAL PARAMETERS
  n_row <- lm_data |> dplyr::select(dplyr::all_of("std_sp")) |> unique() |> nrow()
  if (p_or_r == "p") {
    label_1 <- "p-value"
    xlim <- c(0, max(-log(lm_data[["lm_p"]])))
    xlab <- "-log(p-value of model)"
    subtitle = "logarithmic scale"
  } else if (p_or_r == "adjR2") {
    label_1 <- "adjusted R2"
    xlim <- c(
      min(0.945, min(lm_data[["adj_r_squared"]])),
      max(lm_data[["adj_r_squared"]]))
    xlab <- "Adjusted R2"
    subtitle <- ""
  } else if (p_or_r == "R2") {
    label_1 <- "R2 = "
    xlim <- c(
      min(0.945, min(lm_data[["r_squared"]])),
      max(lm_data[["r_squared"]]))
    xlab <- "R2"
    subtitle <- ""
  }

  label <- paste0(label_1, " = ", threshold)
  title = paste0("Distribution of ", label_1, " of the models")
  label_x <- if(
    p_or_r == "p") (-log(threshold)) else if (
      p_or_r %in% c("adjR2", "R2")) (threshold)

  # INITIATE PLOT
  plot <- lm_data |>
    ggplot2::ggplot(ggplot2::aes(
      x = if (
        p_or_r == "p") (-log(.data[["lm_p"]])) else if (
          p_or_r == "adjR2") (.data[["adj_r_squared"]]) else if (
            p_or_r == "R2") (.data[["r_squared"]]),
      colour = if (color_std_sp) .data[["std_sp"]],
      fill = if (color_std_sp) .data[["std_sp"]]
    )) +
    ggplot2::theme_minimal() +
    ggplot2::geom_density(alpha = 0.3) +
    ggplot2::geom_vline(
      ggplot2::aes(xintercept = if (
        p_or_r == "p") (-log(threshold)) else if (
          p_or_r %in% c("adjR2", "R2")) (threshold)),
      linetype = 2, colour = "purple") +
    {if (facetting_std_sp) ggplot2::facet_wrap(~std_sp, nrow = n_row) } +
    ggplot2::xlim(xlim) +
    ggplot2::xlab(xlab) +
    ggplot2::labs(
      title = title, subtitle = subtitle,
      colour = "Standard\nspecies", fill = "Standard\nspecies"
    )

  # extract max y of the curve
  plot_data <- ggplot2::ggplot_build(plot)
  max_y <- plot_data$data[[1]]$y |> max()

  # Draw plot + add label
  plot_label <- plot +
    ggplot2::annotate(
      geom = "label", label = label,
      x = label_x,
      y = max_y*0.8, hjust = 0.25, colour = "purple" )

  return(plot_label)
}

