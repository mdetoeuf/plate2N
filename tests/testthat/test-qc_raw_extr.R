# --- Parametrization ---
# - qc_raw_extr()/suspicious_extr(): confirm non-default var_col/
#   plate_id_col/map_col/value_col all work end to end
#
# --- Core behavior ---
# - qc_raw_extr(): all plates below threshold -> message shown, nothing
#   returned (implicit NULL - worth confirming this explicitly, since
#   the function has no explicit early return in that branch)
# - qc_raw_extr(): some plates above threshold -> warning shown, correct
#   plate_id/map combinations returned
# - suspicious_extr(): confirm the join correctly matches up
#   extract_extractant()'s output against qc_raw_extr()'s flagged
#   plates - a regression test for the explicit by=, in case a future
#   refactor upstream reintroduces an implicit join
# - suspicious_extr(): pass a suspicious_extr_per_plate with an extra,
#   unrelated column (e.g. a stray "notes" column) - confirm the join
#   still produces exactly the expected columns, with no .x/.y
#   duplication - regression test for the defensive select() fix
#
# --- Deprecation ---
# - multiplot_outlier_extr(...) errors with a message pointing to
#   boxplot_outlier_extr()
