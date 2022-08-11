
compare_available_server_packages <- function(required_packages_df, server_packages_df) {
  # Join required and available by package name then compare versions
  required_packages_df %>%
    left_join(server_packages_df, by = c("package" = "server_package")) %>%
    mutate(min_package_version = str_extract(package_version_required, "\\(([^)]+)\\)")) %>% #get brackets version
    mutate(min_package_version = str_extract(min_package_version, "[0-9\\.]+")) %>% #get version number inside bracket
    mutate(server_status = case_when(
      server_version < min_package_version ~ "server version need upgrading",
      server_version >= min_package_version ~ "server version currently OK",
      is.na(min_package_version) & ! is.na(server_version) ~ "server version currently OK",
      is.na(server_version) ~ "package not currently on server"
    ))
}
