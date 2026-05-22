## code to prepare `abs_corrected` dataset goes here
extractant_average <- tidy_plates |> extractant_average()
sample_corrected <- blank_correct_abs(
  raw_wells_data = tidy_plates,
  per_plate_avg_blank = extractant_average |> dplyr::rename(blank_avg = blank_avg),
  map_to_exclude = c("empty","Std","extr")) |>
  dplyr::left_join(metadata, by = dplyr::join_by(dataset, plate_id))


usethis::use_data(sample_corrected, overwrite = TRUE)

