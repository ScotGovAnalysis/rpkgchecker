get_search_package <- function(request_tb) {
  # Assume already sorted with custom_sort_package_df so search package is 1st
  request_tb %>%
    dplyr::slice(1) %>%
    dplyr::pull(.data$package)
}


#' Export a table as csv file showing required packages and their urls
#'
#' @param compare_tb Tibble output of compare_available_server.
#' @param export_path Directory path where output csv file will be written.
#' @param verify_urls Optional. If TRUE will check each download url exists and
#'                    populate a url_ok column in output with TRUE or FALSE.
#' @param verify_url_proxy Optional. Specify a proxy if needed to check urls.
#'
#' @return Tibble of the exported rows and columns.
#' @export
#'
#' @examples
#' \dontrun{
#' available_long_tb <- available_packages_long()
#' request_tb <- search_requirements(available_long_tb, "fabletools")
#' server_tb <- existing_server_packages("my_server/R_Packages/R_3_6_3_Packages")
#' compare_tb <- compare_available_server(request_tb, server_tb)
#' request_tb <- export_required_packages(compare_tb, "C:/temp")
#' }
export_required_packages <- function(compare_tb,
                                     export_path,
                                     verify_urls = FALSE,
                                     verify_url_proxy = NULL) {

  # Extract the package of interest from top of input tibble
  search_package <- get_search_package(compare_tb)

  # Get rows where package needed or where search package
  request_tb <- compare_tb %>% dplyr::filter((.data$server_status
  != "server version currently OK") | .data$package == search_package)

  # Optionally check urls using RCurl
  if (verify_urls) {
    request_tb <- check_urls(request_tb, "package_url", verify_url_proxy)
  } else {
    request_tb <- request_tb %>% dplyr::mutate(url_ok = "not checked")
  }

  # Select columns wish to include in output
  request_tb <- request_tb %>% dplyr::select(
    .data$package, .data$package_url,
    .data$cran_repo_version, .data$package_version_required,
    .data$server_version, .data$server_status,
    .data$url_ok
  )

  # Rename server version column
  request_tb <- request_tb %>% dplyr::rename(
    current_server_version =
      .data$server_version
  )

  # Output file name
  output_file <- paste0(search_package, "_request_packages.csv")

  # Remove trailing / in output path if exists
  if (stringr::str_sub(export_path, start = -1) == "/") {
    export_path <- stringr::str_sub(export_path, start = 1, end = -1)
  }

  # Create full path for export file and export
  output_fp <- file.path(export_path, output_file)
  readr::write_csv(request_tb, output_fp)

  message(format_message(paste(
    "packages need to request written to",
    output_fp
  )))
  return(request_tb)
}
