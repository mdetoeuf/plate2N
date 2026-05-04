## code to prepare `tibble` dataset goes here

usethis::use_data(tibble, overwrite = TRUE)

example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
(tibble_example <- csv_to_tibble(example_csv))
