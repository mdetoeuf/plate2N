## code to prepare `vertical_plates` dataset goes here

usethis::use_data(vertical_plates, overwrite = TRUE)

(vertical_plates <- verticalize_plates(tibble_example))
