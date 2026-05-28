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
#'
#' @import dplyr ggplot2
#'
#' @returns A list of plots, one per curve, annotated with the issue:
#'     - non-significance of the linear modal (p-value > 0.05)
#'     - non-normality of residuals (shapiro test with threshold of p = 0.05)
#'     - heteroscedasticity of residuals (Breusch-Pagan test, threshold of p = 0.05)
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
    std_data) {

  #i = 1
  plots <- list()

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
      lm_p_msg <- paste0("lm: p_val = ", lm_curve$lm_p)
    }
    if (lm_curve$normality_lm_residuals == "Normal") {norm_msg <- ""} else {
      norm_msg <- "Non-Normal"
    }
    if (lm_curve$homoscedasticity_lm_residuals != "Heteroscedasticity") {
      homosced_msg <- ""} else {
        homosced_msg <- "Heteroscedasticity"
      }

    annotation <- paste(lm_p_msg, ", ", norm_msg, ", ", homosced_msg)
    x_pos <- min(curve_data$std_conc)
    y_pos <- max(curve_data$abs_corrected)*0.9

    # plot
    plot <- plot_std(curve_data |> dplyr::rename(abs = abs_corrected)) +
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

