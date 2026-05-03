utils::globalVariables(c(
  "X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9", "X10", "X11", "X12", "X13"))


#' Import 96-well plate data from Skanit format
#'
#' @param skanit_csv The csv exported from Skanit (or generated from the first sheet of a Skanit Excel) in its raw shape
#' @param delim The value delimiter within the csv file. Default is ",", accepts also ";".
#'
#' @import dplyr readr stringr tidyr
#'
#' @returns A list containing 2 elements. The first, called $abs_data contains the absorbance data. The second $map_data contains the mapping data (only relevant if the mapping has been encoded into skanit. Otherwise: use other functions to import mapping data).
#' @export
#'
#' @examples
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' plate_data <- skanit_to_plate(skanit_csv, delim = ",")
#' plate_data$abs_data
#' plate_data$map_data
#'
skanit_to_plate <- function(
    skanit_csv,
    delim = ","
) {

  if (delim == ",") {
    file <- readr::read_csv(
      skanit_csv,
      comment = "Wavelength",
      skip = 6,
      #skip_empty_rows = TRUE,
      col_names = FALSE,
      show_col_types = FALSE
    ) |>
      tidyr::drop_na(X1)
  } else {
    file <- readr::read_csv2(
      skanit_csv,
      comment = "Wavelength",
      skip = 6,
      #skip_empty_rows = TRUE,
      col_names = FALSE,
      show_col_types = FALSE
    ) |>
      tidyr::drop_na(X1)

    warning(
      "Warning: your csv has values separated by a semi-colon (';') instead of a comma (',').
      This probably means that your numerical data uses the comma instead of the dot as a digit separator.
      This could generate issues in downstream steps, but should not generate errors in this function call.")
  }

  # Remove last row if contains something like "Autoloading..."
  if (stringr::str_split_i(file$X1[nrow(file)], pattern = " ", i = 1) == "Autoloading") {
    file <- file[1:(nrow(file)-1),]
  }

  # extract first column
  file_col1 <- file[[1]]
  #file_col1

  # Replace cells with "Abs" by plate name, then erase original cell containing that plate name
  for (cell in 2:(length(file_col1)-1)) {
    if (file_col1[cell] == "Abs") {
      file_col1[cell] <- file_col1[cell-1]
      file_col1[cell-1] <- NA
    }
  }

  # create new version of file where only absorbance data and map data is kept
  file_plate_ids <- file |>
    dplyr::mutate(X1 = file_col1) |>
    # remove useless NA rows (where plate id was stored)
    tidyr::drop_na(X1)

  # find rownumber where cells contain "Sample" (indicates the start of plate map)
  nrow_sample <- which(file_plate_ids$X1 == "Sample")

  # create a vector with all indices of rows containing map data
  seq <- c()
  for (i in 1:length(nrow_sample)){
    seq <- append(seq,seq(nrow_sample[i],nrow_sample[i]+8,1))
  }
  #seq

  # subset of the file with all mapping elements
  anti_file <- file_plate_ids |> dplyr::slice(seq)

  # complementary of that subset = absorbance data
  clean_file <- dplyr::anti_join(
    file_plate_ids, anti_file,
    by = dplyr::join_by(X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13))

  # create a map file to export as well
  map_file <- anti_file |>
    dplyr::mutate(X1 = clean_file$X1)

  return(list(
    "abs_tibble" = clean_file,
    "map_tibble" = map_file
  ))
}
