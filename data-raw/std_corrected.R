## code to prepare `std_corrected` dataset goes here

# join raw data (supposedly clean, but for example purposes ok) and metadata
raw_meta <- tidy_plates |> dplyr::left_join(metadata, by = dplyr::join_by(dataset, plate_id))

# extract std_data
std_data <- raw_meta |>
  extract_std_data() |>
  dplyr::select(!std_conc) |>
  dplyr::left_join(
    extract_curve(metadata), by = dplyr::join_by(row, dataset, plate_id))

std_blank <- raw_meta |> extract_std_blank()

std_corrected <-
  blank_correct_abs(
    raw_wells_data = std_data |>
      ungroup() |>
      filter_out(row == "A"),
    per_plate_avg_blank = std_blank$average |> rename(blank_avg = blank_avg),
    map_to_exclude = ""
  )


usethis::use_data(std_corrected, overwrite = TRUE)
