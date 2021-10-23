# =============================================================================
# Check that necessary objects exist
# =============================================================================

# TODO: change names
objects_needed <- c(
    "attribs",
    # "calories_par_item",
    "suso_errors"
)

check_exists(objects_needed)

# =============================================================================
# Load necessary libraries
# =============================================================================

library(susoreview)
library(haven)
library(purrr)
library(rlang)

# =============================================================================
# Flag errors
# =============================================================================

# -----------------------------------------------------------------------------
# Chef de ménage
# -----------------------------------------------------------------------------

# aucun chef
issue_aucun_chef <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "num_chefs",
    where = num_chefs == 0,
    type = 1,
    desc = "Aucun chef",
    comment = paste0(
        "ERREUR: Aucun membre n'est désigné comme chef. ",
        "Veuillez identifier le membre qui est chef du ménage."
    )
)

# plus de 1 chef
issue_trop_de_chefs <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "num_chefs",
    where = num_chefs > 1,
    type = 1,
    desc = "Aucun chef",
    comment = paste0(
        "ERREUR: Plus d'un membre désigné comme chef du ménage. ",
        "Veuillez identifier le membre qui est chef du ménage."
    )
)

# -----------------------------------------------------------------------------
# Consommation alimentaire
# -----------------------------------------------------------------------------

# aucune consommation alimentaire au sein du ménage
issue_no_home_food_cons <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "repas_a_domicile",
    where = repas_a_domicile == 0,
    type = 1,
    desc = "Aucune consommation alimentaire au ménage",
    comment = paste0(
        "ERREUR: Aucune consommation alimentaire déclarée. ",
        "Le ménage n'a pas consommé des aliments au sein du ménage. ",
        "Ceci est très peu probable. ",
        "Veuillez confirmer à nouveau toutes les questions de la section 7B."
    )
)

# aucune consommation alimentaire--ni au sein ni en dehors du ménage
issue_no_food_cons <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("repas_a_domicile", "repas_dehors_menage", "repas_dehors_membre"),
    where = repas_a_domicile == 0 & repas_dehors_menage == 0 & repas_dehors_membre == 0,
    type = 1,
    desc = "Aucune consommation alimentaire",
    comment = paste0(
        "ERREUR: Aucune consommation alimentaire déclarée. ",
        "Le ménage n'a consommé aucune alimentation--ni au sein ni en dehors du ménage. ",
        "C'est impossible. ",
        "Veuillez confirmer à nouveau la consommation au sein du ménage (7B) et en dehors du ménage (7A)."
    )
)

# -----------------------------------------------------------------------------
# Consommation non-alimentaire
# -----------------------------------------------------------------------------

# aucune consommation non-alimentaire
issue_no_non_food_cons <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("depense_fetes", "depense_7d", "depense_30d", "depense_3m", "depense_6m", "depense_12m"),
    where = (
        depense_fetes == 0 &
        depense_7d == 0 &
        depense_30d == 0 &
        depense_3m == 0 &
        depense_6m == 0 &
        depense_12m == 0         
    ),
    type = 1,
    desc = "Aucune consommation non-alimentaire",
    comment = "ERREUR: Aucune consommation non-alimentaire déclarée (9A à 9F)"
)

# -----------------------------------------------------------------------------
# Calories
# -----------------------------------------------------------------------------

# calories totales trop élevées
issue_calories_tot_high <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "calories_elevees",
    where = calories_elevees == 1,
    type = 1,
    desc = "Calories totales trop élevées",
    comment = paste0(
        "ERREUR: La consommation alimentaire déclarée est trop élevée. ",
        "D'abord, vérifier les quantités et les unités déclarées ",
        "pour chaque produit dans 7B2. ",
        "Ensuite, confirmer que les déclarations concernent la consommation ",
        "et non pas l'acquisition."    
    )
)


