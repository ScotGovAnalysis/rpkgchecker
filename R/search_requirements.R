#' @importFrom magrittr %>%
add_dep_packages <- function(packages_long, package_v) {
  # Helper function find any dependent packages not in current input vector of
  # required packages - append them to vector
  dep_packages <-
    packages_long %>%
    dplyr::filter(.data$package %in% package_v) %>%
    dplyr::distinct(.data$dep_package) %>%
    dplyr::filter(.data$dep_package != "R" &
      !.data$dep_package %in% package_v) %>%
    tibble::deframe()
  c(package_v, dep_packages)
}


#' Search for required packages by navigating tree of package dependencies.
#'
#' Packages have requirements on other packages via depends, imports.
#'
#' @param packages_long Tibble of all available packages with dependencies in
#' long format, i.e. output of available_packages_long()
#' @param package_name Name of a specific R package to check
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
#' search_required_packages(
#'   packages_long = available_packages_long(), package_name = "dplyr"
#' )
search_required_packages <- function(packages_long,
                                     package_name,
                                     package_version_number = NA) {
  if ((!(is.na(package_version_number)) & (!stringr::str_detect(package_version_number,
    pattern = "(\\d+)\\.(\\d+)\\.(\\d+)"
  )))) {
    stop(strwrap(paste(
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

  # Create the initial output df - columns on versions and dependencies added
  # to this
  requirements_output <-
    packages_long %>%
    dplyr::filter(.data$package %in% required_packages) %>%
    dplyr::select(.data$package, .data$version, .data$package_url) %>%
    dplyr::rename(cran_repo_version = .data$version) %>%
    dplyr::distinct()

  # Filter the required R dependencies
  r_version <-
    packages_long %>%
    dplyr::filter(.data$package %in% required_packages &
      .data$dep_package == "R") %>%
    dplyr::select(.data$package, .data$dependencies) %>%
    dplyr::rename(r_version = .data$dependencies)
  # Join this to the output
  requirements_output <-
    requirements_output %>% dplyr::left_join(r_version, by = "package")

  # Get other dependent packages aside from R itself and max version of package
  # required where it is a dependent
  dep_versions <-
    packages_long %>%
    dplyr::filter(.data$package %in% required_packages &
      (.data$dep_package != "R") &
      (!is.na(.data$dep_version))) %>%
    dplyr::group_by(.data$dep_package) %>%
    dplyr::summarise(dep_version = max(numeric_version(.data$dep_version))) %>%
    dplyr::mutate(dep_version = as.character(.data$dep_version))


  # Get the max dep package version columns that want, i.e. the dependencies
  # column showing for example 'Rcpp(>=1.0.9)'
  dep_versions <-
    packages_long %>%
    dplyr::filter(.data$package %in% required_packages &
      (.data$dep_package != "R") &
      (!is.na(.data$dep_version))) %>%
    dplyr::inner_join(dep_versions,
      by = c(dep_package = "dep_package", dep_version = "dep_version")
    ) %>%
    dplyr::select(.data$dep_package, .data$dependencies) %>%
    dplyr::rename(package_version_required = .data$dependencies) %>%
    dplyr::distinct(.data$dep_package, .data$package_version_required)

  # Join the version required to the output dataframe
  requirements_output <-
    requirements_output %>% dplyr::left_join(dep_versions,
      by = c(package = "dep_package")
    )

  # check that search package version is available
  pkg_available_version <- requirements_output %>%
    dplyr::filter(.data$package == package_name) %>%
    dplyr::pull(.data$cran_repo_version)


  # warn if search version != available version
  if (!is.na(package_version_number) &
    (pkg_available_version != package_version_number)) {
    warning(strwrap(paste(
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
  return(requirements_output)
}
