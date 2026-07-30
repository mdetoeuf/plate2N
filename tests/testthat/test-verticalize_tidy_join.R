# TEST join_abs_map() -------------------------------------------------------

test_that("join_abs_map() returns a tibble", {
  expect_true(
    "tbl" %in% class(
      join_abs_map(
        tibble_list = list(tibble_example, tibble_example),
        abs_map = c("abs-", "map-"))
    )
  )
})

test_that("join_abs_map() accepts a pre-matched coerce_numeric vector", {
  expect_no_error(
    join_abs_map(
      tibble_list = list(tibble_example, tibble_example),
      abs_map = c("abs-", "map-"),
      coerce_numeric = c(FALSE, FALSE))
  )
})

test_that("join_abs_map() still works with a single recycled coerce_numeric value", {
  expect_no_error(
    join_abs_map(
      tibble_list = list(tibble_example, tibble_example),
      abs_map = c("abs-", "map-"),
      coerce_numeric = FALSE)
  )
})
