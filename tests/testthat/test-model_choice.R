# --- fit_curve_model() / fit_curve_models() ---
# - fit_curve_model(): confirm the formula actually differs between
#   model = "linear" and "poly" (check coefficients/terms, not just
#   that it runs)
# - fit_curve_model(): through_origin = TRUE vs. FALSE produces
#   genuinely different fits (with vs. without an intercept term)
# - fit_curve_model(): non-default conc_col/value_col work end to end
# - fit_curve_models(): returns a list with both "linear" and "poly",
#   each matching what fit_curve_model() would produce individually
#
# --- plot_model_comparison() ---
# - runs without error for a single curve, and for multiple curves at
#   once (grouped/coloured by curve_id_col)
# - colour_col = NULL: confirm the default grey30/magenta scheme is
#   used, with no legend shown regardless of legend_position (the
#   synthetic .model_colour column shouldn't leak into a real legend)
# - colour_col set to a real column: confirm it takes priority over
#   the default scheme, and legend_position actually controls
#   visibility
# - non-default conc_col/value_col/unit_col work end to end
#
# --- plot_residual_comparison() ---
# - confirm the plotted residuals actually match
#   stats::residuals(models$linear)/stats::residuals(models$poly),
#   not just that the plot renders
# - non-default conc_col works end to end
# - edge case, not yet decided (flagged in the function's own roxygen):
#   what happens if curve_data has NA values that get silently dropped
#   by lm(), potentially misaligning residuals against curve_data's
#   own concentration column? Not currently guarded against - worth a
#   deliberate decision before writing a test for it
#
# --- review_model_choice() ---
# - n_curves = NULL uses every curve in data
# - n_curves > available curves: triggers the message and caps at the
#   real count, rather than erroring
# - seed: same seed produces the same random sample of curves,
#   reproducibly
# - random_sample = FALSE: takes the first n_curves as they appear,
#   not a random sample
# - overplot = FALSE returns a named list (models/comparison_plot/
#   residual_plot per curve); overplot = TRUE returns a single
#   combined patchwork figure - confirm both return types explicitly
# - colour_col/legend_position: confirm they're threaded through to
#   plot_model_comparison() correctly in both overplot and paginated
#   modes
