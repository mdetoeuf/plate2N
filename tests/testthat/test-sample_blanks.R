# --- Core behavior (parked for later) ---
# - extractant_average(): single extractant -> one row per plate,
#   correct blank_avg/blank_sdev/blank_coeff_var_percent
#
# --- Edge cases, not yet decided ---
# - extractant_average(): what should happen if a value in extr_def
#   doesn't match anything in the data (e.g. a typo)? Currently
#   produces an empty-but-valid group in the loop iteration - worth
#   deciding whether that should warn/error instead of silently
#   returning fewer rows than expected extractants


# --- Parametrization ---

test_that("extract_extractant() works with a non-default map_col", {
  data <- tidy_plates |> dplyr::rename(mapping = map)
  result <- extract_extractant(data, map_col = "mapping")
  expect_true(all(result$mapping == "extr"))
})

test_that("extractant_average() works with non-default column names", {
  data <- tidy_plates |>
    dplyr::rename(
      dataset_name = dataset, plate = plate_id,
      mapping = map, absorbance = abs)

  result <- extractant_average(
    data, dataset_col = "dataset_name", plate_id_col = "plate",
    map_col = "mapping", value_col = "absorbance")

  expect_true(all(c("blank_avg", "blank_sdev", "blank_coeff_var_percent") %in% names(result)))
  expect_gt(nrow(result), 0)
})

test_that("extractant_average() works with multiple extractants and renamed columns", {
  tidy_2_extr <- tidy_plates |>
    dplyr::mutate(
      map = dplyr::case_when(
        column == 8 ~ "extr_1",
        column == 4 ~ "extr_2",
        .default = map))
  dbl_extr_plate <- tidy_2_extr |> dplyr::left_join(multiple_extractant_id) |>
    dplyr::rename(plate = plate_id, mapping = map)

  result <- extractant_average(
    dbl_extr_plate, extr_def = c("extr_1", "extr_2"),
    plate_id_col = "plate", map_col = "mapping")

  expect_setequal(unique(result$mapping), c("extr_1", "extr_2"))
})

test_that("plot_blank_var_distrib() works with a non-default var_col", {
  extractant_avg <- tidy_plates |> extractant_average() |>
    dplyr::rename(my_cv = blank_coeff_var_percent)

  expect_no_error(plot_blank_var_distrib(extractant_avg, var_col = "my_cv"))
})

# --- Previously blocked, now unblocked: suspicious_extr() end to end ---

test_that("suspicious_extr() works end to end with renamed columns", {
  # this was explicitly blocked in test-qc_raw_extr.R, pending this
  # file's parametrization - also surfaced a real bug (see
  # R/qc_raw_extr.R's suspicious_extr(): internal calls weren't
  # threading plate_id_col/map_col/value_col/dataset_col through)
  data <- tidy_plates |>
    dplyr::rename(
      dataset_name = dataset, plate = plate_id,
      mapping = map, absorbance = abs)

  result <- suspicious_extr(
    data, max_coeff = 0.5,
    dataset_col = "dataset_name", plate_id_col = "plate",
    map_col = "mapping", value_col = "absorbance")

  expect_true(all(c("plate", "mapping", "absorbance") %in% names(result)))
})

