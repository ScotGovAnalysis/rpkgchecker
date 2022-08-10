get_server_packages <- function(server_package_dir) {
  server_packages <- list.files(server_package_dir, pattern = "*") %>%
    as_tibble() %>%
    rename(server_file_name = value)

  # Clean server packages
  server_packages <- server_packages %>%
    separate(server_file_name, sep = "_", into = c("server_package", "server_version"), extra = "merge", fill = "right", remove = TRUE) %>%
    mutate(
      server_version = str_replace_all(server_version, "-", "."),
      server_version = str_replace_all(server_version, ".zip", "")
    )
  return(server_packages)
}
