test_that("long transformation works", {
  input_tb <- readRDS(test_path("testdata", "test_a_package.rds"))
  output_tb <- readRDS(test_path("testdata", "test_long_output.rds"))
  mockery::stub(available_packages_long, "available_packages_tb", input_tb)
  expect_equal(available_packages_long(), output_tb)
})
