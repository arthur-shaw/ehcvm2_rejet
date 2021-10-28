# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "combined_dir"
)

check_exists(objects_needed)

# =============================================================================
# Identify cases to review
# =============================================================================

# create cases to review overall
cases_to_review <- haven::read_dta(file = paste0(combined_dir, "EHCVM2_MENAGE_VAGUE1_BFA.dta")) %>%
    # selon le statut SuSo
    dplyr::filter(interview__status %in% statuses_to_reject) %>%
    # selon les données de l'entretien
    dplyr::filter(
        # résultat: achevé
        (s00q08 %in% c(1, 2))
        & 
        # toutes les visites faites
        (visite1 == 1 & visite2 == 2 & visite3 == 3)
    ) %>%
    dplyr::mutate(interview_complete = 1) %>%
    dplyr::select(interview__id, interview__key, interview_complete, interview__status)

# =============================================================================
# Charger les données requises
# =============================================================================

load_filtered <- function(
    dir,
    file,
    name = gsub(pattern = "\\.dta", replacement = "", x = file),
    filter_df
) {
    df <- haven::read_dta(file = paste0(dir, file))
    
    df_filtered <- df %>%
        dplyr::semi_join(filter_df, by = c("interview__id", "interview__key"))
    
    assign(
        x = name,
        value = df_filtered,
        envir = .GlobalEnv
    )
    
}

fichiers <- c(
    "EHCVM2_MENAGE_VAGUE1_BFA.dta", "membres.dta", "filets_securite.dta", "equipements.dta", 
    "interview__errors.dta", "interview__diagnostics.dta", "interview__comments.dta"
)
fichier_noms <- c(
    "menages", "membres", "filets_securite", "equipements", 
    "suso_errors", "suso_diagnostics", "comments"
)

purrr::walk2(
    .x = fichiers, 
    .y = fichier_noms,
    .f = ~ load_filtered(
        dir = combined_dir,
        file = .x,
        name = .y,
        filter_df = cases_to_review
    )
)

# TODO: uncomment once calorie file exists
# purrr::walk(
#     .x = "calories_totales.dta", "calories_par_item.dta",
#     .f = ~ load_filtered(
#         dir = derived_dir,
#         file = .x,
#         filter_df = cases_to_review
#     )
# )
