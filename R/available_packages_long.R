#' Available Packages Long Format
#'
#' This creates a tidy format tibble of package dependencies (depends, imports).
#'
#' @param cran_repo_url The url of the CRAN repository to check.
#'
#' @return Tibble of packages restructured in long format with one row per
#' imports or depends package.
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' available_packages_long()
available_packages_long <- function(cran_repo_url = "win_binary_default") {
  available_packages_tb(cran_repo_url = "win_binary_default") %>%
    # Make column names lower case
    dplyr::rename_with(.fn = tolower) %>%
    # Download link col
    dplyr::mutate(package_url = paste0(.data$repository, "/", .data$package, ".zip")) %>%
    # Select relevant columns
    dplyr::select(.data$package, .data$version, .data$package_url, .data$depends, .data$imports) %>%
    # Clean version column so no - only . for comparison queries
    dplyr::mutate(version=stringr::str_replace_all(.data$version, "-", ".")) %>%
    # Only interested in depends and imports packages - make these long format
    tidyr::pivot_longer(
      cols = c(.data$depends, .data$imports),
      names_to = "requirement_type",
      values_to = "dependencies"
    ) %>% # Remove newline characters
    dplyr::mutate(
      dependencies =
        stringr::str_remove_all(.data$dependencies, "\\n")
    ) %>%
    # Different package dependencies on new rows
    tidyr::separate_rows(.data$dependencies, sep = ",") %>%
    # Remove spaces
    dplyr::mutate(
      dependencies =
        stringr::str_remove_all(.data$dependencies, "\\s")
    ) %>%
    # Split package name from required version into separate columns
    tidyr::separate(.data$dependencies,
      sep = "\\(", into = c("dep_package", "dep_version"),
      remove = FALSE,
      extra = "merge",
      fill = "right"
    ) %>% # Split package version from >= comparator into separate columns
    tidyr::separate(
      .data$dep_version,
      sep = "(?=\\d)",
      into = c("dep_comparator", "dep_version"),
      remove = TRUE,
      extra = "merge",
      fill = "right"
    ) %>%
    # Remove the trailing bracket from the version and replace = with .

    # in version numbers
    dplyr::mutate(
      dep_version = stringr::str_replace_all(.data$dep_version, "\\)", ""),
      dep_version = stringr::str_replace_all(.data$dep_version, "-", "\\.")
    )
}
