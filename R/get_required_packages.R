library(tibble)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

add_dep_packages <- function(cleaned_all_package_df, package_v) {
  # find any dependent packages not in current input vector of required packages - append them to vector
  dep_packages <- cleaned_all_package_df %>%
    filter(package %in% package_v) %>%
    distinct(dep_package) %>%
    filter(dep_package != "R" & !dep_package %in% package_v) %>%
    deframe()
  c(package_v, dep_packages)
}


#' Get required packages
#'
#' @param cleaned_all_package_df Expects input of the outout of check-r-packages/R/clean_available_packages.R 
#' @param package_name Name of a specific R package to check
#'
#' @return Tibble showing input package and dependent packages, their minimum R version and minimum package version.
#' @export
#'
#' @examples
#' # Get required packages tibble for dplyr
#' get_required_packages(cleaned_all_package_df = get_cleaned_available_packages(), package_name = "dplyr)
get_required_packages <- function(cleaned_all_package_df, package_name) {
  # Initial vector just has input package
  required_packages <- c(package_name)
  # Recursively add dependent packages to vector
  while (!setequal(required_packages, add_dep_packages(cleaned_all_package_df, required_packages))) {
    required_packages <- add_dep_packages(cleaned_all_package_df, required_packages)
  }
  
  # Create the initial output df - columns on versions and dependencies added to this
  requirements_output <- cleaned_all_package_df %>%
    filter(package %in% required_packages) %>%
    select(package, version, package_url) %>%
    rename(latest_version = version) %>%
    distinct()
  
  # Filter the required R dependencies
  r_version <- cleaned_all_package_df %>%
    filter(package %in% required_packages & dep_package == "R") %>%
    select(package, dependencies) %>%
    rename(r_version = dependencies)
  # Join this to the output
  requirements_output <- requirements_output %>% left_join(r_version, by = "package")
  
  # Get other dependent packages aside from R itself and max version of package required where it is a dependent
  dep_versions <- cleaned_all_package_df %>%
    filter(dep_package %in% required_packages & dep_package != "R" & !is.na(dep_version)) %>%
    group_by(dep_package) %>%
    summarise(dep_version = max(dep_version))
  
  # Get the max dep package version columns that want, i.e. the dependencies column showing for example "Rcpp(>=1.0.9)"
  dep_versions <- cleaned_all_package_df %>%
    select(dep_package, dep_version, dependencies) %>%
    inner_join(dep_versions, by = c("dep_package" = "dep_package", "dep_version" = "dep_version")) %>%
    select(dep_package, dependencies) %>%
    rename(package_version_required = dependencies) %>%
    distinct()
  # Join the version required to the output dataframe
  requirements_output <- requirements_output %>% left_join(dep_versions, by = c("package" = "dep_package"))
  
  # Specify a custom sort order with the input package as the top of the output df and all other packages after
  package_order <- c(package_name, requirements_output %>% filter(package != package_name) %>% pull(package))
  requirements_output <- requirements_output %>% arrange(factor("package", levels = package_order))
  
  return(requirements_output)
}