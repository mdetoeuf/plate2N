
utils::globalVariables(c("row"))
#' Mapping a Vector with Sample ids into a 96-well Plate Format - Single Plate
#'
#' @details
#' This mapping function always attributes complete columns to standard curves and
#'     blanks. Additional empty columns may be given, optionally.
#'
#' If the list of samples is too short to fill all the wells, remaining empty
#'     wells will be mapped using the character string defined under `empty_def`.
#'
#'
#' @param plate_id The unique identifier of the plate
#' @param samples A vector of strings containing sample names. Samples will be
#'     displayed vertically in the plate (see examples)
#' @param std_def A single string to define wells containing the serial dilutions
#'     of the standard curve. Defaults to "Std"
#' @param column_curves Which columns to map the standard curves to. Can be a
#'     unique string or a vector. Defaults to `c(1,12)`.
#' @param blank_def A single string to define wells containing the blank. Defaults
#'     to `extr` (for "extractant")
#' @param rename_na How to replace NAs found in the sample list. Defaults to "empty",
#'     e.i., the plate map will show "empty" at the corresponding place to where
#'     the function found NAs
#' @param empty_def A single string to define empty wells
#' @param column_empty Optional, which columns to map as empty
#' @param column_blank Which column(s) to map to the blank. Defaults to `8`.
#' @param n_wells_samples How many replicates to attribute to each sample.
#'     Defaults to `4`.
#'
#' @returns A tibble of a single 96-well plate, in plate format, with the plate
#'     id in the top left corner
#' @export
#'
#' @examples
#' (samples <- sample(LETTERS, size = 15))
#' map_1_plate(plate_id = "test_plate", samples = samples)
map_1_plate <- function( #defaults: a whole column (or more) per std or blank
  plate_id, # plate_id = "plate1"
  samples, # samples = sample(LETTERS, size = 18)
  std_def = "Std",
  column_curves = c(1,12),
  blank_def = "extr",
  rename_na = "empty",
  empty_def = "empty",
  column_empty = c(),
  column_blank = 8,
  n_wells_samples = 4
) {

  # # initiate empty plate
  # matrix <- matrix(NA, nrow = 8, ncol = 12)
  # # give it names 1 to 12
  # colnames(matrix) <- paste0("X",(c(1:12)))
  # turn it into a tibble and add column with letters
 # empty_plate <- tibble::as_tibble(matrix) |>
    # dplyr::mutate(row = LETTERS[1:8], .before = 1)

  # compute nb of available wells
  available_wells <-
    96 -
    (length(column_curves) * 8) -
    (length(column_blank) * 8) -
    (length(column_empty) * 8)

  # compute sample capacity
  max_n_samples <- available_wells / n_wells_samples

  # stop + error message if too many samples for available place
  if (length(samples) > max_n_samples) {
    stop("Too many samples given for a single plate.
         Review sample number or plate set up ")
  }

  # fill in std curves
  col_std_names <- paste0(column_curves)
  col_std <- empty_plate |> dplyr::select(tidyselect::all_of(col_std_names))
  for (i in 1:ncol(col_std)) {
    col_std[i] <- rep(std_def)
  }

  # fill in blank wells
  col_blank_names <- paste0(column_blank)
  col_blank <- empty_plate |> dplyr::select(tidyselect::all_of(col_blank_names))
  for (i in 1:ncol(col_blank)) {
    col_blank[i] <- rep(blank_def)
  }

  # fill in empty wells
  if (!is.null(column_empty)) {
    col_empty_names <- paste0(column_empty)
    col_empty <- empty_plate |> dplyr::select(tidyselect::all_of(col_empty_names))
    for (i in 1:ncol(col_empty)) {
      col_empty[i] <- rep(empty_def)
    }
  }

  # start building the plate
  plate <- dplyr::bind_cols(empty_plate |> dplyr::select(row),col_std, col_blank)
  if (exists("col_empty")) {
    plate <- dplyr::bind_cols(plate, col_empty)
  }

  # extract the remaining wells to be occupied by samples
  anti_plate <- empty_plate |> dplyr::select(!names(plate))

  # replace NAs in samples
  na_indices <- which(is.na(samples))
  if (length(na_indices) != 0) {
    samples[na_indices] <- rename_na
  }


  # get the samples replicated as appropriate
  replicated_samples <- lapply(samples, FUN = rep, n_wells_samples) |> unlist()
  n_empty_wells <- available_wells - length(replicated_samples)
  replicated_samples <- append(replicated_samples, rep(empty_def, n_empty_wells))

  # turn replicated samples into a tibble and give them correct column names
  sub_plate_samples <- matrix(replicated_samples, nrow = 8) |>
    tibble::as_tibble(.name_repair = ~ names(anti_plate))

  # create the complete plate and reorder its columns
  plate <- dplyr::bind_cols(plate, sub_plate_samples) |>
    dplyr::relocate(tidyselect::all_of(names(empty_plate)))

  names(plate) <- names(columns)
  # add first row with "column names"
  plate <- columns |> dplyr::bind_rows(plate)

  # add plate_id to it
  plate$row[1] <- plate_id


  return(plate)
}

utils::globalVariables(c("stringr::fruit"))
#' Mapping a Vector with Sample ids into 96-well Plate Format - Several Plates
#'
#' @param samples A vector of strings containing sample names. Samples will be
#'     divided into plates, and displayed vertically (see examples)
#' @param n_samples_per_plate How many samples should be fitted on a single plate.
#'     Defaults to 18, which fits the default settings of `map_1_plate()`.
#' @param plate_ids Optional, a vector of plate_ids to attribute to the plates.
#'     Must be the fitting length. By default, plate ids will be `plate_1`, `plate_2`, etc.
#' @param std_def,column_curves,blank_def,rename_na,empty_def,column_empty,column_blank,n_wells_samples These
#'     parameters are given to a call to `map_1_plate()` and follow its logic.
#'     See also `?map_1_plate()`.
#'
#' @seealso [map_1_plate()]
#'
#' @returns A tibble with the plate mapping, in a format similar to `tibble_example`.
#'     This format also fits the import pipeline. See also the vignette `import-tidy`.
#' @export
#'
#' @examples
#' # take random fruit names as sample names
#' samples <- stringr::fruit[1:70] ; samples[1:5]
#' map_plates(samples, 14) |> print(n = 20)
map_plates <- function(
    samples,
    n_samples_per_plate = 18,
    plate_ids = NULL,
    std_def = "Std",
    column_curves = c(1,12),
    blank_def = "extr",
    rename_na = "empty",
    empty_def = "empty",
    column_empty = c(),
    column_blank = 8,
    n_wells_samples = 4
) {


  # nb of samples and nb of plates
 # n_samples_per_plate <- 14
  (n_plates <- ceiling(length(samples) / n_samples_per_plate))

  # prepare plate ids
  if (is.null(plate_ids)) {
    plate_ids <- paste0("plate_", seq(1:n_plates))
  }

  # divide into smaller vectors
  group_attribution <- seq(1:n_plates) |> rep(n_samples_per_plate) |> sort()
  sample_distribution <- samples |> split(f = group_attribution)


  # initiate empty tibble with correct column names
  tibble <- columns |> filter_out()
  # in a loop, add each plate mapping
  for (plate in 1:length(sample_distribution)) {

    samples_plate <- sample_distribution[[plate]]

    this_plate <- map_1_plate(
      plate_id = plate_ids[plate],
      samples = samples_plate,
      # next parameters are just taken from the function call (transfered to map_1_plate)
      std_def = std_def,
      column_curves = column_curves,
      blank_def = blank_def,
      rename_na = rename_na,
      empty_def = empty_def,
      column_empty = column_empty,
      column_blank = column_blank,
      n_wells_samples = n_wells_samples
      )
    tibble <- dplyr::bind_rows(tibble, this_plate)
  }

  return(tibble)
}


