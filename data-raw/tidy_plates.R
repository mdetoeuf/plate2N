## code to prepare `tidy_plates` dataset goes here

usethis::use_data(tidy_plates, overwrite = TRUE)

map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
map_tibble <- csv_to_tibble(map_file)
abs_tibble <- txt_to_tibble(abs_folder)
joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
tidy_plates <- vertical_to_tidy(joined_vertical)
