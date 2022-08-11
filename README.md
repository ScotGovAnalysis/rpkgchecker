# Check R Packages
This repository aims to help with R package management under a locked down / secure IT setup where a required package and dependent packages are not allowed to be installed directly from [CRAN]("https://cran.r-project.org/") using `install.packages`. In these situations it is also common to be using an older version of R. 

## How this code helps
By specifying the name of a package wish to acquire, this code helps by finding all of the dependent packages, the minimum required version of the dependent packages, and the minimum R version that they work with. Currently this is done by reformatting and then recursively querying `utils::available.packages()`.  

In these locked down environments, a repository of permitted R packages is typically maintained on an internal server. Code in this repo can be used to extract existing package names and their versions from an input folder of `.zip` or `.tar.gz` R packages. This can then be compared with the required package analysis, to produce a final list of requirements by name and their link on CRAN.

## How to run
It is recommended to use the script `create_rpackage_report.R` to generate and display an R Markdown html report for a package of interest. Set the `search_package` variable to the package of interest. The resulting html report is written to `outputs` and can be viewed in a browser (see screenshot below.)

```r
# T generate the html rmmarkdown report for a specific package regarding its R version and package dependencies

source("R/clean_available_packages.R")# custom function to clean utils::available.packages() df
source("R/generate_rpackage_report.R")# custom function to generate html report

# Set the name of the package to search
search_package <- "raster"

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

```
![Alt text](/images/example_output.png?raw=true "Example Output")