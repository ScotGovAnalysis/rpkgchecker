
# rpkgchecker

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Tools to check R package dependencies, minimum R versions and comparison with internal copy of package install files.

## Installation

Install the package from GitHub with devtools.

``` r
devtools::install_github("tomwilsonsco/rpkgchecker@main")
```

## Example

This shows a possible workflow using the available functions.

``` r
library(rpkgchecker) # load the rpkgchecker package

# get a tibble of available packages with 1 dependent package per row
available_long_tb <- available_packages_long()

# filter to a specific package, here "fabletools"
# this will get all dependencies by querying its dependency tree recursively
required_tb <- search_required_packages(available_long_tb, "fabletools")

# get all packages stored on a shared server as windows binaries
server_tb <- existing_server_packages("//s1428a/R_Packages/R_3_6_3_Packages")

# compare the required packages with those available and indicate which 
# need to be acquired or upgraded
compare_tb <- compare_available_server(required_tb, server_tb)
```

