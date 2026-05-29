utils::globalVariables(c("well_id", "plate_id", "dataset"))

#' Clean a tidy table from undesired wells
#'
#' This function relies on a very simple use of the `dplyr::anti_join()` function with settings that are particular to our data structure.
#' However, its iterative use in analysis justifies the definition of an ad-hoc function.
#'
#' @param table_to_clean,well_table Tibbles with the same structure, respectively, as [`plate2N::tidy_table`] and [`failed_wells_example`].
#'  Column (dataset, plate_id, well_id) must have strictly the same name, but the order of columns does not matter.
#'  Rows of `well_table` uniquely identify wells to be removed
#'
#' @param show_msg Logical (default to TRUE). Whether to show the message (confirmation that it worked) or warning (that it failed).
#'
#' @import dplyr
#'
#' @returns A cleaned version of the input tidy_table, that should have less rows than the input table (shortened by the number of rows of `well_table`)
#' @export
#'
#' @examples
#' print(tidy_table, n = 10); failed_wells_example
#' tidy_table |> remove_wells(failed_wells_example) |> print(n = 10)
remove_wells <- function(
    table_to_clean,
    well_table, # well_table = failed_wells_example
    show_msg = TRUE
) {
  cleaned_table <- table_to_clean |>
    dplyr::anti_join(
      well_table |> dplyr::filter_out(is.na(well_id)),
      by = join_by(well_id, plate_id, dataset))
  if(show_msg) {
    # QC check that nb of rows removed = nb of rows of failed_wells
    if (
      nrow(well_table) != nrow(table_to_clean) - nrow(cleaned_table)
    ) {
      warning("The loss of rows from this operation does not correspond to the number of rows to remove (i.e., the number of untrusted wells). Manual check required.")
    }
  }

  return(cleaned_table)
}
