library(tibble)
library(dplyr)
library(tidyr)
library(stringr)
library(readr)

#' Clean and reformat the utils::available.packages() dataframe.
#'
#' @return Cleaned tibble
#' @export
#'
get_cleaned_available_packages <- function() {
  available_packages <- available.packages(repos="http://cran.rstudio.com") %>%
    # Make a tibble from df
    as_tibble() %>%
    # Make column names lower case
    rename_all(., .funs = tolower) %>%
    # Add url for package home page
    mutate(package_url = paste0("https://cran.r-project.org/web/packages/", package, "/index.html")) %>%
    # Select relevant columns
    select(package, version, package_url, depends, imports) %>%
    # Only interested in depends and imports packages - make these long format
    pivot_longer(cols = c(depends, imports), names_to = "requirement_type", values_to = "dependencies") %>%
    # Remove newline characters
    mutate(dependencies = str_remove_all(dependencies, "\\n")) %>%
    # Different package dependencies on new rows
    separate_rows(dependencies, sep = ",") %>%
    # Remove spaces
    mutate(dependencies = str_remove_all(dependencies, "\\s")) %>%
    # Split package name from required version if specified into separate columns
    separate(dependencies, sep = "\\(", into = c("dep_package", "dep_version"), remove = FALSE, extra = "merge", fill = "right") %>%
    # Split package version from >= comparator into separate columns
    separate(dep_version, sep = "(?=\\d)", into = c("dep_comparator", "dep_version"), remove = TRUE, extra = "merge", fill = "right") %>%
    # Remove the trailing bracket from the version and replace = with . in version numbers
    mutate(dep_version = str_replace_all(dep_version, "\\)", ""), dep_version = str_replace_all(dep_version, "-", "\\."))
  return(available_packages)
}