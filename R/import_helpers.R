# initiate an empty plate
# create an empty table with NAs
matrix <- matrix(NA, nrow = 8, ncol = 12)
# give it names 1 to 12
colnames(matrix) <- as.character(c(1:12))

# turn it into a tibble and add column with letters
empty_plate <- tibble::as_tibble(matrix) |>
  dplyr::mutate(row = LETTERS[1:8], .before = 1)

# verticalize and store in a dataframe
abs_longer <- empty_plate |>
  tidyr::pivot_longer(cols = `1`:`12`, names_to = "column", values_to = "abs") |>
  # remove empty column
  dplyr::select(!abs)



