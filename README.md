# Check R packages
Work in progress. The aim is to help with R package management under a locked down / secure IT setup where a required package and dependent packages are not allowed to be installed directly from [CRAN]("https://cran.r-project.org/") using `install.packages`.  

By specifying the name of a package wish to acquire, this code helps by finding all of the dependent packages, the minimum required version of the dependent packages, and the minimum R version that they work with. Often in these situations the latest version of R will not be available.  

In these locked down environments, a repository of allowed R packages is typically maintained on an internal server. Code in this repo can be used to extract existing package names and their versions from an input folder of `.zip` or `.tar.gz` R packages. This can then be compared with the required package analysis, to produce a final list of requirements by name and their link on CRAN.