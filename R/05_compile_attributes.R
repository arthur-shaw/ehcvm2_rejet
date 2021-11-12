# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "menages",
    "membres", 
    "filets_securite",
    "equipements",
    "calories_totales",
    "calories_par_item"
)

check_exists(objects_needed)

# =============================================================================
# Load necessary libraries
# =============================================================================

library(dplyr)
library(susoreview)
library(purrr)
library(rlang)

# =============================================================================
# Create attributes
# =============================================================================

# -----------------------------------------------------------------------------
# Ménage
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 7A, 7B : CONSOMMATION ALIMENTAIRE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# en dehors du ménage, consommation par le ménage en entier (section 7A)
attrib_repas_dehors_menage <- susoreview::any_vars(
    df = menages,
    var_pattern = "s07Aq01b|s07Aq04b|s07Aq07b|s07Aq10b|s07Aq13b|s07Aq16b|s07Aq19b",
    var_val = c(1, 2, 3),
    attrib_name = "repas_dehors_menage"
)

# au sein du ménage (section 7B)
attrib_repas_a_domicile <- susoreview::any_vars(
    df = menages,
    var_pattern = "^s07Bq02_",
    var_val = 1,
    attrib_name = "repas_a_domicile"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 9A à 9F : CONSOMMATION NON-ALIMENTAIRE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# fêtes
attrib_depense_fetes <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Aq02",
    var_val = 1,
    attrib_name = "depense_fetes"
)

# 7 jours
attrib_depense_7d <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Bq02",
    var_val = 1,
    attrib_name = "depense_7d"
)

# 30 jours
attrib_depense_30d <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Cq02",
    var_val = 1,
    attrib_name = "depense_30d"
)

# 3 mois
attrib_depense_3m <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Dq02",
    var_val = 1,
    attrib_name = "depense_3m"
)

# 6 mois
attrib_depense_6m <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Eq02",
    var_val = 1,
    attrib_name = "depense_6m"
)

