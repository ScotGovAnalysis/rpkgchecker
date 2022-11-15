
#' Check installed R version meets minimum for packages.
#'
#' @param required_packages Tibble of required packages.
#'
#' @return Tibble of required packages that require R > existing installed
#' version. Or FALSE if no required packages exceed existing R install version.
#' @export
#'
#' @examples
#' available_long_tb <- available_packages_long()
#' search_tb <- search_requirements(available_long_tb, "fabletools")
#' exceed_r_version <- check_r_version(required_tb)
check_r_version <- function(required_packages) {
  # extract R version from column
  r_requirements <- required_packages %>%
    tidyr::separate(.data$r_version,
      sep = "\\(", into = c("r", "r_install_version"), remove = FALSE, extra = "merge",
      fill = "right"
    ) %>%
    tidyr::separate(.data$r_install_version,
      sep = "(?=\\d)", into = c("r_comparator", "r_install_version"), remove = TRUE, extra = "merge",
      fill = "right"
    ) %>%
    dplyr::mutate(r_install_version = stringr::str_replace_all(.data$r_install_version, "\\)", ""))
  r_current_version <- paste0(R.Version()$major, ".", R.Version()$minor)
  exceed_version <- r_requirements %>% dplyr::filter(.data$r_install_version > r_current_version)
  if (nrow(exceed_version) > 0) {
    return(exceed_version)
  } else {
    return(FALSE)
  }
}
