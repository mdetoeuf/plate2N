## code to prepare `multiple_extractant_id` dataset goes here

# Start from tidy_plates, and replace "extr" by "extr_1", and create "extr_2"
tidy_2_extr <- tidy_plates |>
  dplyr::mutate(
    map = dplyr::case_when(
      column == 8 ~ "extr_1",
      column == 4 ~ "extr_2",
      .default = map),
    extr_id = dplyr::case_when(
      as.double(stringr::str_extract(map, "(\\d)_t1_", group = 1)) < 5 ~ "extr_1",
      map == "Std" ~ "none",
      map %in% c("extr_1", "extr_2") ~ map,
      .default = "extr_2"
    ))
# check it out
tidy_2_extr

# make an equivalence table out of it
multiple_extractant_id <- tidy_2_extr |>
  dplyr::select(dataset, plate_id, map, extr_id) |>
  unique()

usethis::use_data(multiple_extractant_id, overwrite = TRUE)