# calories totales trop faible
issue_calories_tot_low <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "calories_faibles",
    where = calories_faibles == 1,
    type = 1,
    desc = "Calories totales trop faibles",
    comment = paste0(
        "ERREUR: La consommation alimentaire déclarée est trop faible. ",
        "D'abord, confirmer que tous les produits consommés ont été renseignés. ",
        "Ensuite, vérifier que les quantités et unités de consommation sont correctes"   
    )
)

# calories trop élevées pour un item
issue_calories_item_high <- susoreview::create_issue(
    df_attribs = attribs,
    vars = "calories_elevees_item",
    where = calories_elevees_item == 1,
    type = 1,
    desc = "Calories trop élevées pour un item",
    comment = paste0(
        "ERREUR. Trop de calories tirées d'un seul produit. D'abord, chercher le ",
        "produit avec la plus grande quantité ou la plus grande unité de ",
        "consommation. ",
        "Ensuite, confirmer la consommation de celui-ci."
    )
)

# items pour lesqules les calories sont trop élevées
# produit_codes <- c(
#     "aliment__id %in% c(1:26, 166:169)",
#     "aliment__id %in% c(27:39, 170, 171)",
#     "aliment__id %in% c(40:51, 172, 173)",
#     "aliment__id %in% c(52:60, 174)",
#     "aliment__id %in% c(61:70, 175)",
#     "aliment__id %in% c(71:87, 176)",
#     "aliment__id %in% c(88:108, 177)",
#     "aliment__id %in% c(109:133, 178)",
#     "aliment__id %in% c(134:138)",
#     "aliment__id %in% c(139:154, 179)",
#     "aliment__id %in% c(155:165, 180)"
# )

# produit_noms <- c(
#     "cereales",
#     "viandes",
#     "poissons",
#     "laitier",
#     "huiles",
#     "fruits",
#     "legumes",
#     "legtub",
#     "sucreries",
#     "epices",
#     "boissons"
# )

# issues_where_calories_item_high <- purrr::map2_dfr(
#     .x = produit_codes,
#     .y = produit_noms,
#     .f = susoreview::make_issue_in_roster(
#         df = !!rlang::parse_quo(
#             glue::glue("dplyr::filter(calories_par_item, {.x})"),
#             rlang::global_env()
#         ),
#         where = calories > 1500,
#         roster_vars = aliment__id,
#         type = 2,
#         desc = "Calories trop élevées pour un item",
#         comment = "Calories trop élevées pour cet item",
#         issue_vars = glue::glue("s07Bq03a_{.y}")
#     )
# )

# -----------------------------------------------------------------------------
# Revenu
# -----------------------------------------------------------------------------

# aucun revenu
issue_no_revenue <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c(
        "revenu_emploi",
        "revenu_hors_emploi",
        "num_entreprises",
        "recu_transfert",
        "recu_filet",
        "pratique_agriculture",
        "pratique_elevage`",
        "pratique_peche",
        "location_equipement"
    ),
    where = (
        revenu_emploi == 0 &
        revenu_hors_emploi == 0 &
        num_entreprises == 0 &
        recu_transfert == 0 &
        recu_filet == 0 &
        pratique_agriculture == 0 &
        pratique_elevage == 0 &
        pratique_peche == 0 &
        location_equipement == 0
    ),
    type = 1,
    desc = "Aucun revenu",
    comment = paste0(
        "ERREUR: Aucune source de revenu déclarée pour le ménage: ",
        "aucun revenu d'emploi (4A à 4C), aucun revenu hors emploi (5), ",
        "aucun transfert reçu (13A), aucun revenu d'une activité rémunerative",
        "(10, 16, 17, 18), aucun bénéfice des filets de sécurité (15), ",
        "aucun revenu de location (19).)"        
    )
)

# =============================================================================
# Flag critical inconsistencies
# =============================================================================

# travaille dans une entrepise, sans en déclarer une
issue_travail_ent_sans_ent <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("travail_entreprise", "num_entreprises"),
    where = travail_entreprise == 1 & num_entreprises == 0,
    type = 1,
    desc = "Travaille en entrepise, sans en déclarer une",
    comment = paste0(
        "ERREUR: Au moins un membre du ménage travaille dans une entreprise ",
        "familiale selon les informations des sections 4B et 4C, ",
        "mais aucune entreprise n'est déclarée dans la section 10. ",
        "Veuillez confirmer les activités d'emploi et d'entreprise."
    )
)