# 12 mois
attrib_depense_12m <- susoreview::any_vars(
    df = menages,
    var_pattern = "s09Fq02",
    var_val = 1,
    attrib_name = "depense_12m"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 10: ENTREPRISES NON-AGRICOLES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# nombre d'entreprises
attrib_num_entreprises <- susoreview::count_list(
    df = menages,
    var_pattern = "s10q12a",
    missing_val = "##N/A##",
    attrib_name = "num_entreprises"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 11 : LOGEMENT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# entreprise localisée au domicile
attrib_entreprise_au_domicile <- susoreview::create_attribute(
    df = menages,
    condition = s11q17 == 1,
    attrib_name = "entreprise_au_domicile",
    attrib_vars = "s11q17"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 13A : TRANSFERTS REÇUS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# si un transfert reçu
attrib_recu_transfert <- susoreview::count_list(
    df = menages,
    var_pattern = "s13q09a",
    missing_val = "##N/A##",
    attrib_name = "recu_transfert"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 15 : FILETS DE SECURITE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# si un bénéfice reçu d'un filet de sécurité
attrib_recu_filet <- susoreview::any_obs(
    df = filets_securite,
    where = s15q05 == 1,
    attrib_name = "recu_filet",
    attrib_vars = "s15q05"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 16A : AGRICULTURE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pratique l'agriculture
attrib_pratique_agriculture <- susoreview::create_attribute(
    df = menages,
    condition = s16Aq00 == 1,
    attrib_name = "pratique_agriculture",
    attrib_vars = "s16Aq00"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 17 : ELEVAGE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pratique l'élevage
attrib_pratique_elevage <- susoreview::create_attribute(
    df = menages,
    condition = s17q00 == 1,
    attrib_name = "pratique_elevage",
    attrib_vars = "s17q00"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 18 : PÊCHE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# pratique la pêche
attrib_pratique_peche <- susoreview::create_attribute(
    df = menages,
    condition = s18q01 == 1,
    attrib_name = "pratique_peche",
    attrib_vars = "s18q01"
)


# -----------------------------------------------------------------------------
# Membres
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 1A : CARACTERISTIQUES DEMOGRAPHIQUES
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# nombre de chef de ménage
attrib_num_chefs <- susoreview::count_obs(
    df = membres,
    where = s01q02 == 1,
    attrib_name = "num_chefs",
    attrib_vars = "s01q02"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 4A à 4B : EMPLOI
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

type_employeur <- c(3, 4)
categ_soc_prof <- c(8, 9, 10)

activite_agric <- c(111:129)
activite_elevage <- c(141:148)
activite_peche <- c(310:330)
activite_publique <- c(8410, 8420, 8430)

emploi <- membres %>%
    dplyr::mutate(
        travail_agric = (
            # emploi principal
            (
                # branche d'activité: culture
                (s04q30d %in% activite_agric) & 
                # type d'employeur
                (s04q31 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q39 %in% categ_soc_prof)    
            )

            |

            # emploi secondaire
            (
                # branche d'activité: culture
                (s04q52d %in% activite_agric) & 
                # type d'employeur
                (s04q53 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q57 %in% categ_soc_prof)
            )

        ),
        travail_elevage = (
            # emploi principal
            (
                # branche d'activité: culture
                (s04q30d %in% activite_elevage) & 
                # type d'employeur
                (s04q31 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q39 %in% categ_soc_prof)    
            )

            |

            # emploi secondaire
            (
                # branche d'activité: culture
                (s04q52d %in% activite_elevage) & 
                # type d'employeur
                (s04q53 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q57 %in% categ_soc_prof)
            )

        ),
        travail_peche = (
            # emploi principal
            (
                # branche d'activité: culture
                (s04q30d %in% activite_peche) & 
                # type d'employeur
                (s04q31 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q39 %in% categ_soc_prof)    
            )

            |

            # emploi secondaire
            (
                # branche d'activité: culture
                (s04q52d %in% activite_peche) & 
                # type d'employeur
                (s04q53 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q57 %in% categ_soc_prof)
            )

        ),
        travail_entreprise = (
            # emploi principal
            (
                # branche d'activité: ni qgriculutre, ni élevage, ni pêche, ni administration publique
                (!s04q30d %in% c(activite_agric, activite_elevage, activite_peche, activite_publique)) & 
                # type d'employeur
                (s04q31 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q39 %in% categ_soc_prof)    
            )

            |

            # emploi secondaire
            (
                # branche d'activité: ni qgriculutre, ni élevage, ni pêche, ni administration publique
                (!s04q52d %in% c(activite_agric, activite_elevage, activite_peche, activite_publique)) & 
                # type d'employeur
                (s04q53 %in% type_employeur) &  
                # catégorie socio-professionnelle
                (s04q57 %in% categ_soc_prof)
            )

        )
    )

emploi_vars <- "s04q30d|s04q31|s04q39|s04q52d|s04q53|s04q57"

# revenu de l'emploi
attrib_revenu_emploi <- susoreview::any_obs(
    df = membres,
    where = (s04q43 > 0) | (s04q58 > 0),
    attrib_name = "revenu_emploi",
    attrib_vars = "s04q43|s04q58"
)

# travaille dans une entreprise non-agricole familiale
attrib_travail_entreprise <- susoreview::any_obs(
    df = emploi,
    where = travail_entreprise == 1,
    attrib_name = "travail_entreprise",
    attrib_vars = emploi_vars
)

# travaille dans l'agriculture familiale
attrib_travail_agric <- susoreview::any_obs(
    df = emploi,
    where = travail_agric == 1,
    attrib_name = "travail_agric",
    attrib_vars = emploi_vars
)

# travaille dans l'élevage familial
attrib_travail_elevage <- susoreview::any_obs(
    df = emploi,
    where = travail_elevage == 1,
    attrib_name = "travail_elevage",
    attrib_vars = emploi_vars
)

# travaille dans la pêche familiale
attrib_travail_peche <- susoreview::any_obs(
    df = emploi,
    where = travail_peche == 1,
    attrib_name = "travail_peche",
    attrib_vars = emploi_vars
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 5 : REVENU HORS EMPLOI
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# revenu hors emploi
attrib_revenu_hors_emploi <- membres %>%
    dplyr::mutate(
        revenu = dplyr::if_any(
            .cols = c(s05q01, s05q03, s05q05, s05q07, s05q09, s05q11, s05q13),
            .fns = ~ .x == 1
        )
    ) %>%
    susoreview::any_obs(
        where = revenu == 1,
        attrib_name = "revenu_hors_emploi",
        attrib_vars = "s05q01|s05q03|s05q05|s05q07|s05q09|s05q11|s05q13"
    )

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 7A : REPAS HORS MENAGE
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

attrib_repas_dehors_membre <- membres %>%
    dplyr::mutate(
        repas = dplyr::if_any(
            .cols = c(s07Aq01, s07Aq04, s07Aq07, s07Aq10, s07Aq13, s07Aq16, s07Aq19),
            .fns = ~ .x %in% c(1, 2, 3)
        )
    ) %>%
    susoreview::any_obs(
        where = repas == 1,
        attrib_name = "repas_dehors_membre",
        attrib_vars = "s07Aq01|s07Aq04|s07Aq07|s07Aq10|s07Aq13|s07Aq16|s07Aq19"
    )

# -----------------------------------------------------------------------------
# Équipements
# -----------------------------------------------------------------------------

# perçoit un revenu de location d'équipement
attrib_location_equipement <- susoreview::any_obs(
    df = equipements,
    where = s19q10 == 1,
    attrib_name = "location_equipement",
    attrib_vars = "s19q10"
)

# -----------------------------------------------------------------------------
# Calories totales
# -----------------------------------------------------------------------------

# TODO: uncomment once method developed to compute calories

# pourcentage de produits consommées qui ont été valorisés en calories
attrib_p_aliments_valorises <- susoreview::create_attribute(
    df = calories_totales,
    condition = p_calcule > 0.7,
    attrib_name = "p_calcule_ok",
    attrib_vars = "^s07Bq02_|^s07Bq03a_|^s07Bq03b_|^s07Bq03c_"
)

# trop de calories
attrib_calories_elevees <- susoreview::create_attribute(
    df = calories_totales,
    condition = calories_totales > 4000,
    attrib_name = "calories_totales_elevees",
    attrib_vars = "^s07Bq02_|^s07Bq03a_|^s07Bq03b_|^s07Bq03c_"
)

# trop peu de calories
attrib_calories_faibles <- susoreview::create_attribute(
    df = calories_totales,
    condition = calories_totales <= 800 &  p_calcule > 0.7,
    attrib_name = "calories_totales_faibles",
    attrib_vars = "^s07Bq02_|^s07Bq03a_|^s07Bq03b_|^s07Bq03c_"
)

# -----------------------------------------------------------------------------
# Calories par item
# -----------------------------------------------------------------------------

# trop de calories déclarée pour un seul item
attrib_calories_elevees_item <- susoreview::any_obs(
    df = calories_par_item,
    where = calories_par_produit > 1500,
    attrib_name = "calories_item_elevees",
    attrib_vars = "^s07Bq03a_|^s07Bq03b_|^s07Bq03c_"
)

# =============================================================================
# Combine attributes
# =============================================================================

# combine all attribute data sets whose names match the pattern below
attribs <- dplyr::bind_rows(mget(ls(pattern = "^attrib_")))

# remove intermediary objects to lighten load on memory
rm(list = ls(pattern = "^attrib_"))
