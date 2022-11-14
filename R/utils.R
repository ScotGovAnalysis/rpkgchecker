custom_sort_package_df <- function(target_package, results_df,
                                   package_column = "package") {
  # Specify a custom sort order with the input package
  # at the top of the output df and all other packages
  package_order <-
    c(
      target_package,
      results_df %>%
        dplyr::filter(! .data[[package_column]] %in% target_package) %>%
        dplyr::pull({{ package_column }})
    ) %>%
    unique()
  results_df %>%
    dplyr::arrange(factor(.data[[package_column]], levels = package_order))
}


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


requirements_tibble <- function(packages_long, required_packages) {
  # Prepare a requirements tibble checking R and package versions

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
}
