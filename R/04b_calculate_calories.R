# =============================================================================
# Calculer les calories
# =============================================================================

# -----------------------------------------------------------------------------
# Définir une fonction pour calculer la taille du ménage
# -----------------------------------------------------------------------------

#' Calculer la taille du ménage
#' 
#' @param membres_df Data frame. Base ménage.
#' 
#' @return Data frame. Base avec la taille du ménage ainsi que les identifiants
#' 
#' @importFrom dplyr `%>%` mutate group_by summarise ungroup
calculer_taille_menage <- function(
    membres_df = membres_df
) {

    member_count <- membres_df %>%
        # non-visitors
        dplyr::mutate(
            taille_menage = (
                # member, ancien ou nouveau
                ((!is.na(preload_pid) & s01q00a == 1) | is.na(preload_pid)) & 
                # non-visiteur
                (s01q12 == 1 | s01q13 == 1)
            )
        ) %>%
        dplyr::group_by(interview__id, interview__key) %>%
        dplyr::summarise(taille_menage = sum(taille_menage, na.rm = TRUE)) %>%
        dplyr::ungroup()

    return(member_count)

}

# -----------------------------------------------------------------------------
# Définir une fonction pour calculer les calories par produit
# -----------------------------------------------------------------------------

#' Calculer les calories par item
#' 
#' @param menage_df Data frame.
#' @param cases_df Data frame.
#' @param taille_df Data frame.
#' @param taille_var Bare variable name.
#' @param conso_alim_df Data frame.
#' @param alim_produit_id Bare variable name.
#' @param alim_quantite_var Bare variable name.
#' @param alim_unite_var Bare variable name.
#' @param alim_taille_var Bare variable name.
#' @param facteurs_df Data frame.
#' @param facteurs_produit_id Caractère. Nom de la variable.
#' @param facteurs_region_var Caractère. Nom de la variable.
#' @param facteurs_milieu_var Caractère. Nom de la variable.
#' @param facteurs_unite_var Caractère. Nom de la variable.
#' @param facteurs_taille_var Caractère. Nom de la variable.
#' @param facteurs_poids_var Caractère. Nom de la variable.
#' @param calories_df Bare variable name.
#' @param calories_produit_id Bare variable name.
#' @param calories_deflateur_var Bare variable name.
#' @param calories_valeur_var Bare variable name.
#' 
#' @return Data frame
#' 
#' @importFrom rlang sym as_label enquo
#' @importFrom dplyr `%>%` select group_by summarise ungroup rename left_join mutate case_when
#' @importFrom haven zap_formats
calculer_calories <- function(
    menages_df = menages,

    # cas à valider
    cases_df = cases_to_review,

    # taille menage
    taille_df = taille_menage_calculee,
    taille_var = taille_menage,

    # consommation alimentaire
    conso_alim_df = food_df,
    alim_produit_id = aliment__id,
    alim_quantite_var = s07Bq03a,
    alim_unite_var = s07Bq03b,
    alim_taille_var = s07Bq03c,

    # facteurs
    facteurs_df,
    facteurs_produit_id,
    facteurs_niveau = "national",
    facteurs_region_var = NULL,
    facteurs_milieu_var = NULL,
    facteurs_unite_var,
    facteurs_taille_var,
    facteurs_poids_var,

    # calories
    calories_df,
    calories_produit_id = produitID,
    calories_deflateur_var = refuseDeflator,
    calories_valeur_var = kiloCalories

) {
    
    # convert character names to symbols
    facteurs_produit_id <- rlang::sym(facteurs_produit_id)
    if (facteurs_niveau == "strate") {
    facteurs_region_var <- rlang::sym(facteurs_region_var)
    facteurs_milieu_var <- rlang::sym(facteurs_milieu_var)
    }
    facteurs_unite_var  <- rlang::sym(facteurs_unite_var)
    facteurs_taille_var <- rlang::sym(facteurs_taille_var)
    facteurs_poids_var  <- rlang::sym(facteurs_poids_var)

    # create characters for merge keys
    alim_produit_id_nm      <- rlang::as_label(rlang::enquo(alim_produit_id))
    alim_unite_var_nm       <- rlang::as_label(rlang::enquo(alim_unite_var))
    alim_taille_var_nm      <- rlang::as_label(rlang::enquo(alim_taille_var))
    facteurs_produit_id_nm  <- rlang::as_label(rlang::enquo(facteurs_produit_id))
    if (facteurs_niveau == "strate") {
    facteurs_region_var_nm  <- rlang::as_label(rlang::enquo(facteurs_region_var))
    facteurs_milieu_var_nm  <- rlang::as_label(rlang::enquo(facteurs_milieu_var))
    }
    facteurs_unite_var_nm   <- rlang::as_label(rlang::enquo(facteurs_unite_var))
    facteurs_taille_var_nm  <- rlang::as_label(rlang::enquo(facteurs_taille_var))
    calories_produit_id_nm  <- rlang::as_label(rlang::enquo(calories_produit_id))

    # create `by` arguments for joins
    if (facteurs_niveau == "strate") {
    by_region <- rlang::set_names(nm = "s00q01", x = facteurs_region_var_nm)
    by_milieu <- rlang::set_names(nm = "s00q04", x = facteurs_milieu_var_nm)
    }
    by_produit_facteurs <- rlang::set_names(nm = alim_produit_id_nm, x = facteurs_produit_id_nm)
    by_unite <- rlang::set_names(nm = alim_unite_var_nm, x = facteurs_unite_var_nm)
    by_taille <- rlang::set_names(nm = alim_taille_var_nm, x = facteurs_taille_var_nm)

    by_produit_calories <- rlang::set_names(nm = alim_produit_id_nm, x = calories_produit_id_nm)

    # prepare data so that there are no overlapping variable names
    menages_df <- menages_df %>%
        dplyr::select(
            # hhold identifiers
            interview__id, interview__key, 
            # strata identifiers for factors
            s00q01, s00q04
        )

    cases_df <- cases_df %>%
        dplyr::select(interview__id, interview__key)

    taille_df <- taille_df %>%
        dplyr::select(interview__id, interview__key, {{taille_var}})

    conso_alim_df <- conso_alim_df %>%
        dplyr::select(
            interview__id, interview__key,
            {{alim_produit_id}}, {{alim_quantite_var}}, 
            {{alim_unite_var}}, {{alim_taille_var}}
        )

    facteurs_df <- facteurs %>%
        {
            if (facteurs_niveau == "national") {
                dplyr::select(., 
                    {{facteurs_produit_id}}, {{facteurs_unite_var}}, 
                    {{facteurs_taille_var}}, {{facteurs_poids_var}}
                )
            } else if (facteurs_niveau == "strate") {
                dplyr::select(., 
                    {{facteurs_region_var}}, {{facteurs_milieu_var}},
                    {{facteurs_produit_id}}, {{facteurs_unite_var}}, 
                    {{facteurs_taille_var}}, {{facteurs_poids_var}}
                )
            }
        }

    facteurs_natl_var <- paste0(
        rlang::as_label(rlang::enquo(facteurs_poids_var)),
        "_natl"
    )

    facteurs_natl <- facteurs %>%
        dplyr::group_by(
            {{facteurs_produit_id}}, 
            {{facteurs_unite_var}}, {{facteurs_taille_var}}
        ) %>%
        dplyr::summarise({{facteurs_poids_var}} := median({{facteurs_poids_var}}, na.rm = TRUE)) %>%
        dplyr::ungroup() %>%
        dplyr::rename(!!facteurs_natl_var := {{facteurs_poids_var}})

    calories_df <- calories %>%
        dplyr::select(
            {{calories_produit_id}},
            {{calories_deflateur_var}},
            {{calories_valeur_var}}
        )

    # merge data
    calories_impliquees <- cases_df %>%
        dplyr::left_join(menages_df, by = c("interview__id", "interview__key")) %>%
        dplyr::left_join(taille_df, by = c("interview__id", "interview__key")) %>%
        dplyr::left_join(conso_alim_df, by = c("interview__id", "interview__key")) %>%
        # merge factors
        {
            # national: by item and unit
            if (facteurs_niveau == "national") {
                dplyr::left_join(., facteurs_df, by = c(
                    by_produit_facteurs,
                    by_unite,
                    by_taille
                ))
            # strata: by region, urban/rural, item and unit
            } else if (facteurs_niveau == "strate") {
                # strata
                dplyr::left_join(., facteurs_df, by = c(
                    by_region,
                    by_milieu, 
                    by_produit_facteurs,
                    by_unite,
                    by_taille
                )) %>%
                # national
                dplyr::left_join(facteurs_natl, by = c(
                    by_produit_facteurs,
                    by_unite,
                    by_taille
                )) %>%
                # use most local info
                # if missing at strata level, use national median
                # if not missing at strata level, use strata
                dplyr::mutate({{facteurs_poids_var}} := dplyr::case_when(
                    is.na({{facteurs_poids_var}}) ~ !!rlang::sym(facteurs_natl_var),
                    !is.na({{facteurs_poids_var}}) ~ {{facteurs_poids_var}}
                ))                
            }
        } %>%
        # merge calories
        dplyr::left_join(calories_df, by = by_produit_calories) %>%
        # replace DO NOT KNOW values with missing
        dplyr::mutate({{alim_quantite_var}} := dplyr::if_else(
            condition = {{alim_quantite_var}} == 9999,
            true = NA_real_,
            false = {{alim_quantite_var}},
            missing = {{alim_quantite_var}}
        )) %>%
        # compute calories
        dplyr::mutate(
            # Convert from grams (g) to calories (kcal)
            weight_in_g = {{facteurs_poids_var}} * {{alim_quantite_var}},
            weight_in_g_conso = weight_in_g * {{calories_deflateur_var}},
            weight_conso_100g = weight_in_g_conso/100,
            # Compute calories by item
            calories_par_produit = (weight_conso_100g * {{calories_valeur_var}})/(7 * {{taille_var}})          
        ) %>%
        # flag items that have entered into computation (and not)
        dplyr::mutate(
            n_consomme = TRUE,
            n_calcule = !is.na(calories_par_produit)
        ) %>%
        haven::zap_formats() %>%
        dplyr::select(
            interview__id, interview__key, 
            {{alim_produit_id}}, {{alim_quantite_var}}, {{alim_unite_var}}, {{alim_taille_var}},
            calories_par_produit, n_consomme, n_calcule
        )

    return(calories_impliquees)

}

