generate_rpackage_report <- function(search_package, server_dir) {
  # Set the name of the output html file
  output_html_file <- paste0("package_requirements_", search_package, ".html")

  # Render the existing markdown report, passing in the search package
  # and server directory Save the resulting html in the outputs directory
  rmarkdown::render(file.path("markdown", "package_checks.Rmd"),
    output_file = output_html_file,
    output_dir = "outputs", params = list(
      package_to_check = search_package,
      server_dir = server_dir
    )
  )
}
