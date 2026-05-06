# initiate an empty plate
# create an empty table with NAs
matrix <- matrix(NA, nrow = 8, ncol = 12)
# give it names 1 to 12
colnames(matrix) <- as.character(c(1:12))

# turn it into a tibble and add column with letters
empty_plate <- tibble::as_tibble(matrix) |>
  dplyr::mutate(row = LETTERS[1:8], .before = 1)

# verticalize the empty plate and store in a dataframe
verticalized_empty <- empty_plate |>
  tidyr::pivot_longer(cols = `1`:`12`, names_to = "column", values_to = "abs") |>
  # remove empty column
  dplyr::select(!abs)

##########################################################################

# store column names
columns <- readr::read_csv(I("row,1,2,3,4,5,6,7,8,9,10,11,12"), col_names = FALSE,
                           col_types = readr::cols(.default = readr::col_character()))
names(columns) <- c("row", "X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9", "X10", "X11", "X12")



