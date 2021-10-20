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

# reject interviews
to_reject <- revised_decisions[["to_reject"]] %>%
    rename(comment = reject_message)

# post comments for interviews to reject
susoreview::post_comments(
    df_to_reject = to_reject,
    df_issues = issues
)

# implement rejection with rejection message
purrr::pwalk(
    .l = to_reject,
    .f = susoreview::reject_interview
)
