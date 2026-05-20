utils::globalVariables(c("std_conc", "unique_curve_id", "abs_corrected"))


#' Perform Linear Model for Standard Curve
#'
#' The linear model is based on the function `lm()` and fits the curve to go through
#'     the origin (0,0), which only makes sense for blank-corrected absorbance data.
#'
#' @param grouped_data A tibble, grouped per curve (e.g., use `dplyr::group_by(plate_id, column)`
#'     on your data before calling the function). Must contain columns `std_conc`,
#'     `unique_curve_id` and `abs_corrected`
#'
#' @import dplyr tibble
#' @importFrom magrittr extract2
#' @importFrom car ncvTest
#' @importFrom car outlierTest
#'
#' @returns A table containing relevant parameters of the linear model, with
#'     - 1 row per "group" (e.g., plate * column, which is relevant to spot outliers).
#'     - columns
#' @export
#'
#' @examples
#' data <- std_corrected |> dplyr::group_by(plate_id, column)
#' lm_std_curve(data)
lm_std_curve <- function(
    grouped_data
) {
  full_data <- grouped_data |> dplyr::mutate(std_conc = as.numeric(std_conc))

  # initiate for loop
  #i = 1
  lm_table <- tibble::tibble(
    unique_curve_id = character(),
    slope = numeric(),
    lm_p = numeric(),
    normality_lm_residuals = character(),
    shapiro_p = numeric(),
    homoscedasticity_lm_residuals = character(),
    breusch_pagan_p = numeric(),
    outlier_rstudent = numeric()
  )

  for (i in 1:dplyr::n_groups(full_data)) {
    #for (i in 1:10) {

    # curve data
    curve <- dplyr::group_split(full_data)[[i]]
    unique_curve_id <- curve |>
      dplyr::select(unique_curve_id) |> magrittr::extract2(1) |> unique()

    # linear model
    my_lm <- stats::lm(abs_corrected ~ 0 + std_conc, data = curve)
    # get details
    sum <- summary(my_lm)
    slope <- my_lm$coefficients |> as.numeric()
    lm_coeff <- sum$coefficients ; names(lm_coeff) <- dimnames(lm_coeff)[[2]]
    lm_p <- lm_coeff["Pr(>|t|)"] |> as.numeric()
    r_squared <- round(sum$r.squared, digits = 2)

    # test normality of residuals for one plate
    shapiro_p <- (stats::residuals(my_lm) |> stats::shapiro.test())$p.value |> round(digits = 3)
    if (shapiro_p < 0.05) {normality_lm_residuals <- "Not Normal"} else {normality_lm_residuals <- "Normal"}

    # test homoscedasticity of residuals - # H0 = homoscedasticity
    breusch_pagan_p <- (car::ncvTest(my_lm))$p |> round(digits = 3)
    if (breusch_pagan_p < 0.05) {homoscedasticity_lm_residuals <- "Heteroscedasticity"} else {homoscedasticity_lm_residuals <- "Homooscedasticity"}

    # test for outliers - ideally between -3 and 3 or even -5 and 5 (usage a bit unclear)
    outlier_rstudent <- (car::outlierTest(my_lm))$rstudent |> as.numeric() |> round(digits = 3)#

    # Store all of it in a vector
    new_row <- tibble::tibble(
      unique_curve_id,
      slope,
      lm_p,
      normality_lm_residuals,
      shapiro_p,
      homoscedasticity_lm_residuals,
      breusch_pagan_p,
      outlier_rstudent
    )

    lm_table <- lm_table |> dplyr::bind_rows(new_row)
  }
  return(lm_table)
}
