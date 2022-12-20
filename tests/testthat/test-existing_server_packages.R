test_that("search package zips in dir works", {
  test_dir <- test_path("testdata")
  correct <- tibble::tibble(server_package = "atest", server_version = "1.0.0")
  expect_equal(existing_server_packages(test_dir), correct)
})
