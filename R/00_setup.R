# =============================================================================
# Set file paths
# =============================================================================

# data
data_dir <- paste0(proj_dir, "data/") # /data/
resource_dir <- paste0(data_dir, "00_resource/")  # /00_resource/
download_dir <- paste0(data_dir, "01_downloaded/")  # /01_downloaded/
combined_dir <- paste0(data_dir, "02_combined/")  # /02_combined/
derived_dir <- paste0(data_dir, "03_derived/")   # /03_derived/

# outputs
output_dir <- paste0(proj_dir, "output/")    # /output/


# =============================================================================
# Purge stale data
# =============================================================================

# remove zip files
zips_to_delete <- fs::dir_ls(
    path = download_dir, 
    recurse = FALSE, 
    type = "file", 
    regexp = "\\.zip$"
)
fs::file_delete(zips_to_delete)

# remove unzipped folders and the data they contain
dirs_to_delete <- fs::dir_ls(
    path = download_dir, 
    recurse = FALSE, 
    type = "directory"
)
fs::dir_delete(dirs_to_delete)

# =============================================================================
# Purge stale outputs
# =============================================================================

# remove Excel and Stata files
results_to_delete <- fs::dir_ls(
    path = output_dir, 
    recurse = FALSE, 
    type = "file", 
    regexp = "\\.xlsx$|\\.dta$"
)
fs::file_delete(results_to_delete)
