## code to prepare `tibble` dataset goes here


example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
(tibble_example <- csv_to_tibble(example_csv))
usethis::use_data(tibble_example, overwrite = TRUE)
