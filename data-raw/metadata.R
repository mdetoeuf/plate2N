## code to prepare `metadata` dataset goes here


file <- system.file("extdata", "metadata.csv", package = "plate2N")
metadata <- readr::read_csv(file, show_col_types = FALSE) |>
  dplyr::mutate(dataset = "Nmin", .before = plate_id)
usethis::use_data(metadata, overwrite = TRUE)
