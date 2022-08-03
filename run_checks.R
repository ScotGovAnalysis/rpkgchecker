source("R/get_required_packages.R")
source("R/clean_available_packages.R")

search_package <- "MatchIt"

package_requirements <- get_required_packages(cleaned_all_package_df = get_cleaned_available_packages(), package_name = search_package)

write_csv(package_requirements, file.path("outputs", paste0(search_package, "_requirements.csv")))
