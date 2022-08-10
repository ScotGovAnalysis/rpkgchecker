library(crayon)
check_r_version_required <- function(package_requirements_df) {
  # extract R version from column
  r_requirements <- package_requirements_df %>%
    separate(r_version, sep = "\\(", into = c("r", "r_install_version"), remove = FALSE, extra = "merge", fill = "right") %>%
    separate(r_install_version, sep = "(?=\\d)", into = c("r_comparator", "r_install_version"), remove = TRUE, extra = "merge", fill = "right") %>%
    mutate(r_install_version = str_replace_all(r_install_version, "\\)", ""))
  r_current_version <- paste0(R.Version()$major, ".", R.Version()$minor)
  exceed_version <- r_requirements %>% filter(r_install_version > r_current_version)
  if (nrow(exceed_version) > 0) {
    return(exceed_version)
  }
  else {
    return(FALSE)
  }
}
