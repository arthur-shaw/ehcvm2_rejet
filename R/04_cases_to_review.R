# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "hholds"
)

check_exists(objects_needed)

# =============================================================================
# Identify cases to review
# =============================================================================

# create cases to review overall
cases_to_review <- hholds %>%
    # complete based on SuSo status
    dplyr::filter(interview__status %in% statuses_to_reject) %>%
    # selon les données de l'entretien
    dplyr::filter(
        dplyr::if_any(
            .cols = c(
                complete_aas, complete_unps, 
                complete_single_phase, complete_full_interview
            ),
            .fns = ~ .x == 1
        )
    ) %>%
    dplyr::mutate(interview__complete = 1) %>%
    dplyr::select(
        interview__id, interview__key, interview__status,
        complete_aas, complete_unps, complete_single_phase, complete_full_interview,
        interview__complete
    )

# create sets for filtering attributes
cases_aas <- dplyr::filter(cases_to_review, complete_aas == 1)
cases_unps <- dplyr::filter(cases_to_review, complete_unps == 1)
cases_unoma <- dplyr::filter(cases_to_review, complete_unoma == 1)
cases_single_phase <- dplyr::filter(cases_to_review, complete_single_phase == 1)
cases_full_interview <- dplyr::filter(cases_to_review, complete_full_interview == 1)
