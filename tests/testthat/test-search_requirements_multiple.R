test_that("search multiple works", {
  long_tb <- readRDS(test_path("testdata", "test_long_tb.rds"))
  search_tb <- search_requirements(long_tb, "stringr")
  search_multiple_tb <- search_requirements_multiple(
    long_tb,
    c("stringr", "sf")
  )
  expect_true((nrow(search_tb) > 0) & (nrow(search_multiple_tb) > 0))
  expect_true(nrow(search_tb) < nrow(search_multiple_tb))
})
