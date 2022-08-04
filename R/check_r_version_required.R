library(crayon)
check_r_version_required <- function(package_requirements_df) {
  # extract R version from column
  r_requirements <- package_requirements_df %>%
    separate(r_version, sep = "\\(", into = c("r", "r_install_version"), remove = FALSE, extra = "merge", fill = "right") %>%
    separate(r_install_version, sep = "(?=\\d)", into = c("r_comparator", "r_install_version"), remove = TRUE, extra = "merge", fill = "right") %>%
    mutate(r_install_version = str_replace_all(r_install_version, "\\)", ""))
  r_current_version <- paste0(R.Version()$major, ".", R.Version()$minor)
  exceed_version <- r_requirements %>% filter(r_version > r_current_version)
  print(exceed_version)
  if (nrow(exceed_version) > 0) {
    cat(paste(red("Warning! Current version of R,", r_current_version, "is lower than R version required for latest version of packages:\n")))
    for (i in 1:nrow(exceed_version)) {
      row_show <- paste(exceed_version[i, 1], exceed_version[i, 2], "requires R", exceed_version[i, 6], exceed_version[i, 7])
      cat(red(row_show), "\n")
    }
  }
  else {
    print(paste("R version required for packages is lower or equal to currently installed version,", r_current_version))
  }
}
