#' Get all available packages as a tibble
#'
#' @param repo_url The url of the CRAN repository to check.
#'
#' @return Tibble of all available packages and details.
#' @export
#'
#' @examples
#' available_packages_tb()
available_packages_tb <- function(cran_repo_url = "win_binary_default") {
  if (cran_repo_url == "win_binary_default") {
    search_url <- contrib.url(repos = "https://cran.r-project.org/", type = "win.binary")
  } else {
    search_url <- cran_repo_url
  }
  available_packages <- available.packages(contriburl = search_url, filters = c("duplicates"), ignore_repo_cache = TRUE)
  tibble::as_tibble(available_packages)
}