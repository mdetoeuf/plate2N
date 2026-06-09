tidy_2_extr <- tidy_plates |>
    dplyr::mutate(
      map = dplyr::case_when(
        column == 8 ~ "extr_1",
        column == 4 ~ "extr_2",
        .default = map))

multiple_extractant_id # check it out
# joining with multiple_extractant_id
(dbl_extr_plate <- tidy_2_extr |> dplyr::left_join(multiple_extractant_id))


usethis::use_data(dbl_extr_plate, overwrite = TRUE)
