custom_sort_package_df <-function(target_package, results_df,
                                  package_column = "package") {
    # Specify a custom sort order with the input package
    # at the top of the output df and all other packages
    package_order <-
      c(
        target_package,
        results_df %>%
          dplyr::filter(.data[[package_column]] != target_package) %>%
          dplyr::pull({{ package_column }})
      ) %>%
      unique()
    print(package_order)
    results_df %>%
      dplyr::arrange(factor(.data[[package_column]], levels = package_order))
  }
