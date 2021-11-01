# =============================================================================
# Locate project root
# =============================================================================

# follow these guidelines in specifying the root folder
# - use / instead of \ in file path
# - be sure to put / at the end of the path
proj_dir    <- "C:/Users/wb393438/UEMOA/ehcvm2_rejet/"

# =============================================================================
# Questionnaire whose data to review
# =============================================================================

# provide a string that uniquely identifies the questionnaire. this can be:
# - full name
# - sub-string
# - regular expression
qnr_expr <- "EHCVM 2-MENAGE"

# =============================================================================
# Program behavior parameters
# =============================================================================

# Provide a comma-separated list of interview statuses to review.
# See status values here: https://docs.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/#coding_status
# Statuses supported by this script include: 
# - Completed: 100
# - ApprovedBySupervisor: 120
# - ApprovedByHeadquarters: 130
statuses_to_reject <- c(100, 120)

# Provide a comma-separated list of issue types to reject
# {susoreview} uses the following codes:
# - 1 = Reject
# - 2 = Comment to post
# - 3 = Survey Solutions validation error
# - 4 = Review
issues_to_reject <- c(1)

# Whether to reject interviews recommended for rejection
# - If TRUE, the program will instruct the server to reject these interviews.
# - If FALSE, the program will not.
# - In either case, the interviews recommended for rejection, and the reasons why, are saved in `/output/`
should_reject <- TRUE

# =============================================================================
# Load required packages from {renv} lockfile
# =============================================================================

renv::restore()

# =============================================================================
# Provide Survey Solutions details
# =============================================================================

server      <- ""
workspace   <- ""
user        <- ""
password    <- ""

susoapi::set_credentials(
    server = server,
    user = user,
    password = password
)

# =============================================================================
# Confirm that inputs provided
# =============================================================================

#' Check whether the object exists
#' 
#' @param object Character. Name of the object whose existence to check.
#' 
#' @importFrom glue glue
object_exists <- function(object) {
    if(!exists(object)) {
        stop(glue::glue("No object named `{object}` exists. Please provide it above."))
    } 
}

# -----------------------------------------------------------------------------
# Project directory
# -----------------------------------------------------------------------------

object_exists("proj_dir")

dir.exists(proj_dir)

# -----------------------------------------------------------------------------
# Program behavior parameters
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Statuses to reject
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exists
object_exists("statuses_to_reject")

# contains only expected values
allowed_statuses <- c(100, 120, 130)
if (any(!statuses_to_reject %in% allowed_statuses)) {
    stop(
        glue::glue(
            "Unexpected values found in `statuses_to_reject`.",
            "Expected: {allowed_statuses}",
            "Found: {statuses_to_reject}",
            .sep = "\n"
        )
    )
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Statuses to reject
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exists
object_exists("should_reject")

# contains expected values
if (!is.logical(should_reject)) {
    stop(
        glue::glue(
            "Unexpected values found in `should_reject`.",
            "Expected: TRUE/FALSE",
            "Found: {should_reject}",
            .sep = "\n"
        )
    )
}

# -----------------------------------------------------------------------------
# Survey Solutions details
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specified
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

suso_details <- c(
    "server",
    "workspace",
    "user",
    "password"
)

purrr::walk(
    .x = suso_details,
    .f = ~ object_exists(.x)
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Valid
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

susoapi::check_credentials(
    workspace = workspace,
    verbose = TRUE
)

# =============================================================================
# Run scripts
# =============================================================================

# specify script directory
script_dir <- paste0(proj_dir, "R/")

# run logic in logical order
source(paste0(script_dir, "_run_all.R"))
