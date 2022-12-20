test_that("search requirements works", {
  long_tb <- readRDS(test_path("testdata", "test_long_tb.rds"))
  search_tb <- search_requirements(long_tb, "dplyr")
  expect_true(nrow(search_tb) > 0)
  expect_true(nrow(search_tb) < nrow(long_tb))
})