# travaille dans l'agriculture, sans déclarer une activité agricole
issue_travail_ag_sans_ag <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("travail_agric", "pratique_agriculture"),
    where = travail_agric == 1 & pratique_agriculture == 0,
    type = 1,
    desc = "Travaille en agriculture, sans déclarer une activité agricole",
    comment = paste0(
        "ERREUR: Au moins un membre du ménage travaille dans l'agriculture ",
        "familiale selon les informations des sections 4B et 4C, ",
        "mais aucune activité agricole n'est déclarée dans la section 16A. ",
        "Veuillez confirmer les activités d'emploi et d'agriculture."
    )
)

# travaille dans l'élevage, sans déclarer une activité d'élevage
issue_travail_elev_sans_elev <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("travail_elevage", "pratique_elevage"),
    where = travail_elevage == 1 & pratique_elevage == 0,
    type = 1,
    desc = "Travaille en élevage, sans déclarer une activité d'élevage",
    comment = paste0(
        "ERREUR: Au moins un membre du ménage travaille dans l'élevage ",
        "familiale selon les informations des sections 4B et 4C, ",
        "mais aucune activité d'élevage n'est déclarée dans la section 17. ",
        "Veuillez confirmer les activités d'emploi et d'élevage."
    )
)

# travaille dans la pêche, sans déclarer une activité piscicole
issue_travail_peche_sans_peche <- susoreview::create_issue(
    df_attribs = attribs,
    vars = c("travail_peche", "pratique_elevage"),
    where = travail_peche == 1 & pratique_elevage == 0,
    type = 1,
    desc = "Travaille en pêche, sans déclarer une activité de pêche",
    comment = paste0(
        "ERREUR: Au moins un membre du ménage travaille dans la pêche ",
        "familiale selon les informations des sections 4B et 4C, ",
        "mais aucune activité de pêche n'est déclarée dans la section 18. ",
        "Veuillez confirmer les activités d'emploi et de pêche."
    )
)

# =============================================================================
# Combine all issues
# =============================================================================

# combine all issues
issues <- dplyr::bind_rows(mget(ls(pattern = "^issue_")))

# remove intermediary objects to lighten load on memory
rm(list = ls(pattern = "^issue_"))

# =============================================================================
# Add issues from interview metadata
# =============================================================================

# -----------------------------------------------------------------------------
# ... if questions left unanswered
# -----------------------------------------------------------------------------

# get interview statistics
# creates data frame with interview stats
interviews <- cases_to_review$interview__id
interview_stats <- purrr::map_dfr(
        .x = interviews,
        .f = ~ susoapi::get_interview_stats(interview_id = .x)
    ) %>%
    dplyr::rename(interview__id = InterviewId, interview__key = InterviewKey)

# prepare number of legit missing file
# TODO: see if any legit unanswered
# num_legit_miss <- num_legit_miss %>%
#     rename(n_legit_miss = numLegitMiss) %>%
#     select(interview__id, interview__key, n_legit_miss)

# add error if interview completed, but questions left unanswered
# returns issues data supplemented with unanswered question issues
issues_plus_unanswered <- susoreview::add_issue_if_unanswered(
    df_cases_to_review = cases_to_review,
    df_interview_stats = interview_stats,
    df_issues = issues,
    n_unanswered_ok = 0
    # ,
    # df_legit_miss = num_legit_miss
)

# -----------------------------------------------------------------------------
# ... if any SuSo errors
# -----------------------------------------------------------------------------

# add issue if there are SuSo errors
issues_plus_miss_and_suso <- susoreview::add_issues_for_suso_errors(
    df_cases_to_review = cases_to_review,
    df_errors = suso_errors,
    issue_type = 3,
    df_issues = issues_plus_unanswered
)
