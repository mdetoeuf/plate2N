#' Merging 2 vertical plates into one
#'
#' The function `join_abs_map()` was thought to merge absorbance data with their mapping counterparts,
#' coming from 2 separate import occurrences, into a single, vertical tibble.
#' It takes profit of the `dplyr::left_join()` function, connected to our `verticalize_plates()` function,
#' so that it provides a 2-in-1 feature of verticalizing plates while joining them.
#'
#' The first purpose of this function is to join an absorbance tibble and a mapping tibble, which is how the default setup is organized.
#' Still, it offers enough flexibility in its parameters to be adapted to the joining of any 2 tibbles, so long as they fit the proper `tibble_example`-like structure.
#'
#'
#' @param abs_tibble,map_tibble The first and second tibble (will appear on the left and right, respectively). Must have the same structure as `tibble_example`.
#' @param dataset An optional string to be added as a prefix to all column names (from both tibbles), with the exception of the first 2 columns describing well id ("row" and "column"). It is originally meant to record the name of the dataset for later uses.
#' @param abs_map A string vector to add additional prefixes. The default value is set to c("abs", "map"), so that the "abs" data (corresponding to argument `abs_tibble`) will receive the first prefix, and the "map" data (corresponding to argument `map_tibble`) will receive the second prefix. Set this to c("", "") to prevent prefix addition.
#' @param coerce_numeric A logical vector to decide whether the function `verticalize_plates()`, called separately for `abs_tibble` and `map_tibble`, should coerce data to become numeric or not. The default value is set to `c(TRUE, FALSE)`, so that absorbance data will be numerical whereas mapping data will be strings.
#'
#' @returns A unique verticalized table containing the data from both data sets.
#' @seealso [verticalize_plates()]
#' @export
#'
#' @examples
#' skanit_csv <- system.file("extdata", "skanit.csv", package = "plate2N")
#' skanit_tibbles <- skanit_to_tibble(skanit_csv)
#' join_abs_map(skanit_tibbles$abs_tibble, skanit_tibbles$map_tibble)
join_abs_map <- function(
    abs_tibble,
    map_tibble,
    dataset = "",
    abs_map = c("abs", "map"),
    coerce_numeric = c(TRUE, FALSE)
) {
  joined_vertical <- dplyr::left_join(
    verticalize_plates(
      abs_tibble,
      coerce_numeric = coerce_numeric[1],
      prefix = paste0(dataset, abs_map[1])
      ),
    verticalize_plates(
      map_tibble,
      coerce_numeric = coerce_numeric[2],
      prefix = paste0(dataset, abs_map[2])
    )
  )
  return(joined_vertical)
}
