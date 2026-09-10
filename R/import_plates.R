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



# store column names
columns <- readr::read_csv(I("row,1,2,3,4,5,6,7,8,9,10,11,12"), col_names = FALSE,
                           col_types = readr::cols(.default = readr::col_character()))
names(columns) <- c("row", "X1", "X2", "X3", "X4", "X5", "X6", "X7", "X8", "X9", "X10", "X11", "X12")



#** Then, import functions*

#' Imports 96-well plate data from .TXT format as exported from the plate reader
#'
#' @param filepath The path to the folder containing the .TXT files. The folder
#'     may contain other non-TXT files, but all .TXT files within the folder will be included.
#' @param extension The default is ".TXT". This parameter defines the pattern by which files to be included will be picked from the folder identified by 'filepath'.
#' @param output Desired output format. Default "tibble." Alternative option is a list (one element of the list attributed to each plate)
#'
#' @import dplyr readr stringr tidyr
#'
#' @returns Depends on the output parameter.
#'          If `output = "tibble"`, a tibble where each plate is stacked on top of each other (same format as with skanit_to_plate())
#'          If `output = "list"`, a list where each element is a tibble corresponding to raw plate data (1 file --> 1 plate --> 1 element). Names of the elements correspond to the names of the files (without the extension .TXT). A good practice is thus to name the files as "plate_name.TXT"
#' @export
#'
#' @examples
#' filepath <- system.file("extdata", "txt_examples/", package = "plate2N")
#' abs_tibble <- txt_to_tibble(filepath)
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

  for (i in seq_along(all_txt_files)) {

    # get name of file nb i
    file <- paste0(filepath, "/", all_txt_files[i])

    # store plate id in a variable
    plate_id <- stringr::str_extract(all_txt_files[i], pattern = "(.*)\\.TXT$", group = 1)

    # initiate headers
    plate_header <- columns |>
      dplyr::mutate(row = plate_id, .before = 1)

    # extract only absorbance data from file to exploit as a tibble
    plate_abs <-
      readr::read_tsv(file, col_names = TRUE, skip = 5, show_col_types = FALSE, name_repair = "unique_quiet", col_types = readr::cols(.default = readr::col_character())) |>
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
    file <- file[seq_len(nrow(file) - 1), ]
  }


  # extract first column
  file_col1 <- file[[1]]

  if (length(file_col1) < 3) {
    stop("The imported file does not contain enough rows to represent even one plate (a minimum of 9 rows is expected: a plate-id row plus rows A-H). Check the file's structure and import.")
    }

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
  for (i in seq_along(nrow_sample)){
    seq <- append(seq,seq(nrow_sample[i],nrow_sample[i]+8,1))
  }

  # subset of the file with all mapping elements
  anti_file <- file_plate_ids |> dplyr::slice(seq)

  # complementary of that subset = absorbance data
  clean_file <- dplyr::anti_join(
    file_plate_ids, anti_file,
    by = dplyr::join_by(row, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12))

  # If numbers formatted with commas, replace them with dots
  if (clean_file$X1[2] |> stringr::str_extract(pattern = "\\W") == ",") {
    for (i in seq_len(ncol(clean_file))) {
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



#' Import single plate data from a single Tecan-generated file
#'
#' @param file (path to) file to import from
#' @param extension ".xlsx" is currently the only option, but this might change based on user needs
#'
#' @importFrom readxl read_excel
#' @importFrom stringr str_extract
#'
#' @returns A tibble with a single plate
#'
#' @export
#'
#' @examples
#' file <- system.file("extdata", "tecan_example/tecan1.xlsx", package = "plate2N")
#' read_tecan(file)
read_tecan <- function(
    file,
    extension = ".xlsx"
) {

  # extract plate_id from file name
  # If file was given as filepath, then extract last part = file
  if (!is.na(stringr::str_extract(file, "/"))) {
    plate_id <- file |> stringr::str_extract(pattern = paste0("(.*)(/)(.*)(",extension,")"), group = 3)
  } else {
    plate_id <- file
  }

  # import raw tibble
  tibble <- readxl::read_excel(file, skip = 30, n_max = 11, col_types = "text")
  names(tibble) <- names(columns)

  tibble <- columns |> dplyr::bind_rows(tibble)
  tibble[1,1] <- plate_id

  return(tibble)
}



#' Import plate data from a Tecan-generated .xlsx file
#'
#' @param folderpath Path to the folder that contains all .xlsx in the "Tecan"
#'     output format. Make sure that folder contains only plate data as .xlsx files.
#'     It may contain other file types, but all .xlsx files will be imported, which
#'     could lead to errors should the files not present the correct structure
#' @param extension For now has only 1 .xlsx option. Should it be relevant to add
#'     a csv option, please reach out to the authors.
#'
#' @returns The plate data in a tibble format
#' @export
#'
#' @import dplyr stringr
#'
#' @examples
#' filepath <- system.file("extdata", "tecan_example/", package = "plate2N")
#' tecan_to_tibble(filepath)
#'
tecan_to_tibble <- function(
    folderpath,
    extension = ".xlsx"
) {

    # obtain list of plate files in the filepath
    all_tecan_files <- list.files(
      paste0(folderpath, "/"),
      pattern = extension,
      full.names = FALSE)

    # in a loop: extract each plate and append the list
    # (1 file --> 1 plate --> 1 element of the list)

    # initiate empty tibble
    tibble <- columns |> dplyr::filter(row != "row")

# use read_tecan() to append the empty tibble in a loop, 1 iteration per file
    for (i in seq_along(all_tecan_files)) {
      file <- all_tecan_files[i]
      path <- paste0(folderpath, "/", file)
      tibble_i <- read_tecan(path)
      tibble <- tibble |> dplyr::bind_rows(tibble_i)
    }

return(tibble)

}


#' Automatically detect and extract 96-well plate layouts from a raw data file
#'
#' Scans a file column by column, looking for the signature shape of a
#' 96-well plate: eight consecutive rows reading `"A"` through `"H"`,
#' with the row immediately above holding `1` through `12` across the
#' next 12 columns. Once found, that block (the anchor cell plus 8 rows
#' and 12 columns) is extracted as one plate; scanning then continues
#' down the same column for further plates stacked below, before moving
#' to the next column. Useful for files that don't follow one of the
#' package's other fixed import formats.
#'
#' **Only complete plates are detected** — a broken or partial `A`-`H`
#' or `1`-`12` run (e.g. a missing row) will not be recognized, and
#' that data will simply be skipped rather than flagged.
#'
#' @param filepath Path to the file to scan.
#' @param format One of `"csv"`, `"csv2"`, `"xlsx"`, or `"txt"`. If `NULL`
#'     (the default), guessed from the file extension for `.xlsx`/`.txt`.
#'     A `.csv` extension defaults to `"csv"` (comma-delimited) with a
#'     warning, since the extension alone can't distinguish it from a
#'     semicolon-delimited ("French locale") file — pass `format = "csv"`
#'     explicitly to silence the warning, or `format = "csv2"` if that's
#'     actually what you have.
#' @param delim Delimiter used when `format = "txt"`. Defaults to `"\t"`.
#' @param skip,comment Passed through to the underlying reader
#'     (`readr::read_csv()`/`read_csv2()`/`read_delim()`, or
#'     `readxl::read_excel()` for `skip` only). `comment` is not
#'     supported for `format = "xlsx"` — `readxl` has no comment-
#'     skipping option, and passing a non-empty `comment` with
#'     `format = "xlsx"` errors rather than being silently ignored.
#' @param col_select Optionally restrict which columns of the raw file
#'     are scanned (e.g. if you know plate data only appears in a
#'     certain range). Defaults to `NULL` (scan every column). For
#'     `format = "xlsx"`, this expects column *positions* (a numeric
#'     vector), not names or `tidyselect` helpers — simpler than
#'     `readr`'s own `col_select`, which does accept full `tidyselect`
#'     syntax for the other formats.
#' @param plate_id_in_anchor If `TRUE` (the default), each plate's ID is
#'     read from its anchor cell (the cell just above `"A"` and left of
#'     `"1"`). If `FALSE`, IDs come from `plate_ids` if given, or are
#'     auto-generated otherwise (`"plate1"`, `"plate2"`, ..., zero-padded
#'     to match however many plates are found in total).
#' @param plate_ids Optional character vector of plate IDs, used only
#'     when `plate_id_in_anchor = FALSE`, applied in the order plates
#'     are found (column by column, top to bottom). If its length
#'     doesn't match the number of plates actually found, a warning is
#'     issued (possibly indicating an incomplete/misaligned plate
#'     layout) and the vector is recycled/truncated to fit.
#' @param case_sensitive Whether `"A"`-`"H"` must match case exactly.
#'     Defaults to `TRUE`.
#' @param trim_whitespace Whether to trim leading/trailing whitespace
#'     before comparing cells. Defaults to `TRUE`.
#' @param output Either `"tibble"` (all plates stacked, default) or
#'     `"list"` (one named element per plate) — same convention as
#'     [txt_to_tibble()].
#'
#' @returns Depends on `output`, matching [txt_to_tibble()]'s own
#'     convention.
#' @section Numeric precision:
#' Values are read and returned as character strings, matching the
#' rest of the package's import functions. For `.xlsx` files
#' specifically, this can occasionally surface long floating-point
#' artifacts (e.g. `"0.31830000000000003"` instead of the displayed
#' `"0.3183"`) — a known `readxl` quirk when reading numeric cells as
#' text, not something this function rounds or otherwise adjusts. If
#' this matters for your data, round explicitly downstream.
#'
#' @export
#'
#' @examples
#' filepath <- system.file("extdata", "tecan_example/tecan1.xlsx", package = "plate2N")
#' auto_to_tibble(filepath)
auto_to_tibble <- function(
    filepath,
    format = NULL,
    delim = "\t",
    skip = 0,
    comment = "",
    col_select = NULL,
    plate_id_in_anchor = TRUE,
    plate_ids = NULL,
    case_sensitive = TRUE,
    trim_whitespace = TRUE,
    output = "tibble"
) {
  # --- read the whole file as a raw, header-less, all-character grid ---
  if (is.null(format)) {
    ext <- tolower(tools::file_ext(filepath))
    format <- switch(ext,
                     "xlsx" = "xlsx", "txt" = "txt", "csv" = "csv",
                     stop(
                       "Could not auto-detect format from file extension '.", ext, "'. ",
                       "Please specify `format` explicitly (one of \"csv\", \"csv2\", \"xlsx\", \"txt\")."))
    if (format == "csv") {
      warning(
        "File has a .csv extension; assuming comma-delimited (format = \"csv\"). ",
        "If your file actually uses semicolons (e.g. a 'French locale' export), ",
        "re-run with format = \"csv2\" instead. ",
        "To silence this warning, pass format = \"csv\" explicitly.")
    }
  }

  grid <- switch(format,
                 "csv" = readr::read_csv(
                   filepath, col_names = FALSE, skip = skip, comment = comment,
                   col_select = col_select, col_types = readr::cols(.default = readr::col_character()),
                   show_col_types = FALSE),
                 "csv2" = readr::read_csv2(
                   filepath, col_names = FALSE, skip = skip, comment = comment,
                   col_select = col_select, col_types = readr::cols(.default = readr::col_character()),
                   show_col_types = FALSE),
                 "txt" = readr::read_delim(
                   filepath, delim = delim, col_names = FALSE, skip = skip, comment = comment,
                   col_select = col_select, col_types = readr::cols(.default = readr::col_character()),
                   show_col_types = FALSE),
                 "xlsx" = {
                   if (!identical(comment, "")) {
                     stop("`comment` is not supported for format = \"xlsx\" (readxl has no comment-skipping option). Remove `comment` or use a different format.", call. = FALSE)
                     }
                   x <- suppressMessages(
                     readxl::read_excel(filepath, col_names = FALSE, skip = skip, col_types = "text"))
                   if (!is.null(col_select)) x <- x[, col_select]
                   x
                 },
                 stop('`format` must be one of "csv", "csv2", "xlsx", "txt", or NULL to auto-detect.'))

  n_rows <- nrow(grid)
  n_cols <- ncol(grid)

  # --- scan for plate blocks: column by column, then row by row ---
  found_blocks <- list()

  for (col in seq_len(n_cols)) {
    row <- 2  # row 1 can never hold "A", since there's no row above it for the anchor
    while (row <= n_rows) {

      matched <- FALSE
      if ((row + 7) <= n_rows && (col + 12) <= n_cols) {
        letter_col <- grid[[col]][row:(row + 7)]
        if (trim_whitespace) letter_col <- trimws(letter_col)
        if (!case_sensitive) letter_col <- toupper(letter_col)

        if (identical(letter_col, LETTERS[1:8])) {
          number_row <- grid[row - 1, (col + 1):(col + 12)] |> unlist() |> unname()
          number_row_numeric <- suppressWarnings(as.numeric(number_row))
          if (!anyNA(number_row_numeric) && identical(number_row_numeric, as.numeric(1:12))) {
            matched <- TRUE
          }
        }
      }

      if (matched) {
        block <- grid[(row - 1):(row + 7), col:(col + 12)]
        names(block) <- names(columns)
        found_blocks[[length(found_blocks) + 1]] <- list(
          data = block, anchor_value = grid[[col]][row - 1])
        row <- row + 9  # skip past this block, keep scanning the same column
      } else {
        row <- row + 1
      }
    }
  }

  n_found <- length(found_blocks)

  if (n_found == 0) {
    warning(
      "No 96-well plate layouts were found in this file. Check that the file ",
      "contains complete A-H / 1-12 blocks, and that `skip`/`format`/`col_select` are set correctly.")
    return(if (output == "tibble") columns[0, ] else list())
  }

  # --- resolve plate IDs ---
  if (plate_id_in_anchor) {
    resolved_ids <- vapply(found_blocks, function(b) as.character(b$anchor_value), character(1))
  } else if (!is.null(plate_ids)) {
    if (length(plate_ids) != n_found) {
      warning(
        length(plate_ids), " plate_ids were provided, but ", n_found,
        " plate layouts were found. This mismatch may indicate an incomplete or ",
        "misaligned plate layout somewhere in the file. Recycling/truncating plate_ids to fit.")
    }
    resolved_ids <- rep(as.character(plate_ids), length.out = n_found)
  } else {
    pad_width <- nchar(as.character(n_found))
    resolved_ids <- paste0("plate", formatC(seq_len(n_found), width = pad_width, flag = "0"))
  }

  # --- assemble output ---
  result_list <- lapply(seq_len(n_found), function(i) {
    block <- found_blocks[[i]]$data
    block[1, 1] <- resolved_ids[i]
    block
  })
  names(result_list) <- resolved_ids

  if (output == "tibble") {
    return(dplyr::bind_rows(result_list))
  } else {
    return(result_list)
  }
}
