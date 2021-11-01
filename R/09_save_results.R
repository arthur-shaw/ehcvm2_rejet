# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    # issues and attributes
    "attribs",
    "issues_plus_miss_and_suso",
    # to reject
    "to_reject_ids",
    "to_reject_issues",
    "to_reject_api",
    # to review
    "to_review_ids",
    "to_review_issues",
    "to_review_api"
    # to follow up

)

check_exists(objects_needed)

# =============================================================================
# Write decisions to disk in Excel and Stata format
# =============================================================================

# -----------------------------------------------------------------------------
# Define function
# -----------------------------------------------------------------------------

write_to_excel_and_stata <- function(
    data,
    dir,
    name = deparse(substitute(data))
) {

    # Excel
    writexl::write_xlsx(x = data, path = paste0(dir, name, ".xlsx"), col_names = TRUE)

    # Stata
    haven::write_dta(data = data, path = paste0(dir, name, ".dta"))

}

# -----------------------------------------------------------------------------
# Attributes
# -----------------------------------------------------------------------------

# data
write_to_excel_and_stata(
    data = attribs, 
    dir = output_dir, 
    name = "attributes"
)

# -----------------------------------------------------------------------------
# Issues
# -----------------------------------------------------------------------------

# data
write_to_excel_and_stata(
    data = issues_plus_miss_and_suso, 
    dir = output_dir, 
    name = "issues"
)

# -----------------------------------------------------------------------------
# To reject
# -----------------------------------------------------------------------------

purrr::walk2(
    .x = list(to_reject_ids, to_reject_issues, to_reject_api),
    .y = c("to_reject_ids", "to_reject_issues", "to_reject_api"),
    .f = ~ write_to_excel_and_stata(.x, dir = output_dir, name = .y)
)

# -----------------------------------------------------------------------------
# To review
# -----------------------------------------------------------------------------

purrr::walk2(
    .x = list(to_review_ids, to_review_issues, to_review_api),
    .y = c("to_review_ids", "to_review_issues", "to_review_api"),
    .f = ~ write_to_excel_and_stata(.x, dir = output_dir, name = .y)
)

# -----------------------------------------------------------------------------
# To follow up
# -----------------------------------------------------------------------------

purrr::walk2(
    .x = list(to_follow_up_ids, to_follow_up_issues, to_follow_up_api),
    .y = c("to_follow_up_ids", "to_follow_up_issues", "to_follow_up_api"),
    .f = ~ write_to_excel_and_stata(.x, dir = output_dir, name = .y)
)

