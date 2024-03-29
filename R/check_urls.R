check_url <- function(url, proxy) {
  !tryCatch(
    {
      httr::http_error(url, httr::use_proxy(proxy))
    },
    error = function(e) {
      TRUE
    }
  )
}


#' Check if urls in a specified column are genuine.
#'
#' A column will be added to the input dataframe "url_ok" with TRUE or FALSE
#' depending on if URL works.
#'
#' @param check_tb Tibble or dataframe with column of urls to check.
#' @param url_column Name of column containing urls to check.
#' @param verify_url_proxy Optionally specify a proxy when on secure network.
#'
#' @return Input tibble or dataframe with url_ok column added.
#' @export
#'
#' @examples
#' \dontrun{
#' search_tb <- search_requirements(
#'   packages_long = available_packages_long(), package_name = "dplyr"
#' )
#' search_tb <- check_urls(search_tb)
#' }
check_urls <- function(check_tb, url_column = "package_url",
                       verify_url_proxy = NULL) {
  request_tb <- check_tb %>%
    dplyr::mutate(url_ok = sapply(
      check_tb[[url_column]],
      check_url,
      verify_url_proxy
    ))
  # If no urls could be verified might mean proxy server needed for check
  not_verified <- request_tb %>% dplyr::filter(.data$url_ok == FALSE)
  if (nrow(not_verified) == nrow(request_tb)) {
    warning(format_message("Could not verify any urls.
                         Check if need to specify proxy."))
  }
  return(request_tb)
}
