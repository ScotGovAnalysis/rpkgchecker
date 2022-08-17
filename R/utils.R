custom_sort_package_df <- function(target_package, results_df, package_column = "package") {
  # Specify a custom sort order with the input package as the top of the output df and all other packages after
  #package_order <- c(target_package, results_df %>% filter({{ package_column }} != target_package) %>% pull({{ package_column }}))
  package_order <- c(target_package, results_df %>% filter(.data[[package_column]] != target_package) %>% pull({{package_column}})) %>% unique()
  print(package_order)
  results_df %>% arrange(factor(.data[[package_column]], levels = package_order))
}
