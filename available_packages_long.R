#' Available Packages Long Format
#'
#' This creates a tidy format tibble of package dependencies (depends, imports).
#'
#' @param cran_repo_url The url of the CRAN repository to check.
#'
#' @return Tibble of packages restructured in long format with one row per imports or depends package.
#' @importFrom magrittr %>% 
#' @export
#'
#' @examples
#' available_packages_long()
available_packages_long <- function(cran_repo_url = "win_binary_default") {
  available_packages_tb(cran_repo_url) %>%
    # Make column names lower case
    dplyr::rename_all(., .funs = tolower) %>%
    dplyr::mutate(package_url = paste0(repository, "/", package, ".zip")) %>%
    # Select relevant columns
    dplyr:select(package, version, package_url, depends, imports) %>%
    # Only interested in depends and imports packages - make these long format
    tidyr::pivot_longer(cols = c(depends, imports), names_to = "requirement_type", values_to = "dependencies") %>%
    # Remove newline characters
    dplyr::mutate(dependencies = stringr::str_remove_all(dependencies, "\\n")) %>%
    # Different package dependencies on new rows
    tidyr::separate_rows(dependencies, sep = ",") %>%
    # Remove spaces
    dplyr::mutate(dependencies = stringr::str_remove_all(dependencies, "\\s")) %>%
    # Split package name from required version if specified into separate columns
    tidyr::separate(dependencies, sep = "\\(", into = c("dep_package", "dep_version"), remove = FALSE, extra = "merge", fill = "right") %>%
    # Split package version from >= comparator into separate columns
    tidyr::separate(dep_version, sep = "(?=\\d)", into = c("dep_comparator", "dep_version"), remove = TRUE, extra = "merge", fill = "right") %>%
    # Remove the trailing bracket from the version and replace = with . in version numbers
    dplyr::mutate(dep_version = stringr::str_replace_all(dep_version, "\\)", ""), dep_version = stringr::str_replace_all(dep_version, "-", "\\."))
}
