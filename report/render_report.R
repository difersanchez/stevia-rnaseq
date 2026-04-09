# -----------------------------------------------------------------------------
# Render the Stevia pathogen detection R Markdown report
#
# Usage:
#   Rscript report/render_report.R /path/to/project SAMPLE_ID
#
# Example:
#   Rscript report/render_report.R "$(pwd)" "V350344566_L01_SE01"
# -----------------------------------------------------------------------------

args <- commandArgs(trailingOnly = TRUE)

project_dir <- ifelse(length(args) >= 1, args[1], ".")
sample <- ifelse(length(args) >= 2, args[2], "V350344566_L01_SE01")

rmarkdown::render(
  input = file.path(project_dir, "report", "report.Rmd"),
  output_file = file.path(
    project_dir,
    "results",
    "report",
    paste0(sample, "_pathogen_report.html")
  ),
  params = list(
    project_dir = project_dir,
    sample = sample
  ),
  envir = new.env(parent = globalenv())
)
