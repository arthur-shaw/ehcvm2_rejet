# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "comments",
    "issues",
    "cases_to_review",
    "interview_stats"
)

check_exists(objects_needed)

# =============================================================================
# Make decisions
# =============================================================================

# check for comments
# returns a data frame of cases that contain comments
interviews_with_comments <- susoreview::check_for_comments(
    df_comments = comments, 
    df_issues = issues, 
    df_cases_to_review = cases_to_review
)


# decide what action to take 
decisions <- susoreview::decide_action(
    df_cases_to_review = cases_to_review,
    df_issues = issues_plus_miss_and_suso,
    df_has_comments = interviews_with_comments,
    df_interview_stats = interview_stats
)

# add rejection messages
to_reject <- decisions[["to_reject"]]

to_reject <- susoreview::add_rejection_msgs(
    df_to_reject = to_reject,
    df_issues = issues_plus_miss_and_suso
)

# flag persistent issues
revised_decisions <- susoreview::flag_persistent_issues(
    df_comments = comments,
    df_to_reject = to_reject
)
