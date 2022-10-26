library(tibble)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

#' @importFrom magrittr %>%
add_dep_packages <- function(packages_long, package_v) {
  # Helper function find any dependent packages not in current input vector of
  # required packages - append them to vector
  dep_packages <-
    packages_long %>%
    dplyr::filter(package %in% package_v) %>%
    dplyr::distinct(dep_package) %>%
    dplyr::filter(dep_package != "R" &
      !dep_package %in% package_v) %>%
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
#'
#' @return Tibble showing input package and dependent packages, their minimum R
#' version and minimum package version.
#' @export
#'
#' @examples
#' # Get required packages tibble for dplyr
#' get_required_packages(
#'   cleaned_all_package_df =
#'     get_cleaned_available_packages(), package_name = "dplyr"
#' )
search_required_packages <- function(packages_long, package_name) {
  # Initial vector just has input package
  required_packages <- c(package_name)
  # Recursively add dependent packages to vector
  while (!setequal(
    required_packages,
    add_dep_packages(cleaned_all_package_df, required_packages)
  )) {
    required_packages <-
      add_dep_packages(cleaned_all_package_df, required_packages)
  }

  # Create the initial output df - columns on versions and dependencies added
  # to this
  requirements_output <-
    cleaned_all_package_df %>%
    filter(package %in% required_packages) %>%
    select(package, version, package_url) %>%
    rename(latest_version = version) %>%
    distinct()

  # Filter the required R dependencies
  r_version <-
    cleaned_all_package_df %>%
    filter(package %in% required_packages &
      dep_package == "R") %>%
    select(package, dependencies) %>%
    rename(r_version = dependencies)
  # Join this to the output
  requirements_output <-
    requirements_output %>% left_join(r_version, by = "package")

  # Get other dependent packages aside from R itself and max version of package
  # required where it is a dependent
  dep_versions <-
    cleaned_all_package_df %>%
    filter(package %in% required_packages &
      (dep_package != "R") &
      (!is.na(dep_version))) %>%
    group_by(dep_package) %>%
    summarise(dep_version = max(dep_version))


  # Get the max dep package version columns that want, i.e. the dependencies
  # column showing for example 'Rcpp(>=1.0.9)'
  dep_versions <-
    cleaned_all_package_df %>%
    filter(package %in% required_packages &
      (dep_package != "R") &
      (!is.na(dep_version))) %>%
    inner_join(dep_versions,
      by = c(dep_package = "dep_package", dep_version = "dep_version")
    ) %>%
    select(dep_package, dependencies) %>%
    rename(package_version_required = dependencies) %>%
    distinct(dep_package, package_version_required)

  # Join the version required to the output dataframe
  requirements_output <-
    requirements_output %>% left_join(dep_versions,
      by = c(package = "dep_package")
    )

  return(requirements_output)
}
