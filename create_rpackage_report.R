# Use this script to generate the html rmmarkdown report for a specific package regarding its R version and package dependencies

source("R/clean_available_packages.R")# custom function to clean utils::available.packages() df
source("R/generate_rpackage_report.R")# custom function to generate html report

# Set the name of the package to search
search_package <- "MatchIt"

# Need to refresh the CRAN package info from utils::available.packages() if not done so today
refresh_all_package_info <- TRUE

# Acquire all package info and write if required
if (refresh_all_package_info) {
  # Call custom function to get cleaned up, long format copy of utils::available.packages()
  cleaned_all_package_df <- get_cleaned_available_packages()
  # Write the cleaned all package df to csv for reuse
  write_csv(cleaned_all_package_df, file.path("outputs", "all_package_requirements.csv"))
}


# Set the server directory to check for existing packages
server_dir <- "//s1428a/R_Packages/R_3_6_3_Packages"

# Call custom function to generate the report
generate_rpackage_report(search_package, server_dir)

# To open the report in browser set the file name for the html that will have been created by above function
output_html_file <- paste0("package_requirements_", search_package, ".html")

# Open the newly created html file in browser
system2("open", file.path("outputs", output_html_file))
