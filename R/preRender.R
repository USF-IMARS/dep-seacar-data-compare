# # Proceed if rendering the whole project, exit otherwise
if (!nzchar(Sys.getenv("QUARTO_PROJECT_RENDER_ALL"))) {
  quit()
}

# ===========================================================================
# unzip SEACAR files
# ===========================================================================
if (!nzchar(system.file(package = "librarian"))) {
  install.packages("librarian")
}
librarian::shelf(
  glue,
  here,
  utils  
)

input_dir <- here("./data/01-SEACAR_raw")
output_dir <- here("./data/02-SEACAR_unzipped")

# Create the output directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

# List all .zip files in the input directory
zip_files <- list.files(
  input_dir, pattern = "\\.zip$", full.names = TRUE
)

# Loop through each zip file
for (zip_file in zip_files) {
  # Get the base name of the zip file 
  # (without directory and .zip extension)
  zip_name <- tools::file_path_sans_ext(basename(zip_file))
  
  cat(glue("unzipping to {output_dir}/{zip_name}/..."))
  
  # Create a subfolder in the output directory 
  # with the name of the zip file
  unzip_dir <- file.path(output_dir, zip_name)
  if (!dir.exists(unzip_dir)) {
    dir.create(unzip_dir)
  }
  
  # Unzip the file into the created subfolder
  unzip(zip_file, exdir = unzip_dir)
  cat("done.\n")
}

# ===========================================================================
# ===========================================================================
# prepare provider_reports templates
# ===========================================================================
# creates a report template .qmd for each provider data file
if (!nzchar(system.file(package = "librarian"))) {
  install.packages("librarian")
}
librarian::shelf(
  glue,
  here,
  readr,
  whisker  
)

REPORT_TEMPLATE = "provider_reports/provider_report_template.qmd"
REPORTS_DIR = "provider_reports/provider_reports"
DATA_DIR = "data/02-SEACAR_unzipped"

# create the template
templ <- gsub(
    "AOML_WQ_3", "{{provider_id}}", 
  readLines(REPORT_TEMPLATE))

dir.create(REPORTS_DIR, showWarnings=FALSE)

# === iterate through the data structure 
# List all the subdirectories
folders <- list.dirs(
  DATA_DIR, full.names = TRUE, recursive = FALSE
)

# Loop through each folder in the DATA_DIR
for (folder in folders) {
  PROVIDER_ID <- basename(folder)
  print(glue("=== creating template for '{PROVIDER_ID}' ==="))
  # get the metadata from the folder name
  metadata <- data.frame(
    PROVIDER_NAME = sub("_WQ_.*", "", folder),  # Extract the part before _WQ_
    SEACAR_ID = sub(".*_WQ_", "", folder)       # Extract the part after _WQ_
  )

  params = list(
    provider_id = PROVIDER_ID
  )

  writeLines(
    whisker.render(templ, params),
    file.path(REPORTS_DIR, glue("{PROVIDER_ID}.qmd"))
  )
}


# ===========================================================================