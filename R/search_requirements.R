#' Search for required packages by navigating tree of package dependencies.
#'
#' Packages have requirements on other packages via depends, imports.
#'
#' @param packages_long Tibble of all available packages with dependencies in
#' long format, i.e. output of available_packages_long().
#' @param package_name Package name to search.
#' @param package_version_number Optional version number required. Will show a
#' message if available version less than or greater than this.
#'
#' @importFrom rlang .data
#' @importFrom magrittr %>%
#'
#' @return Tibble showing input package and dependent packages, their minimum R
#' version and minimum package version.
#' @export
#'
#' @examples
#' # Get required packages tibble for dplyr
#' search_tb <- search_requirements(
#'   packages_long = available_packages_long(), package_name = "dplyr"
#' )
search_requirements <- function(packages_long,
                                package_name,
                                package_version_number = NA) {
  # Check input OK tibble
  stopifnot(tibble::is_tibble(packages_long),
            "package" %in% colnames(packages_long))

  # Check input package name is in tibble
  if (!package_name %in% packages_long$package) {
    stop(format_message(paste("search package", package_name, "not found in
                       available packages tibble")))
  }
  if ((!(is.na(package_version_number)) & (
    !stringr::str_detect(package_version_number,
      pattern = "(\\d+)\\.(\\d+)\\.(\\d+)"
    )))) {
    stop(format_message(paste(
      package_version_number,
      "is not a valid version number. Set as NA if latest compatible
       version required."
    )))
  }
  # Initial vector just has input package
  required_packages <- c(package_name)
  # Recursively add dependent packages to vector
  while (!setequal(
    required_packages,
    add_dep_packages(packages_long, required_packages)
  )) {
    required_packages <-
      add_dep_packages(packages_long, required_packages)
  }

  # Get the requirements tibble as output
  requirements_output <- requirements_tibble(packages_long, required_packages)

  # check that search package version is available
  pkg_available_version <- requirements_output %>%
    dplyr::filter(.data$package == package_name) %>%
    dplyr::pull(.data$cran_repo_version)


  # warn if search version != available version
  if (!is.na(package_version_number) &
    (pkg_available_version != package_version_number)) {
    warning(format_message(paste(
      package_name, "version", package_version_number,
      "is not available in the CRAN repository searched. Version",
      pkg_available_version, "is available."
    )))
  }

  # Set the search package CRAN version as the required version
  requirements_output <- requirements_output %>%
    dplyr::mutate(package_version_required = dplyr::case_when(
      .data$package == package_name ~ paste0(
        package_name, "(>=",
        pkg_available_version, ")"
      ),
      TRUE ~ package_version_required
    ))

  # Sort tbl so that search package is first row in the output
  requirements_output <- custom_sort_package_df(
    package_name,
    requirements_output
  )
  return(requirements_output)
}
