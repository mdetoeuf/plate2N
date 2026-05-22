## code to prepare `metadata` dataset goes here

usethis::use_data(metadata, overwrite = TRUE)

file <- system.file("extdata", "metadata.csv", package = "plate2N")
metadata <- readr::read_csv(file, show_col_types = FALSE) |>
  dplyr::mutate(dataset = "Nmin", .before = plate_id)
