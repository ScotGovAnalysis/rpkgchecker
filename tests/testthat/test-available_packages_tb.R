test_that("Tibble created from available.packages", {
  test_tb <- readRDS(test_path("testdata", "test_tb.rds"))
  expect_true(tibble::is_tibble(test_tb))
})

test_that("Output tibble has most important column names", {
  needed_cols <- c("package", "imports", "depends", "version", "repository")
  found_cols <- intersect(colnames(test_tb), needed_cols)
  expect_true(setequal(needed_cols, found_cols))
})
