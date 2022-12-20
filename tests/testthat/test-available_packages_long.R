test_that("long transformation works", {
  input_tb <- readRDS(test_path("testdata", "test_tb.rds"))
  mockery::stub(available_packages_long, "available_packages_tb", input_tb)
  output_tb <- available_packages_long()
  input_test <- input_tb[input_tb$package == "dplyr", ]
  output_test <- output_tb[output_tb$package == "dplyr", ]
  expect_true(nrow(output_test) > nrow(input_test))
})
