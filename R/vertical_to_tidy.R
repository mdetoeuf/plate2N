#' From vertical plate data to tidy data using the tidyr package
#'
#' See also [`vertical_plates`] and [`tidy_table`] to understand input and output data structure
#'
#' @param vertical_data As generated from either [`verticalize_plates()`] or [`join_abs_map()`].
#'
#' @returns A table in a tidy format for downstream analysis
#' @export
#'
#' @examples
#' map_file <- system.file("extdata", "csv_map.csv", package = "plate2N")
#' abs_folder <- system.file("extdata", "txt_examples/", package = "plate2N")
#' map_tibble <- csv_to_tibble(map_file)
#' abs_tibble <- txt_to_tibble(abs_folder)
#' joined_vertical <- join_abs_map(abs_tibble, map_tibble, dataset = "Nmin-")
#' tidy_data <- vertical_to_tidy(joined_vertical)
vertical_to_tidy <- function(
    vertical_data
    ) {
  tidy_data <- vertical_data |>
    pivot_longer(
      cols = !any_of(c("row", "column")),
      names_to = c("dataset", "abs_map", "plate_id"),
      names_sep = "-",
      values_to = "value"
    ) |>
    pivot_wider(
      names_from = "abs_map",
      values_from = "value"
    ) |>
    relocate(map, .before = "abs" ) |>
    mutate(
      well_id = paste0(row, column),
      unique_well_id = paste0(well_id, "_", plate_id),
      .before = 3
    )
}
