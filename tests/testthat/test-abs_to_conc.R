# --- reg_join_abs() ---
# - linear lm_table (has "slope") selects the linear-model column set
# - poly lm_table (has "poly_a") selects the poly-model column set,
#   using the explicit list rather than the old positional range -
#   regression test for today's fix
# - invalid lm_table (neither "slope" nor "poly_a" present) errors
#   with the documented message
# - non-default plate_id_col/dataset_col/map_col/well_id_col/
#   value_col/std_sp_col/unit_col all work end to end
#
# --- convert_molec() ---
# - regression test for today's fix: a custom masses vector actually
#   changes the output (confirms the bug - previously it silently
#   used the hardcoded molar_masses dataset regardless of what was
#   passed)
# - default masses = molar_masses still works as before
# - multiple std_sp/target_sp combinations in one call are all
#   correctly converted, none dropped or duplicated
# - non-default std_sp_col/target_sp_col/value_col/output_col all
#   work end to end
#
# --- Not yet decided ---
# - Whether "# get this into plate2N" (the leftover comment at the
#   top of the original file) implies these functions/this file
#   aren't yet properly wired into the vignette - user believes they
#   likely already are, to be confirmed separately, not blocking
#   this pass
