# First, import and tidy data for TDN
TDN_abs <- csv_to_tibble(system.file("extdata", "TDN_data.csv", package = "plate2N"))

TDN_map <- csv_to_tibble(system.file("extdata", "TDN_maps.csv", package = "plate2N"))

TDN_meta <- readr::read_csv(
  system.file("extdata", "TDN_metadata.csv", package = "plate2N"),
  show_col_types = FALSE) |>
  dplyr::mutate(
    date = as.Date(date, tryFormats = "%d/%m/%Y"),
    dataset = "TDN", .before = plate_id) |>
  dplyr::select(dataset, plate_id, std_sp, std_unit, std_conc, date)


joined_vertical <- join_abs_map(list(TDN_abs, TDN_map), dataset = "TDN-")

tidy_TDN <- vertical_to_tidy(joined_vertical, column_def = c("abs", "map"))

# blank-correct std curves
raw_meta <- tidy_TDN |>
  dplyr::left_join(TDN_meta, by = dplyr::join_by(dataset, plate_id))

curve_concentration <- extract_curve(TDN_meta, pipetting_direction = "top_down")

std_data <- raw_meta |>
  extract_std_data(std_def = "Std") |>
  dplyr::select(!std_conc) |>
  dplyr::left_join(curve_concentration, by = dplyr::join_by(row, dataset, plate_id))

std_blank <- std_data |>
  extract_std_blank(
    std_def = "Std",
    pipetting_direction = "top_down")

std_blank_avg <- std_blank_average(std_blank$trusted)

std_corrected_TDN <-
  blank_correct_abs(
    # ungroup std data, remove rows with the blanks (here: row A)
    raw_wells_data = std_data |>
      dplyr::ungroup() |>
      dplyr::filter_out(row == "A"),
    per_plate_avg_blank = std_blank_avg,
    map_to_exclude = ""
  ) |>
  # only keep relevant columns (remove metadata clutter, optional)
  dplyr::select(row:std_conc)
usethis::use_data(std_corrected_TDN, overwrite = TRUE)
