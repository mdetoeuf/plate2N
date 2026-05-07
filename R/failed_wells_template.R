#' Generate a template to record "failed wells"
#'
#' In experiments with 96-well plates, especially with manual pipetting,
#' it is not rare to have some mishaps where we know that a certain well is to be excluded.
#' The template generated here, once filled by the user with data allowing the identification of failed wells,
#' will allow the automated exclusion of those wells from data analysis.
#' The template can then easily be exported, for example with [`readr::write_csv()`] or [`readr::write_excel_csv()`].
#'
#' @param nrow The desired number of rows. Defaults at `nrow = 30`.
#'             Note that if data is encoded in an Excel or equivalent file, the number of rows is not really important and can be increased indefinitely
#'
#' @importFrom tibble tibble
#'
#' @returns A simple tibble with `nrow` rows and 3 columns: dataset, plate_id and well_id.
#' @export
#'
#' @examples
#' failed_wells_template()
failed_wells_template <- function(
    nrow = 30
) {
  template <- tibble::tibble(
    dataset = rep("", nrow),
    plate_id = rep("", nrow),
    well_id = rep("", nrow)
  )

  return(template)
}
