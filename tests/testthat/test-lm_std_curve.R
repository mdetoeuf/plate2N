# --- lm_diagnostics() ---
# - linear model: returns the expected columns (slope, r_squared,
#   adj_r_squared, lm_p, normality_lm_residuals, shapiro_p,
#   homoscedasticity_lm_residuals, breusch_pagan_p), no poly_* columns
# - poly model: additionally returns poly_a/poly_a_p/poly_b/poly_b_p
# - regression test for today's fix: extracting poly coefficients by
#   term name (not position) - construct a case that would have
#   silently mismatched under the old positional [2,4]/[1,4] indexing
#   if the term order ever differed, and confirm poly_a consistently
#   corresponds to the squared term regardless
#
# --- lm_std_curve() ---
# - linear vs. poly model: correct columns present in each case
#   (delegates to lm_diagnostics(), but worth confirming end to end
#   through the full grouped-data pipeline too)
# - through_origin = TRUE vs. FALSE produces genuinely different fits
#   (same test spirit as fit_curve_model()'s own, but confirming the
#   parameter is actually threaded through this function correctly)
# - one row per group, correctly labelled with dataset/plate_id/
#   unique_curve_id/std_sp
# - regression test for the seq_len()/n_groups() fix: confirm this
#   doesn't error on an edge case with very few groups (can't easily
#   test true zero-group input without constructing degenerate data,
#   but worth at least a 1-group case)
# - non-default conc_col/value_col/curve_id_col/dataset_col/
#   plate_id_col/std_sp_col all work end to end
#
# --- suspicious_lm() ---
# - linear model: correctly filters OUT curves that pass all 3
#   criteria (normal residuals, homoscedastic, significant), keeping
#   only genuinely suspicious ones
# - poly model: same, but with the 2 additional coefficient-
#   significance criteria
# - invalid model argument errors with the documented message
#
# --- plot_list_lm() ---
# - runs without error for both linear and poly models
# - regression test for today's simplification: confirm the plot's
#   x-axis actually shows the unit (via unit_col), now that the
#   manual rename()+xlab() construction was replaced with plot_std()'s
#   own value_col/unit_col handling
# - non-default conc_col/value_col/curve_id_col/dataset_col/unit_col
#   work end to end
#
# --- density_lm_param() ---
# - p_or_r = "p"/"adjR2"/"R2": all three run without error and
#   produce the expected axis label/range
# - facetting_std_sp/color_std_sp: both TRUE/FALSE combinations run
#   without error
#
# --- Not yet decided ---
# - Whether to eventually consolidate suspicious_lm()'s hardcoded
#   output-column names with lm_diagnostics()'s own column-producing
#   logic, so the two can't silently drift apart if lm_diagnostics()'s
#   column names ever change. Not urgent, flagged for awareness.
