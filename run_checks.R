source("R/get_required_packages.R") # filter cleaned
source("R/clean_available_packages.R") # custom function to clean utils::available.packages() df
source("R/check_r_version_required.R")# check version of R is >= to min R required for packages
source("R/get_server_packages.R")
source("R/compare_available_server_packages.R")

# Name of package to search, e.g. tidyr, dplyr, stringr etc
search_package <- "MatchIt"

# Call custom function to get dependent packages R versions from cleaned up copy of utils::available.packages()
package_requirements <- get_required_packages(cleaned_all_package_df = get_cleaned_available_packages(), package_name = search_package)

# Check no packages require R >= the version of R installed
check_r_version_required(package_requirements)

# comparsion with packages on server --------------------------------------

packages_dir <- "//s1428a/R_Packages/R_3_6_3_Packages"

# Get the zip files of R packages on server as tibble
server_packages <- get_server_packages(package_dir)

package_requirements_checked <- compare_available_server_packages(package_requirements, server_packages)

# Write the results to csv
# write_csv(package_requirements, file.path("outputs", paste0(search_package, "_requirements.csv")))
