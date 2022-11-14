#' Find all dependencies for multiple input search packages.
#'
#' @param packages_long Tibble of all available packages with dependencies in
#' long format, i.e. output of available_packages_long().
#' @param package_names Vector of package names to search.
#'
#' @return Tibble showing input packages and dependent packages, their minimum R
#' version and minimum package version.
#' @export
#'
#' @examples
#' # Search for all existing packages on a server...
#' # Get existing server packages
#' server_tb <- existing_server_packages("//s1428a/R_Packages/R_3_6_3_Packages")
#' # Search for their requirements by passing the server_package column vector
#' search_requirements_multiple(
#'   packages_long = available_packages_long(),
#'   package_names = server_tb$server_package
#' )
search_requirements_multiple <- function(packages_long, package_names) {

  # Create initial requirements vector
  required_packages <- package_names

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

  # Sort so requested on top
  requirements_output <- custom_sort_package_df(
    package_names,
    requirements_output
  )
  return(requirements_output)
}
