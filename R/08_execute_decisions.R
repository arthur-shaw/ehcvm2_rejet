# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "revised_decisions",
    "issues"
)

check_exists(objects_needed)

# =============================================================================
# Execute decisions
# =============================================================================

# post comments for interviews to reject
susoreview::post_comments(
    df_to_reject = to_reject_ids,
    df_issues = to_reject_issues
)

# implement rejection with rejection message
purrr::pwalk(
    .l = to_reject_api,
    .f = susoreview::reject_interview,
    statuses_to_reject = statuses_to_reject,
    workspace = workspace
)
