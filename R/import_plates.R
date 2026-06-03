#** This file contains several import functions and some helpers *
#*
#** First, helpers *
#*

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



#** Then, import functions*

#' Imports 96-well plate data from .TXT format as exported from the plate reader
#'
#' @param filepath The path to the folder containing the .TXT files. The folder may contain other non-TXT files, but all .TXT files within the folder will be included. **Warning:** the only "." allowed in the filename is the one before the TXT extension
#' @param extension The default is ".TXT". This parameter defines the pattern by which files to be included will be picked from the folder identified by 'filepath'.
#' @param output Desired output format. Default is a tibble. Alternative option is a list (one element per plate)
#'
#' @import dplyr readr stringr tidyr
#'
#' @returns Depends on the output parameter.
#'          If `output = "tibble"`, a tibble where each plate is stacked on top of each other (same format as with skanit_to_plate())
#'          If `output = "list"`, a list where each element is a tibble corresponding to raw plate data (1 file --> 1 plate --> 1 element). Names of the elements correspond to the names of the files (without the extension .TXT). A good practice is thus to name the files as "plate_name.TXT"
#' @export
#'

# filepath <- "/Users/Admin/Nextcloud/PhD/2024_trial/Fab_Mo/Red_story/InterBIC_Npools_code/raw_data/Nmin"
# file <- paste0(filepath, "/", "NH4_1F1.TXT")
txt_to_tibble <- function(
    filepath,
    extension = ".TXT",
    output = "tibble") {
  # obtain list of plate files in the filepath
  all_txt_files <- list.files(
    paste0(filepath, "/"),
    pattern = extension,
    full.names = FALSE)

  # in a loop: extract each plate and append the list
  # (1 file --> 1 plate --> 1 element of the list)

  # initiate empty tibble
  tibble <- columns |> dplyr::filter(row != "row")
  # initiate an empty list
  abs_data_list <- list()
  # i = 3
  for (i in 1:length(all_txt_files)) {
    # get name of file nb i
    file <- paste0(filepath, "/", all_txt_files[i])

    # store plate id in a variable
    plate_id <- stringr::str_extract(all_txt_files[i], pattern = "(\\w*)(.)(\\TXT)", group = 1)

    # initiate headers
    plate_header <- columns |>
      dplyr::mutate(row = plate_id, .before = 1)
    #   names(plate_header) <- names(empty_plate)

    # extract only absorbance data from file to exploit as a tibble
    plate_abs <-
      readr::read_tsv(file, col_names = TRUE, skip = 5, show_col_types = FALSE, name_repair = "unique_quiet", col_types = cols(.default = col_character())) |>
      tidyr::drop_na()
    names(plate_abs) <- names(columns)

    if (output == "tibble") {
      # bind headers and plate_abs, then append tibble
      plate_abs <- dplyr::bind_rows(plate_header, plate_abs)
      tibble <- dplyr::bind_rows(tibble, plate_abs)
    } else {
      # save data into the list format
      abs_data_list[[i]] <- plate_abs
      names(abs_data_list)[i] <- plate_id
    }
  }

  if (output == "tibble") {
    return(tibble)
  } else {return(abs_data_list)}
}




#' Import 96-well plate data in csv format
#'
#' Can be either comma-delimited ("normal csv" = default setting) or semi-colon delimited ("French version" with commas used for digits and semi-colons as separators).
#' The format must follow strictly the following structure, and content can be numerical (e.g., absorbance data) or strings (e.g., plate mapping):
#'   - plates must be directly on top of each other (no empty rows between the plates)
#'   - the first plate must be at the top of the document (no empty row above it)
#'   - plates must be at the utmost left of the document (first 13 columns of the sheet)
#'   - No data must be recorded beyond plate data (nothing below the plates or further right)
#'   - the plate name must be in the first cell (top left) of the plate, just above "A", marking the first row of data, and just left of "1", marking the first column of data
#' For csv files that do fit neither this structure nor the "Skanit" structure (see ?skanit_to_plate for more details), an alternative is to use read_csv() or read_csv2 and rearrange the resulting tibble to fit the output given here, so that it can be inputted in the downstream steps.
#'
#' @param filepath The path to the file.
#' @param delim Value separator of the .csv document. Default value is ",". ";" is also accepted.
#'
#' @returns A tibble with the plate data, all plates are still on top of each other (see examples)
#' @export
#'
#' @examples
#' example_csv <- system.file("extdata", "csv_example.csv", package = "plate2N")
#' plate_data <- csv_to_tibble(example_csv)
#' plate_data

csv_to_tibble <- function(
    filepath,
    delim = ","      # alternative is ";"
) {
  # import csv
  if (delim == ",") {
    tibble <-  readr::read_csv(
      filepath,
      col_names = FALSE,
      show_col_types = FALSE)
  } else {
    tibble <-  readr::read_csv2(
      filepath,
      col_names = FALSE,
      show_col_types = FALSE)
  }

  names(tibble) <- names(columns)

  return(tibble)
}




utils::globalVariables(c(
  "row", "X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9", "X10", "X11", "X12"))
#' Import 96-well plate data from Skanit format
#'
#' @param skanit_csv The csv exported from Skanit (or generated from the first
#'     sheet of a Skanit Excel) in its raw shape
#' @param delim The value delimiter within the csv file. Default is ",", accepts also ";".
#' @param suppress_msg Wether to suppress the message received when `delim` is
#'     different than = ",". Defaults to `FALSE`.
#'
#' @import dplyr readr stringr tidyr
#'
#' @returns A list containing 2 elements. The first, called $abs_data contains a tibble with the absorbance data. The second $map_data contains a tibble with the mapping data (only relevant if the mapping has been encoded into skanit. Otherwise: use other functions to import mapping data).
#' @export
#'
#' @examples
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' plate_data <- skanit_to_tibble(skanit_csv, delim = ",")
#' plate_data$abs_tibble
#' plate_data$map_tibble
#'
skanit_to_tibble <- function(
    skanit_csv,
    delim = ",",
    suppress_msg = FALSE
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

    if (!suppress_msg) {
      message(
        "Warning: your csv has values separated by a semi-colon (';') instead of a comma (',').
      This probably means that your numerical data uses the comma instead of the dot as a digit separator.
      Make sure that the conversion to a dot has not changed your data.")
    }

  }

  # correct column names to fit to convention from other *_to_tibble functions
  names(file) <- names(columns)

  # Remove last row if contains something like "Autoloading..."
  if (stringr::str_split_i(file$row[nrow(file)], pattern = " ", i = 1) == "Autoloading") {
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
    dplyr::mutate(row = file_col1) |>
    # remove useless NA rows (where plate id was stored)
    tidyr::drop_na(row)

  # find rownumber where cells contain "Sample" (indicates the start of plate map)
  nrow_sample <- which(file_plate_ids$row == "Sample")

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
    by = dplyr::join_by(row, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12))

  # If numbers formatted with commas, replace them with dots
  if (clean_file$X1[2] |> str_extract(pattern = "\\W") == ",") {
    for (i in 1:ncol(clean_file)) {
      replacement <- gsub("\\,", ".", clean_file[[i]])
      clean_file[i] <- replacement
    }
  }

  # create a map file to export as well
  map_file <- anti_file |>
    dplyr::mutate(row = clean_file$row)

  return(list(
    "abs_tibble" = clean_file,
    "map_tibble" = map_file
  ))
}
