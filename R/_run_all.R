# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "proj_dir"
)

check_exists(objects_needed)

# =============================================================================
# Folders for scripts
# =============================================================================

# scripts
script_dir <- paste0(proj_dir, "R/")

# =============================================================================
# Run scripts in required order
# =============================================================================

# prepare
# - set file paths
# - purge prior data
source(paste0(script_dir, "00_setup.R"))

# get data
# - fetch
source(paste0(script_dir, "01_get_data.R"))

# combine data
# - unpack data
# - combine and save unzipped Stata data
source(paste0(script_dir, "02_combine_data.R"))

# combine food consumption data
# - ingest all food files
# - harmonize variable names in files
# - extract, combine, and apply value labels
source(paste0(script_dir, "03_combine_food.R"))

# identify cases to review
# - create frame of all cases to review
# - create data sets for filtering
source(paste0(script_dir, "04_cases_to_review.R"))

if (nrow(cases_to_review) == 0) {
    warning("Currently no interviews to process that can be rejected")
} else {

# compile attributes
source(paste0(script_dir, "05_compile_attributes.R"))

# compile issues
# - from attributes and microdata
# - from interview metadata
source(paste0(script_dir, "06_compile_issues.R"))

# make decisions
# - what to reject
# - wht to review
source(paste0(script_dir, "07_make_decisions.R"))

# execute decisions
# - post comments to individual questions
# - reject interviews
if (should_reject == TRUE) {
source(paste0(script_dir, "08_execute_decisions.R"))
}

}
