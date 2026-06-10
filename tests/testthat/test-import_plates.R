
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

