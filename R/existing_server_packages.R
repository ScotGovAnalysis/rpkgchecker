#' Package name and version from a directory of package installs/
#'
#' @param server_package_dir String specifying the directory to search.
#'
#' @return Tibble with columns of package names and package versions.
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' existing_server_packages("//s1428a/R_Packages/R_3_6_3_Packages")
existing_server_packages <- function(server_package_dir) {
  server_packages <- list.files(server_package_dir, pattern = "*") %>%
    tibble::as_tibble() %>%
    dplyr::rename(server_file_name = .data$value)

  # Clean server packages
  server_packages <- server_packages %>%
    tidyr::separate(.data$server_file_name,
      sep = "_", into = c("server_package", "server_version"), extra = "merge",
      fill = "right", remove = TRUE
    ) %>%
    dplyr::mutate(
      server_version =
        stringr::str_replace_all(.data$server_version, "-", "."),
      server_version = stringr::str_replace_all(
        .data$server_version,
        ".zip", ""
      )
    )
  return(server_packages)
}
