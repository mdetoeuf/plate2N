#' Imports 96-well plate data from .TXT format as exported from the plate reader
#'
#' @param filepath The path to the folder containing the .TXT files. The folder may contain other non-TXT files, but all .TXT files within the folder will be included. **Warning:** the only "." allowed in the filename is the one before the TXT extension
#' @param extension The default is ".TXT". This parameter defines the pattern by which files to be included will be picked from the folder identified by 'filepath'.
#' @param output Desired output format. Default is a tibble. Alternative option is a list (one element per plate)
#'
#' @returns Depends on the output parameter.
#'          If `output = "tibble"`, a tibble where each plate is stacked on top of each other (same format as with skanit_to_plate())
#'          If `output = "list"`, a list where each element is a tibble corresponding to raw plate data (1 file --> 1 plate --> 1 element). Names of the elements correspond to the names of the files (without the extension .TXT). A good practice is thus to name the files as "plate_name.TXT"
#' @export
#'

# filepath <- "/Users/Admin/Nextcloud/PhD/2024_trial/Fab_Mo/Red_story/InterBIC_Npools_code/raw_data/Nmin"
# file <- paste0(filepath, "/", "NH4_1F1.TXT")
txt_import <- function(
  filepath,
  extension = ".TXT",
  output = "tibble") {
  # obtain list of plate files in the filepath
  all_txt_files <- list.files(
    paste0(filepath, "/"),
    pattern = extension,
    full.names = FALSE)

  # store column names
  columns <- read_csv(I("row,1,2,3,4,5,6,7,8,9,10,11,12"), col_names = FALSE,
                                      col_types = cols(.default = col_character()))
  names(columns) <- columns



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
      mutate(row = plate_id, .before = 1)
 #   names(plate_header) <- names(empty_plate)

    # extract only absorbance data from file to exploit as a tibble
    plate_abs <-
      readr::read_tsv(file, col_names = TRUE, skip = 5, show_col_types = FALSE, name_repair = "unique_quiet", col_types = cols(.default = col_character())) |>
      tidyr::drop_na()
    names(plate_abs) <- names(columns)

    if (output == "tibble") {
      # bind headers and plate_abs, then append tibble
      plate_abs <- bind_rows(plate_header, plate_abs)
      tibble <- bind_rows(tibble, plate_abs)
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

