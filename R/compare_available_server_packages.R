
compare_available_server_packages <- function(required_packages_df, server_packages_df) {
  # Join required and available by package name then compare versions
  required_packages_df %>%
    left_join(server_packages, by = c("package" = "server_package")) %>%
    mutate(min_package_version = str_extract(package_version_required, "[0-9\\.]+")) %>%
    mutate(server_status = case_when(
      server_version < min_package_version ~ "server version need upgrading",
      server_version >= min_package_version ~ "server version currently OK",
      is.na(server_version) ~ "package not currently on server"
    ))
}
