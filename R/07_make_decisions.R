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
    df_issues = issues_plus_miss_and_suso, 
    df_cases_to_review = cases_to_review
)


# decide what action to take 
decisions <- susoreview::decide_action(
    df_cases_to_review = cases_to_review,
    df_issues = issues_plus_miss_and_suso,
    issue_types_to_reject = issues_to_reject,
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

# =============================================================================
# Extract decisions into data representing them
# =============================================================================

# -----------------------------------------------------------------------------
# To reject
# -----------------------------------------------------------------------------

to_reject_ids <- revised_decisions[["to_reject"]] %>%
    dplyr::select(interview__id) %>%
    dplyr::left_join(cases_to_review, by = "interview__id")

to_reject_issues <- to_reject_ids %>%
    dplyr::left_join(
        issues_plus_miss_and_suso, 
        by = c("interview__id", "interview__key")
    ) %>%
    dplyr::filter(issue_type %in% c(issues_to_reject, 2)) %>%
    dplyr::select(
        interview__id, interview__key, interview__status,
        dplyr::starts_with("issue_")
    )

to_reject_api <- revised_decisions[["to_reject"]]

# -----------------------------------------------------------------------------
# To review
# -----------------------------------------------------------------------------

to_review_ids <- decisions[["to_review"]]

to_review_issues <- to_review_ids %>%
    dplyr::left_join(
        issues_plus_miss_and_suso, 
        by = c("interview__id", "interview__key")
    ) %>%
    dplyr::filter(issue_type %in% c(issues_to_reject, 4)) %>%
    dplyr::select(
        interview__id, interview__key, interview__status,
        dplyr::starts_with("issue_")
    )

to_review_api <- susoreview::add_rejection_msgs(
    df_to_reject = decisions[["to_review"]],
    df_issues = issues_plus_miss_and_suso
)

# -----------------------------------------------------------------------------
# To follow up
# -----------------------------------------------------------------------------

to_follow_up_ids <- revised_decisions[["to_follow_up"]] %>%
    dplyr::left_join(cases_to_review, by = "interview__id") %>%
    dplyr::select(interview__id, interview__key)

to_follow_up_issues <- revised_decisions[["to_follow_up"]] %>%
    dplyr::left_join(issues_plus_miss_and_suso, by = "interview__id") %>%
    dplyr::left_join(
        cases_to_review, 
        by = c("interview__id", "interview__key")
    ) %>%
    dplyr::select(
        interview__id, interview__key, interview__status,
        dplyr::starts_with("issue_")
    )

to_follow_up_api <- revised_decisions[["to_follow_up"]]
