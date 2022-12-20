test_tb <- available_packages_tb()

test_long_tb <- available_packages_long()

saveRDS(test_tb, test_path("testdata", "test_tb.rds"))

saveRDS(test_long_tb, test_path("testdata", "test_long_tb.rds"))

withr::defer(unlink(test_path("testdata", "test_tb.rds")), teardown_env())

withr::defer(unlink(test_path("testdata", "test_long_tb.rds")), teardown_env())
