utils::globalVariables(c("std_conc", "unique_curve_id", "abs_corrected"))


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
#' @param grouped_data A tibble, grouped per curve (e.g., use `dplyr::group_by(plate_id, column)`
#'     on your data before calling the function). Must contain columns `std_conc`,
#'     `unique_curve_id` and `abs_corrected`
#' @param model Which model to use. Accepts either `linear` (default) or `poly`
#'     for polynomial model.
#'
#' @import dplyr tibble
#' @importFrom magrittr extract2
#' @importFrom car ncvTest
#' @importFrom car outlierTest
#' @importFrom stats pf
#'
#' @returns A table containing relevant parameters of the linear model, with
#'     - 1 row per "group" (e.g., plate * column, which is relevant to spot outliers).
#'     - columns: `unique_curve_id`, `slope`, `r_squared`, `adj_r_squared`, `lm_p`,
#'       `normality_lm_residuals`, `shapiro_p`, `homoscedasticity_lm_residuals`,
#'       `breusch_pagan_p`
#'
#' @export
#'
#' @examples
#' data <- std_corrected |> dplyr::group_by(plate_id, column)
#' lm_std_curve(data)
lm_std_curve <- function(
    grouped_data,
    model = "linear"
) {
  full_data <- grouped_data |> dplyr::mutate(std_conc = as.numeric(std_conc))


  # initiate empty tibble for the looploop

  # CASE 1 : LINEAR MODEL
  if (model == "linear") {
    lm_data <- tibble::tibble(
      plate_id = character(),
      unique_curve_id = character(),
      slope = numeric(),
      r_squared = numeric(),
      adj_r_squared = numeric(),
      lm_p = numeric(),
      normality_lm_residuals = character(),
      shapiro_p = numeric(),
      homoscedasticity_lm_residuals = character(),
      breusch_pagan_p = numeric()#,
      # outlier_rstudent = numeric()
    )

    # CASE 2 : POLYNOMIAL MODEL
  } else if (model == "poly") {
    lm_data <- tibble::tibble(
      plate_id = character(),
      unique_curve_id = character(),
      poly_a = numeric(),
      poly_a_p = numeric(),
      poly_b = numeric(),
      poly_b_p = numeric(),
      r_squared = numeric(),
      adj_r_squared = numeric(),
      lm_p = numeric(),
      normality_lm_residuals = character(),
      shapiro_p = numeric(),
      homoscedasticity_lm_residuals = character(),
      breusch_pagan_p = numeric()#,
    )
  } else stop('Argument "model" is not valid.
              Only `model = "linear"` and `model = "poly"` are accepted.
              See also `?lm_std_curve()`')

  #i = 9
  for (i in 1:dplyr::n_groups(full_data)) {
    #for (i in 1:10) {

    # curve data, regardless of model
    curve <- dplyr::group_split(full_data)[[i]]
    plate_id <- curve |>
      dplyr::select(plate_id) |> magrittr::extract2(1) |> unique()
    unique_curve_id <- curve |>
      dplyr::select(unique_curve_id) |> magrittr::extract2(1) |> unique()

    # CASE 1 : linear model
    if (model == "linear") {
      lm_linear <- stats::lm(abs_corrected ~ 0 + std_conc, data = curve)
      sum_linear <- summary(lm_linear)
      slope <- lm_linear$coefficients |> as.numeric()
      r_squared <- sum_linear$r.squared |> as.numeric() |> round(digits = 4)
      adj_r_squared <- sum_linear$adj.r.squared |> as.numeric() |> round(digits = 4)
      lm_coeff <- sum_linear$coefficients ; names(lm_coeff) <- dimnames(lm_coeff)[[2]]
      lm_p <- lm_coeff["Pr(>|t|)"] |> as.numeric() |> signif(digits = 4)
      # test normality of residuals for one plate
      shapiro_p <- (stats::residuals(lm_linear) |> stats::shapiro.test())$p.value |> round(digits = 3)
      if (shapiro_p < 0.05) {normality_lm_residuals <- "Not Normal"} else {normality_lm_residuals <- "Normal"}

      # test homoscedasticity of residuals - # H0 = homoscedasticity
      breusch_pagan_p <- (car::ncvTest(lm_linear))$p |> round(digits = 3)
      if (breusch_pagan_p < 0.05) {homoscedasticity_lm_residuals <- "Heteroscedasticity"} else {homoscedasticity_lm_residuals <- "Homoscedasticity"}

      # test for outliers - ideally between -3 and 3 or even -5 and 5 (usage a bit unclear)
      # outlier_rstudent <- (car::outlierTest(my_lm))$rstudent |> as.numeric() |> round(digits = 3)#

      # Store all of it in a vector
      new_row <- tibble::tibble(
        plate_id,
        unique_curve_id,
        slope,
        r_squared,
        adj_r_squared,
        lm_p,
        normality_lm_residuals,
        shapiro_p,
        homoscedasticity_lm_residuals,
        breusch_pagan_p #,
        # outlier_rstudent
      )


      # CASE 2 : polynomial model

    } else if (model == "poly") {
      # compute model
      lm_poly <- stats::lm(abs_corrected ~ 0 + std_conc + I(std_conc^2), data = curve)
      sum_poly <- summary(lm_poly)

      # get coefficients of the modeled curve + their p-value
      poly_a <- lm_poly$coefficients["I(std_conc^2)"]
      poly_b <- lm_poly$coefficients["std_conc"]
      poly_a_p <- sum_poly$coefficients[2,4]
      poly_b_p <- sum_poly$coefficients[1,4]

      # get R^2 of the model
      r_squared <- sum_poly$r.squared |> as.numeric() |> round(digits = 4)
      adj_r_squared <- sum_poly$adj.r.squared |> as.numeric() |> round(digits = 4)

      # get p-value of the model
      lm_fstat <- sum_poly$fstatistic["value"]
      lm_numdf <- sum_poly$fstatistic["numdf"]
      lm_dendf <- sum_poly$fstatistic["dendf"]
      lm_p <- stats::pf(lm_fstat, lm_numdf, lm_dendf, lower.tail = FALSE) |> signif(digits = 4)

      # test normality of residuals for one plate
      shapiro_p <- (stats::residuals(lm_poly) |> stats::shapiro.test())$p.value |> signif(digits = 4)
      if (shapiro_p < 0.05) {normality_lm_residuals <- "Not Normal"} else {normality_lm_residuals <- "Normal"}

      # test homoscedasticity of residuals - # H0 = homoscedasticity
      breusch_pagan_p <- (car::ncvTest(lm_poly))$p |> signif(digits = 4)
      if (breusch_pagan_p < 0.05) {homoscedasticity_lm_residuals <- "Heteroscedasticity"} else {homoscedasticity_lm_residuals <- "Homoscedasticity"}
      #

      # Store all of it in a vector
      new_row <- tibble::tibble(
        plate_id,
        unique_curve_id,
        poly_a,
        poly_a_p,
        poly_b,
        poly_b_p,
        r_squared,
        adj_r_squared,
        lm_p,
        normality_lm_residuals,
        shapiro_p,
        homoscedasticity_lm_residuals,
        breusch_pagan_p#,
      )
    }




    lm_data <- lm_data |> dplyr::bind_rows(new_row)

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
        normality_lm_residuals == "Normal" &
          homoscedasticity_lm_residuals == "Homoscedasticity" &
          lm_p < 0.05)

    # CASE 2 : POLYNOMIAL MODEL
  } else if (model == "poly") {
    suspicious_lm <- lm_data |>
      dplyr::filter_out(
        normality_lm_residuals == "Normal" &
          homoscedasticity_lm_residuals == "Homoscedasticity" &
          lm_p < 0.05 &
          poly_a_p < 0.05 &
          poly_b_p < 0.05
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
    lm_data, # lm_data <- lm_suspicious_NO3
    std_data, # std_data <- std_corrected
    model = "linear") { # model = "poly"

  #i = 1
  plots <- list()
  #i = 1
  #for (i in 1:10) {
  for (i in 1:nrow(lm_data)) {
    # curve data
    lm_curve <- lm_data[i,]
    curve_id <- lm_data$unique_curve_id[i]

    curve_data <- std_data |>
      dplyr::filter(unique_curve_id == curve_id) |>
      dplyr::mutate(std_conc = as.numeric(std_conc))

    # std unit for plotting
    std_unit <- curve_data$std_unit |> unique()

    # gathering info to display
    if (lm_curve$lm_p < 0.05) { lm_p_msg <- ""} else {
      lm_p_msg <- paste0("lm: p_val = ", lm_curve$lm_p, ", ")
    }
    if (lm_curve$normality_lm_residuals == "Normal") {norm_msg <- ""} else {
      norm_msg <- "Non-Normal, "
    }
    if (lm_curve$homoscedasticity_lm_residuals != "Heteroscedasticity") {
      homosced_msg <- ""} else {
        homosced_msg <- "Heteroscedasticity, "
      }

    annotation <- paste(lm_p_msg, norm_msg, homosced_msg)

    if (model == "poly") {
      if (lm_curve$poly_a_p < 0.05) {coeff_a <- ""} else {
        coeff_a <- paste0("a: p_val = ", signif(lm_curve$poly_a_p, digits = 2), ", ")
      }
      if (lm_curve$poly_b_p < 0.05) {coeff_b <- ""} else {
        coeff_b <- paste0("b: p_val = ", signif(lm_curve$poly_b_p, digits = 2), ", ")
      }

      annotation <- paste(annotation, coeff_a, coeff_b)
    }



    x_pos <- min(curve_data$std_conc)
    y_pos <- max(curve_data$abs_corrected)*0.9

    # plot
    plot <- plot_std(curve_data |> dplyr::rename(abs = abs_corrected), model = model) +
      ggplot2::labs(title = curve_id) +
      ggplot2::xlab(paste0("Concentration of Standard Curve [", std_unit, "]")) +
      ggplot2::ylab("Blank-corrected Absorbance") +
      ggplot2::theme(legend.position = "none") +
      ggplot2::annotate(
        geom = "label", label = annotation,
        x = x_pos, y = y_pos, hjust = 0, colour = "red")
    #plot
    plots[[curve_id]] <- plot
    #i = i+1

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
  n_row <- lm_data |> dplyr::select(std_sp) |> unique() |> nrow()
  if (p_or_r == "p") {
    label_1 <- "p-value"
    xlim <- c(0,max(-log(lm_data$lm_p)))
    xlab <- "-log(p-value of model)"
    subtitle = "logarithmic scale"
  } else if (p_or_r == "adjR2") {
    label_1 <- "adjusted R2"
    xlim <- c(
      min(0.945, min(lm_data$adj_r_squared)),
      max(lm_data$adj_r_squared))
    xlab <- "Adjusted R2"
    subtitle <- ""
  } else if (p_or_r == "R2") {
    label_1 <- "R2 = "
    xlim <- c(
      min(0.945, min(lm_data$r_squared)),
      max(lm_data$r_squared))
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
        p_or_r == "p") (-log(lm_p)) else if (
          p_or_r == "adjR2") (adj_r_squared) else if (
            p_or_r == "R2") (r_squared),
      colour = if (color_std_sp) std_sp,
      fill = if (color_std_sp) std_sp
    )) +
    ggplot2::theme_minimal() +
    # geom_histogram() +
    ggplot2::geom_density(alpha = 0.3) +
    ggplot2::geom_vline(
      ggplot2::aes(xintercept = if (
        p_or_r == "p") (-log(threshold)) else if (
          p_or_r %in% c("adjR2", "R2")) (threshold)),
      linetype = 2, colour = "purple") +
    # annotate(
    #   geom = "label", label = label,
    #   x = label_x,
    #   y = 0.15, hjust = 0.25, colour = "purple" ) +
    {if (facetting_std_sp) ggplot2::facet_wrap(~std_sp, nrow = n_row) } +
    ggplot2::xlim(xlim) +
    ggplot2::xlab(xlab) +
    ggplot2::labs(
      title = title, subtitle = subtitle,
      colour = "Standard species", fill = "Standard species"
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