# -----------------------------------------------------------------------------
# Calculer les calories impliquées par la consommation déclarée
# -----------------------------------------------------------------------------

taille_menage_calculee <- calculer_taille_menage(membres_df = membres)

facteurs <- haven::read_dta(file = paste0(resource_dir, nom_fichier_facteurs))
calories <- haven::read_dta(file = paste0(resource_dir, nom_fichier_calories))

calories_par_item <- calculer_calories(
    menages_df = menages, 
    cases_df = cases_to_review, 
    taille_df = taille_menage_calculee, 
    taille_var = taille_menage, 
    # consommation alimentaire
    conso_alim_df = food_df, 
    alim_produit_id = aliment__id, 
    alim_quantite_var = s07Bq03a, 
    alim_unite_var = s07Bq03b, 
    alim_taille_var = s07Bq03c,
    # facteurs de conversion 
    facteurs_df = facteurs, 
    facteurs_produit_id = facteurs_prod_id, 
    facteurs_niveau = facteurs_niv, 
    facteurs_region_var = facteurs_region, 
    facteurs_milieu_var = facteurs_milieu, 
    facteurs_unite_var = facteurs_unite, 
    facteurs_taille_var = facteurs_taille, 
    facteurs_poids_var = facteurs_poids, 
    # calories par produit
    calories_df = calories, 
    calories_produit_id = produitID, 
    calories_deflateur_var = refuseDeflator, 
    calories_valeur_var = kiloCalories
)

calories_totales <- calories_par_item %>%
    dplyr::group_by(interview__id, interview__key) %>%
    dplyr::summarise(
        dplyr::across(
            .cols = c(calories_par_produit, n_consomme, n_calcule),
            .fns = ~ sum(.x, na.rm = TRUE)
        )
    ) %>%
    dplyr::mutate(
        calories_totales = calories_par_produit,
        p_calcule = n_calcule/n_consomme
    ) %>%
    dplyr::select(-calories_par_produit) %>%
    dplyr::ungroup()

# -----------------------------------------------------------------------------
# Sauvegarder les bases du calcul calorifique
# -----------------------------------------------------------------------------

# calories par item
haven::write_dta(
    data = calories_par_item,
    path = paste0(derived_dir, "calories_par_item.dta")
)

# calories totales
haven::write_dta(
    data = calories_totales,
    path = paste0(derived_dir, "calories_totales.dta")
)
