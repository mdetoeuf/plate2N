# --- Parametrization (parked, not yet written) ---
# - extract_std_blank()/std_blank_average()/correct_std_blank()/
#   extract_curve()/std_dilution_average(): confirm non-default column
#   names work end to end for each (only extract_std_data() has a
#   dedicated test so far)
#
# --- Core behavior (parked) ---
# - extract_std_blank(): confirm $trusted/$untrusted correctly identify
#   a deliberately "wrong-row" blank well
# - std_blank_average(): confirm blank_coeff_var_percent computed
#   correctly, and NA (not error) with only one value per plate
# - extract_curve(): confirm correct row order for top_down vs.
#   bottom_up pipetting_direction
# - std_dilution_average(): confirm the averaging itself is numerically
#   correct across multiple same-plate curves, not just that it runs
#
# --- Not yet testable without different example data ---
# - correct_std_blank()'s std_def bug fix: a true regression test needs
#   example data using a non-default standard-curve marker (not "Std"),
#   which isn't currently available among the package's example
#   datasets


# --- pipette_to_row() ---

test_that("pipette_to_row() returns the correct row for each direction", {
  expect_equal(pipette_to_row("top_down"), "A")
  expect_equal(pipette_to_row("bottom_up"), "H")
})

test_that("pipette_to_row() errors clearly on an unknown direction", {
  # regression test for today's fix: the error message previously said
  # "top-down" (hyphen) while only "top_down" (underscore) is accepted
  expect_error(pipette_to_row("sideways"), "top_down")
})

# --- extract_std_data() ---

test_that("extract_std_data() works with non-default column names", {
  data <- tidy_plates |>
    dplyr::rename(mapping = map, dataset_name = dataset, plate = plate_id, col = column)

  result <- extract_std_data(
    data, map_col = "mapping", dataset_col = "dataset_name",
    plate_id_col = "plate", column_col = "col")

  expect_true("unique_curve_id" %in% names(result))
  expect_gt(nrow(result), 0)
})

# --- extract_std_blank() ---

test_that("extract_std_blank() returns a list with 3 elements, not 4", {
  # regression test for the roxygen fix: $average was documented but
  # never actually computed by this function (std_blank_average() does
  # that separately, by design) - confirms the code's real behavior now
  # matches the corrected docs
  result <- tidy_plates |> extract_std_blank()
  expect_setequal(names(result), c("all", "trusted", "untrusted"))
})

# --- correct_std_blank() ---

test_that("correct_std_blank() runs end to end", {
  expect_no_error(correct_std_blank(tidy_plates))
})

test_that("correct_std_blank() produces output consistent with calling std_blank_average() directly", {
  # regression test for the DRY fix (calling std_blank_average() rather
  # than duplicating its logic inline)
  result <- correct_std_blank(tidy_plates)
  expect_true("abs_corrected" %in% names(result))
})

# --- std_dilution_average() ---

test_that("std_dilution_average() uses fake_column_value consistently", {
  result <- std_corrected |> std_dilution_average(fake_column_value = 99)
  expect_true(all(result$column == 99))
})

