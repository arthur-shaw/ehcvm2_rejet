# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "qnr_expr",
    "download_dir"
)

check_exists(objects_needed)

# =============================================================================
# Load necessary libraries
# =============================================================================

library(susoflows)

# =============================================================================
# Fetch data
# =============================================================================

susoflows::download_matching(
    workspace = workspace,
    matches = qnr_expr, 
    export_type = "STATA",
    path = download_dir
)
