# helper function
extract_std_data <- function(data, std_def = "Std") {
  std_data <- data |>
    # take only plate-columns with standard curves
    filter(map == std_def) |>
    group_by(dataset, plate_id)
  std_data
}
