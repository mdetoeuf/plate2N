## code to prepare `failed_wells` dataset goes here

usethis::use_data(failed_wells_example, overwrite = TRUE)

failed_wells_example <- tibble::tibble(
  dataset = rep("expe1", 2),
  plate_id = c("M16", "M23"),
  well_id = c("A1", "H12")
)
