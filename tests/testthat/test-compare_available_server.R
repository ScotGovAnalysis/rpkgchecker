test_that("compare server and available works", {
  test_server_tb <- readRDS(test_path("testdata", "test_server_tb.rds"))
  long_tb <- readRDS(test_path("testdata", "test_long_tb.rds"))
  search_tb <- search_requirements(long_tb, "stringr")
  compare_tb <- compare_available_server(search_tb, test_server_tb)

  expect_true(nrow(compare_tb[compare_tb$server_status ==
    "server version need upgrading", ]) >= 1)

  expect_true(nrow(compare_tb[compare_tb$server_status ==
    "package not currently on server", ]) >= 1)
})
