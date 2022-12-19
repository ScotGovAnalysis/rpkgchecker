test_that("Tibble created from available.packages", {
  expect_true(tibble::is_tibble(available_packages_tb()))
})

test_that("Output tibble has most important column names", {
  needed_cols <- c("package", "imports", "depends", "version", "repository")
  found_cols <- intersect(colnames(available_packages_tb()), needed_cols)
  expect_true(setequal(needed_cols, found_cols))
})
