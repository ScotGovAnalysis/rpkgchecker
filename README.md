# Check R Packages
This repository aims to help with R package management under a locked down / secure IT setup where a required package and dependent packages are not allowed to be installed directly from [CRAN]("https://cran.r-project.org/") using `install.packages`. In these situations it is also common to be using an older version of R. 

## How this code helps
By specifying the name of a package wish to acquire, this code helps by finding all of the dependent packages, the minimum required version of the dependent packages, and the minimum R version that they work with. Currently this is done by reformatting and then recursively querying `utils::available.packages()` as follows:
```r
utils::available.packages(repos="http://cran.r-project.org", filters=c("duplicates"), ignore_repo_cache = TRUE)
```

In these locked down environments, a repository of permitted R packages is typically maintained on an internal server. Code in this repo is used to extract existing package names and their versions from an input folder of `.zip` or `.tar.gz` R packages. This can then be compared with the required package analysis, to produce a final list of requirements by name and their link on CRAN.

## How to run
It is recommended to use the script `create_rpackage_report.R` to generate and display an R Markdown html report for a package of interest. Set the `search_package` variable to the package of interest. The resulting html report is written to `outputs` and can be viewed in a browser (see screenshot below.)  
Example output of R Markdown html report: 

![Alt text](/images/example_output.png?raw=true "Example Output")