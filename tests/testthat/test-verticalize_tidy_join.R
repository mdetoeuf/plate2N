# --- verticalize_plates() ---
# - row_col/column_cols: confirm non-default names work end to end, and
#   that the OUTPUT always uses the package's standard "row"/"column"
#   naming regardless of what the raw input called them
# - coerce_numeric = TRUE vs. FALSE: confirm the resulting columns are
#   actually numeric vs. character, not just that it runs
# - prefix: confirm it's applied to data columns but not to "row"/
#   "column" themselves
#
# --- join_abs_map() ---
# - regression test for today's fix: tibble_list with exactly ONE
#   element should work without error (this was the actual bug -
#   2:length(tibble_list) became a descending 2:1 sequence and crashed)
# - two-element tibble_list still joins correctly (the original,
#   already-working case)
# - abs_map/coerce_numeric length mismatches vs. tibble_list still
#   trigger their existing stop() messages
# - coerce_numeric given as a single value vs. a per-tibble vector both
#   work
#
# --- vertical_to_tidy() ---
# - regression test for today's fix: calling vertical_to_tidy(x) alone
#   (not wrapped in extra parens) should actually print a result, not
#   return invisibly
# - well_id/unique_well_id are correctly constructed from row+column+
#   plate_id
# - column_def: confirm passing a different value doesn't change the
#   output at all (documents/verifies that it's genuinely a no-op, per
#   today's roxygen update)
#
# --- Removed from this file, no tests needed ---
# - tibble_to_list() removed entirely (confirmed unused in both the
#   package and the user's own pipeline)



# TEST join_abs_map() -------------------------------------------------------

test_that("join_abs_map() returns a tibble", {
  expect_true(
    "tbl" %in% class(
      join_abs_map(
        tibble_list = list(tibble_example, tibble_example),
        abs_map = c("abs-", "map-"))
    )
  )
})

test_that("join_abs_map() accepts a pre-matched coerce_numeric vector", {
  expect_no_error(
    join_abs_map(
      tibble_list = list(tibble_example, tibble_example),
      abs_map = c("abs-", "map-"),
      coerce_numeric = c(FALSE, FALSE))
  )
})

test_that("join_abs_map() still works with a single recycled coerce_numeric value", {
  expect_no_error(
    join_abs_map(
      tibble_list = list(tibble_example, tibble_example),
      abs_map = c("abs-", "map-"),
      coerce_numeric = FALSE)
  )
})
