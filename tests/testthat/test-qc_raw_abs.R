# --- Core behavior ---
# - basic case: a mix of in-range and out-of-range absorbance values ->
#   correct wells identified as suspicious (compare returned well_ids
#   against a hand-checked expected set)
# - all wells in range -> returns 0 rows; message shown (not warning)
# - all wells out of range -> warning shown; all wells returned
#
# --- Filtering logic ---
# - empty_wells filtering: rows with map %in% empty_wells excluded
#   entirely from consideration, even if their absorbance value would
#   otherwise be flagged as out of range
# - empty_wells as a vector of several values (not just one string) ->
#   all of them correctly excluded
# - NA absorbance values: excluded entirely (not counted as in- or
#   out-of-range, not present in the output either way)
#
# --- Messaging/output ---
# - show_msg = FALSE / show_warning = FALSE: confirm the message/warning
#   is actually suppressed when requested
# - export_plot: confirm the named object actually gets created in the
#   global environment, and that it's the expected plot object





# --- Backward compatibility / error handling ---

test_that("qc_raw_abs() errors on empty input", {
  expect_error(
    qc_raw_abs(tidy_table[0, ]),
    "0 rows")
})

# --- Parametrization ---

test_that("qc_raw_abs() works with non-default column names", {
  data <- tidy_plates |>
    dplyr::rename(
      absorbance = abs,
      mapping = map,
      dataset_name = dataset,
      plate = plate_id,
      well = well_id)

  expect_no_error(
    qc_raw_abs(
      data,
      value_col = "absorbance", map_col = "mapping",
      dataset_col = "dataset_name", plate_id_col = "plate",
      well_id_col = "well", show_plot = FALSE,
      min_abs = 0, max_abs = 1, show_msg = FALSE)
  )
})

# --- plot_col_facet ---

test_that("plot_col_facet accepts both NULL and \"none\" for no facetting", {
  expect_no_error(
    qc_raw_abs(tidy_plates, plot_col_facet = "none", show_plot = FALSE, export_plot = "p1",
               min_abs = 0, max_abs = 1, show_msg = FALSE))
  expect_no_error(
    qc_raw_abs(tidy_plates, plot_col_facet = NULL, show_plot = FALSE, export_plot = "p2",
               min_abs = 0, max_abs = 1, show_msg = FALSE))
})

test_that("qc_raw_abs() doesn't error when facetting by a column with multiple distinct values", {
  # this only checks that facetting runs without error when several
  # facet values are present - it does NOT check that the resulting
  # number of facets is correct; that's checked visually instead, see
  # the "facetting" example in qc_raw_abs()'s own roxygen documentation
  data <- tidy_plates |>
    dplyr::mutate(dataset = rep(c("A", "B", "C"), length.out = dplyr::n()))

  expect_no_error(
    qc_raw_abs(data, plot_col_facet = "dataset", show_plot = FALSE, export_plot = "p3",
               min_abs = 0, max_abs = 1, show_msg = FALSE))
})


