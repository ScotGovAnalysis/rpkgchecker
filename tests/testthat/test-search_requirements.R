test_that("search requirements works", {
  long_tb <- available_packages_long()
  search_tb <- search_requirements(available_long_tb, "dplyr")
  expect_true(nrow(search_tb) > 0)
  expect_true(nrow(search_tb) < nrow(long_tb))
})
