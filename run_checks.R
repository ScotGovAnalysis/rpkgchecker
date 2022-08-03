source("R/get_required_packages.R") # filter cleaned
source("R/clean_available_packages.R") # custom function to clean utils::available.packages() df

# Name of package to search, e.g. tidyr, dplyr, stringr etc
search_package <- "MatchIt"

# Call custom function to get dependent packages R versions from cleaned up copy of utils::available.packages()
package_requirements <- get_required_packages(cleaned_all_package_df = get_cleaned_available_packages(), package_name = search_package)

# Write the results to csv
write_csv(package_requirements, file.path("outputs", paste0(search_package, "_requirements.csv")))
