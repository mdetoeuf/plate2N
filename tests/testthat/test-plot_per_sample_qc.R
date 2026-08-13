# --- Parametrization ---
# - plot_list_qc_microresp(): confirm the new dataset_col works, and
#   that non-default map_col/plate_id_col/value_col/label_col/panel_col
#   still work end to end (no dedicated test yet for this function at
#   all)
# - boxplot_values()/plot_ridges_values(): confirm non-default x_col/
#   y_col/value_col/groups_col/label_col all work
# - plot_qc_sample_pair()/plot_list_qc_samples(): confirm non-default
#   y_col/value_col work end to end
#
# --- colour_col dual behavior (NULL / literal colour / column name) ---
# - boxplot_values()/plot_ridges_values(): all three colour_col cases
#   (NULL, a literal colour string, a real column name) produce a plot
#   without erroring, and that the literal-colour case actually uses
#   that colour rather than treating it as a column lookup
#
# --- plot_list_qc_microresp() ---
# - panel_col given vs. NULL: confirm both branches run without error
# - max_plates_per_panel: confirm plates are split evenly (reuse the
#   same even-split logic already tested for plot_list_qc_samples(),
#   see below)
#
# --- add_spacers() ---
# - confirm the interleaved list has the right length (2n-1 for n
#   plots) and that sizes alternates 1/gap_size correctly
# - single-plot input (n = 1): confirm no spacer gets added at all
#
# --- plot_qc_sample_pair()/plot_list_qc_samples() ---
# - n_chunks = NULL vs. explicit: confirm both produce the expected
#   number of chunks
# - value_range = NULL (auto-computed) vs. explicit: confirm an
#   explicitly-passed range is actually used, not silently overridden
# - legend_position: confirm "none" shows no legend and something like
#   "right" does show one, with colour_col set to a real column
# - stopifnot() guard: confirm the "value_col must be numeric" error
#   fires when y_col/value_col are accidentally swapped
#
# --- Known, deliberately accepted edge cases (not to test, already discussed) ---
# - ggrepel label clipping near a panel's value-axis edge: accepted as
#   low-risk, not tested (see the same discussion logged for
#   boxplot_outlier_extr())
# - legend merging across multiple plot_list_qc_samples() chunks:
#   deliberately not merged (each chunk gets flattened via
#   wrap_elements() before combining) - accepted as-is (Option A),
#   not a bug to test against
