## code to prepare `std_corrected` dataset goes here

usethis::use_data(std_corrected, overwrite = TRUE)

# join raw data (supposedly clean, but for example purposes ok) and metadata
raw_meta <- tidy_plates |> dplyr::left_join(metadata, by = dplyr::join_by(plate_id))

# extract std_data
std_data <- raw_meta |>
  extract_std_data() |>
  select(!std_conc) |>
  left_join(
    curve_concentration = extract_curve(metadata),
    by = join_by(row, plate_id))

std_blank <- raw_meta |> extract_std_blanc()

std_corrected <-
  blank_correct_abs(
    raw_wells_data = std_data |>
      ungroup() |>
      filter_out(row == "A"),
    per_plate_avg_blank = std_blank$average |> rename(blank_avg = blanc_avg),
    map_to_exclude = ""
  )
