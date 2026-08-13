# --- Core behavior ---
# - basic case: correctly blank-corrects a single-extractant dataset
#   (compare abs_corrected against a hand-computed expected value)
# - map_to_exclude: rows matching these values are correctly excluded
#   from the output
#
# --- extr_id handling ---
# - single extractant (no extr_id column present initially): extr_id
#   gets correctly filled with extr_def
# - per_plate_avg_blank with a map_col: gets correctly renamed to
#   extr_id before joining (the double-extractant case, using
#   dbl_extr_plate from the roxygen examples)
#
# --- Regression tests for today's fixes ---
# - the right_join() now has an explicit by= (dataset_col, plate_id_col,
#   "extr_id") - construct a case with an extra shared column between
#   raw_wells_data and per_plate_avg_blank that ISN'T part of the
#   intended key, and confirm it doesn't silently change the join
#   result (i.e. confirm the join key is exactly what's declared, not
#   "whatever happens to overlap")
# - the anti_join() lost-rows check now keyed on unique_well_id_col
#   only - confirm the warning still fires correctly when rows are
#   genuinely lost (e.g. an incomplete map_to_exclude)
#
# --- Parametrization ---
# - value_col/map_col/blank_avg_col/dataset_col/plate_id_col/
#   unique_well_id_col: confirm a fully renamed dataset still works
#   end to end
#
# --- Edge cases, not yet decided ---
# - what happens if per_plate_avg_blank is missing dataset_col or
#   plate_id_col entirely (rather than just having a different name)?
#   The join would currently fail with dplyr's own generic error -
#   same "let dplyr's error stand" decision made earlier in this
#   sweep for qc_raw_abs()'s parametrized columns, not a new gap
