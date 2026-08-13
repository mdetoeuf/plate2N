# NOTE: suspicious_extr()'s own plate_id_col/map_col/value_col
# parametrization can't be fully tested end-to-end yet - it always
# calls extract_extractant()/extractant_average() on the raw `data`,
# and those (in sample_blanks.R) still hardcode "map"/"abs"/"plate_id".
# Revisit once that file is parametrized.

# --- Core behavior (parked for later) ---
# - qc_raw_extr(): some plates above threshold -> warning shown,
#   correct plate_id/map combinations returned


# --- Deprecation ---

test_that("multiplot_outlier_extr() is deprecated and errors with a redirect", {
  expect_error(
    multiplot_outlier_extr(),
    "boxplot_outlier_extr")
})

# --- Parametrization ---

test_that("qc_raw_extr() works with non-default plate_id_col/map_col", {
  # bypasses extract_extractant()/extractant_average() (not yet
  # parametrized - deferred to the sample_blanks.R pass) by supplying a
  # pre-computed extractant_average tibble directly, with renamed
  # plate_id/map columns
  extractant_avg <- tibble::tibble(
    plate = c("P01", "P02", "P03"),
    mapping = c("extr", "extr", "extr"),
    blank_coeff_var_percent = c(2, 8, 3))

  result <- qc_raw_extr(
    extractant_average = extractant_avg,
    plate_id_col = "plate", map_col = "mapping",
    max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE)

  expect_equal(result$plate, "P02")
})

test_that("qc_raw_extr() works with a non-default var_col", {
  extractant_avg <- tibble::tibble(
    plate_id = c("P01", "P02"),
    map = c("extr", "extr"),
    my_cv = c(2, 8))

  result <- qc_raw_extr(
    extractant_average = extractant_avg,
    var_col = "my_cv",
    max_coeff = 5, suppress_message = TRUE, suppress_warning = TRUE)

  expect_equal(result$plate_id, "P02")
})

test_that("qc_raw_extr() returns a 0-row tibble (not NULL) when nothing is suspicious", {
  extractant_avg <- tibble::tibble(
    plate_id = c("P01", "P02"),
    map = c("extr", "extr"),
    blank_coeff_var_percent = c(1, 2))

  result <- qc_raw_extr(
    extractant_average = extractant_avg,
    max_coeff = 5, suppress_message = TRUE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("suspicious_extr()'s join isn't disrupted by extra columns in suspicious_extr_per_plate", {
  # regression test for the defensive select() fix - doesn't need
  # renamed columns, so it's fully testable today even though
  # suspicious_extr()'s own column renaming (see note below) isn't yet
  data <- tidy_plates
  suspicious_plate_id <- qc_raw_extr(
    data, max_coeff = 0.5, suppress_message = TRUE, suppress_warning = TRUE)

  suspicious_plate_id_extra <- suspicious_plate_id |>
    dplyr::mutate(notes = "flagged manually")

  result <- suspicious_extr(
    data, max_coeff = 0.5, suspicious_extr_per_plate = suspicious_plate_id_extra)

  expect_true(!"notes" %in% names(result))
  expect_true(!any(grepl("\\.x$|\\.y$", names(result))))
})

