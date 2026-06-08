## code to prepare `tidy_table` dataset goes here


skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")

skanit <- skanit_to_tibble(skanit_csv)

joined_vertical <- join_abs_map(
  skanit$abs_tibble,
  skanit$map_tibble,
  dataset = "expe1-")

too_long <- joined_vertical |>
  tidyr::pivot_longer(
    cols = !any_of(c("row", "column")),
    names_to = c("dataset", "abs_map", "plate_id"),
    names_sep = "-",
    values_to = "value"
  )

tidy_table <- too_long |>
    tidyr::pivot_wider(
      names_from = "abs_map",
      values_from = "value"
    ) |>
    dplyr::relocate(map, .before = "abs" ) |>
    dplyr::mutate(
      well_id = paste0(row, column),
      unique_well_id = paste0(well_id, "_", plate_id),
      .before = 3
    ) |>
    dplyr::relocate(plate_id, .before = "unique_well_id")

usethis::use_data(tidy_table, overwrite = TRUE)
