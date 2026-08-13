# --- txt_to_tibble() ---
# - output = "tibble" vs. "list": confirm both actually produce their
#   documented shape (stacked tibble vs. named list, one element per
#   file)
# - plate_id correctly extracted from filenames (via the .TXT-suffix
#   regex)
# - a non-default extension (e.g. a folder using a different suffix)
#   works and correctly filters which files get picked up
#
# --- csv_to_tibble() ---
# - delim = "," vs. ";" both parse correctly
#
# --- skanit_to_tibble() ---
# - the length(file_col1) < 3 stop() actually fires on a
#   too-short/malformed input (regression test for that guard)
# - the "Autoloading" trailing-row removal actually removes it when
#   present, and doesn't remove anything when absent
# - the "Abs" cell-replacement logic correctly reassigns plate IDs
#   down onto the following row
# - comma-to-dot numeric conversion only triggers when delim = ";",
#   and correctly converts (not just runs without error)
# - suppress_msg = TRUE actually suppresses the semicolon-format
#   message
#
# --- read_tecan() ---
# - plate_id correctly extracted whether file is given as a bare
#   filename or a full path (the two branches of the
#   is.na(str_extract(file, "/")) check)
#
# --- tecan_to_tibble() ---
# - correctly stacks multiple files into one tibble, in a folder with
#   more than one plate
#
# --- Not column-parametrization-related, but worth deciding ---
# - Confirm removing "filepath" from utils::globalVariables() stays
#   clean after a full check() - see note above


# TEST txt_to_tibble() ----------------------------------------------------


test_that("txt_to_tibble() returns a tibble", {
  expect_true(
    "tbl" %in% class(txt_to_tibble(system.file("extdata", "txt_examples/", package = "plate2N"))))
})

test_that("nb of plates is nb of files", {
  expect_equal(
    # nb of plates in output of the function
    txt_to_tibble(system.file("extdata", "txt_examples/", package = "plate2N")) |>
      select(row) |> filter_out(row %in% LETTERS) |> nrow(),
    # nb of input files
    length(list.files(
      paste0(system.file("extdata", "txt_examples/", package = "plate2N"), "/"),
      pattern = ".TXT"))
  )
})

