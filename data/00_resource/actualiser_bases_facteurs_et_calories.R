# =============================================================================
# Identifier et ingérer les bases des calories et des facteurs de conversion
# =============================================================================

# répertoires
# - utiliser / au lieu de \ dans le chemin
# - être certain de mettre / à la fin du chemin
resource_dir <- ""

# calories
# prendre la base ici: https://github.com/arthur-shaw/ehcvm-tri-automatique/tree/master/donnees/ressources
# sauvegarder dans le répertoire suivant de projet: /data/00_resource/
# indiquer le nom dans entre guillemets ici-bas
fichier_calories            <- "calories.dta"
produit_id_var_calories     <- "produitID"

# facteurs de conversion des NSU
# prendre la base depuis le programme de rejet de l'EHCVM 2, qui devrait se trouver dans
# le répertoire suivant: /donnees/ressources/
# sauvegarder dans le répertoire suivant de projet: /data/00_resource/
# indiquer le nom dans entre guillemets ici-bas
fichier_facteurs            <- ""
produit_id_var_facteurs     <- ""

# =============================================================================
# Charger les packages requis
# =============================================================================

library(haven)
library(rlang)
library(dplyr)
library(readxl)

# =============================================================================
# Définir les fonctions
# =============================================================================

# -----------------------------------------------------------------------------
# Reconvertir les obs les produits éclatés et/ou nouveaux
# -----------------------------------------------------------------------------

#' Reconvertir des observations d'un tableau de référence
#' 
#' Certaines observations existantes peuvent servir de substitut pour des 
#' actuellement inexistantes. D'abord, prendre une observations source par son ID. 
#' Ensuite, convertir cette observation en lui attribuant un ID cible.
#' 
#' @param df Data frame. 
#' @param var_id Charactère. Nom de varaible qui identifie le produit.
#' @param val_souce Numérique. Valeur de l'ID de l'observation source
#' @param val_cible Numérique. Valeur de l'ID de l'observation cible
#' 
#' @return Data frame. Même structure que `df`. Observation avec ID différent.
#' 
#' @importFrom dplyr `%>%` filter mutate
reconvertir_obs <- function(
    df,
    var_id,
    val_source,
    val_cible
) {

    var_id <- rlang::sym(var_id)

    df_converti <- df %>%
        dplyr::filter(!!var_id == val_source) %>%
        dplyr::mutate(!!var_id := val_cible)        

    return(df_converti)

}

# -----------------------------------------------------------------------------
# Renuméroter les ID pour les produits stables
# -----------------------------------------------------------------------------

#' Renuméroter les produits groupe par groupe
#' 
#' @param df Data frame.
#' @param aliment_id Caractère. Variable d'identification des aliments
#' 
#' @return Data frame. Base avec une numérotation actualisée
#' 
#' @importFrom dplyr `%>%` mutate case_when
#' @importFrom haven zap_labels
#' @import rlang
renumeroter_aliments <- function(
    df,
    aliment_id
) {

    aliment_id <- rlang::sym(aliment_id)

    df_renumerote <- df %>%
        haven::zap_labels() %>%
        dplyr::mutate(
            # renuméroter en allant de la fin de la liste au début
            {{ aliment_id }} := dplyr::case_when(
                # boissons à partir de "Café"
                {{ aliment_id }} >= 129 ~ {{ aliment_id }} + 27,
                # autre condiments et noix de cola
                {{ aliment_id }} %in% c(126, 127) ~ {{ aliment_id }} + 26,
                # Gingembre (120) à Vinaigre /moutarde
                {{ aliment_id }} %in% c(120:125) ~ {{ aliment_id }} + 23,
                # sel et piment séché
                {{ aliment_id }} %in% c(118:119) ~ {{ aliment_id }} + 21,
                # de sucre (114) à caramel (117)
                {{ aliment_id }} %in% c(114:117) ~ {{ aliment_id }} + 21,
                # de gari (112) à attiéke (113)
                {{ aliment_id }} %in% c(112:113) ~ {{ aliment_id }} + 19,
                # de sésame (101) à farine de manioc (111)
                {{ aliment_id }} %in% c(101:111) ~ {{ aliment_id }} + 19,
                # arachides grillée (99) à pâte d'arachide (100)
                {{ aliment_id }} %in% c(99:100) ~ {{ aliment_id }} + 18,
                # de "aubergine, courge/courgette" (77) à Arachides décortiquées ou pilées (98)
                {{ aliment_id }} %in% c(77:98) ~ {{ aliment_id }} + 17,
                # de "autres fruits" (71) à "concombre" (76) 
                {{ aliment_id }} %in% c(71:76) ~ {{ aliment_id }} + 16,
                # de "pastèque, melon" (67) à "canne à sucre" (70)
                {{ aliment_id }} %in% c(67:70) ~ {{ aliment_id }} + 12,
                # avocat
                {{ aliment_id }} == 66 ~ 77,
                # banane douce
                {{ aliment_id }} == 63 ~ 76,
                # de "citrons" à "autres agrumes"
                {{ aliment_id }} %in% c(64:65) ~ {{ aliment_id }} + 10,
                # de "autres hules" (59) à "orange" (62)
                {{ aliment_id }} %in% c(59:62) ~ {{ aliment_id }} + 11,
                # de "huile de coton" (57) à "huile de palme raffinée" (58)
                {{ aliment_id }} %in% c(57:58) ~ {{ aliment_id }} + 10,
                # de "crabes, crevettes et autres fruits de mer" (42) à "huile d'arachide" (56)
                {{ aliment_id }} %in% c(42:56) ~ {{ aliment_id }} + 8,
                # de "gibier" (33) à "poisson séché" (41)
                {{ aliment_id }} %in% c(33:41) ~ {{ aliment_id }} + 5,
                # de "pâte alimentaire" (16) à "charcuterie" (32)
                {{ aliment_id }} %in% c(16:32) ~ {{ aliment_id }} + 4,
                # autres farines de céréales 
                {{ aliment_id }} == 15 ~ 18,
                # farine de blé local ou importé
                {{ aliment_id }} == 14 ~ 16,
                # farine de mil
                {{ aliment_id }} == 13 ~ 14,
                # cereales
                {{ aliment_id }} <= 12 ~ {{ aliment_id }}
            )
        )

    return(df_renumerote)

}

# =============================================================================
# Calories
# =============================================================================

# ingérer la base de l'EHCVM 1
calories <- haven::read_dta(file = paste0(resource_dir, fichier_calories))

# -----------------------------------------------------------------------------
# Créer des observations pour les produits éclatés
# -----------------------------------------------------------------------------

# extraire les codes de produit du fichier Excel
produits_eclates <- readxl::read_xlsx(path = paste0(resource_dir, "calories_produits_eclates.xlsx"))
eclates_depuis <- dplyr::pull(produits_eclates, val_source)
eclates_vers <- dplyr::pull(produits_eclates, val_cible)

# peupler une base des observations reconverties
calories_eclates <- purrr::map2_dfr(
    .x = eclates_depuis,
    .y = eclates_vers,
    .f = ~ reconvertir_obs(
        df = calories,
        var_id = produit_id_var_calories,
        val_source = .x,
        val_cible = .y
    )
)

# -----------------------------------------------------------------------------
# Créer des observations pour les nouveaux produits
# -----------------------------------------------------------------------------

# extraire les codes de produit du fichier Excel
produits_nouveaux <- readxl::read_xlsx(path = paste0(resource_dir, "calories_produits_nouveaux.xlsx"))
nouveaux_depuis <- dplyr::pull(produits_nouveaux, val_source)
nouveaux_vers <- dplyr::pull(produits_nouveaux, val_cible)

# peupler une base des observations reconverties
calories_nouveaux <- purrr::map2_dfr(
    .x = nouveaux_depuis,
    .y = nouveaux_vers,
    .f = ~ reconvertir_obs(
        df = calories,
        var_id = produit_id_var_calories,
        val_source = .x,
        val_cible = .y
    )
)

# -----------------------------------------------------------------------------
# Renuméroter les observations
# -----------------------------------------------------------------------------

# renuméroter les identifiants
calories_renumerote <- renumeroter_aliments(
    df = calories, 
    aliment_id = "produitID"
)

# -----------------------------------------------------------------------------
# Joindre les bases
# -----------------------------------------------------------------------------

# mettre ensemble les bases de calories
tbl_calories_ehcvm2 <- dplyr::bind_rows(
    calories_eclates,
    calories_nouveaux,
    calories_renumerote
)

# supprimer les objets intermédiaires afin d'alléger la mémoire
rm(list = ls(pattern = "^calories_"))

# confirmer la présence de tous les produits
produits <- c(1:153, 155:180)
produits_absents <- produits[!produits %in% tbl_calories_ehcvm2$produitID]
if (length(produits_absents) >= 1) {
    produits_absents_liste <- glue::glue_collapse(produits_absents, sep = ", ", last = ", et ")
    warning(glue::glue(
        "Certains produits ne figurent pas dans la base.",
        "Voici la liste des identifiants: {produits_absents_liste}",
        .sep = "\n"
    ))
}

# sauvegarder le résultat
haven::write_dta(
    data = tbl_calories_ehcvm2, 
    path = paste0(resource_dir, "calories_ehcvm2.dta")
)

# =============================================================================
# Facteurs de conversion
# =============================================================================

# ingérer la base de l'EHCVM 1
facteurs <- haven::read_dta(file = paste0(resource_dir, fichier_facteurs))

# -----------------------------------------------------------------------------
# Créer des observations pour les produits éclatés
# -----------------------------------------------------------------------------

# extraire les codes de produit du fichier Excel
produits_eclates <- readxl::read_xlsx(path = paste0(resource_dir, "facteurs_produits_eclates.xlsx"))
eclates_depuis <- dplyr::pull(produits_eclates, val_source)
eclates_vers <- dplyr::pull(produits_eclates, val_cible)

# peupler une base des observations reconverties
facteurs_eclates <- purrr::map2_dfr(
    .x = eclates_depuis,
    .y = eclates_vers,
    .f = ~ reconvertir_obs(
        df = facteurs,
        var_id = produit_id_var_facteurs,
        val_source = .x,
        val_cible = .y
    )
)

# -----------------------------------------------------------------------------
# Créer des observations pour les nouveaux produits
# -----------------------------------------------------------------------------

# extraire les codes de produit du fichier Excel
produits_nouveaux <- readxl::read_xlsx(path = paste0(resource_dir, "facteurs_produits_nouveaux.xlsx"))
nouveaux_depuis <- dplyr::pull(produits_nouveaux, val_source)
nouveaux_vers <- dplyr::pull(produits_nouveaux, val_cible)

# peupler une base des observations reconverties
facteurs_nouveaux <- purrr::map2_dfr(
    .x = nouveaux_depuis,
    .y = nouveaux_vers,
    .f = ~ reconvertir_obs(
        df = facteurs,
        var_id = produit_id_var_facteurs,
        val_source = .x,
        val_cible = .y
    )
)

# -----------------------------------------------------------------------------
# Renuméroter les observations
# -----------------------------------------------------------------------------

# renuméroter les identifiants des produits alimentaires
facteurs_renumerotes <- renumeroter_aliments(
    df = facteurs,
    aliment_id = produit_id_var_facteurs
)
 
# -----------------------------------------------------------------------------
# Joindre les bases
# -----------------------------------------------------------------------------

# mettre ensemble les bases de calories
tbl_facteurs_ehcvm2 <- dplyr::bind_rows(
    facteurs_eclates,
    facteurs_nouveaux,
    facteurs_renumerotes    
)

# supprimer les objets intermédiaires afin d'alléger la mémoire
rm(list = ls(pattern = "^facteurs_"))

# sauvegarder le résultat
haven::write_dta(
    data = tbl_facteurs_ehcvm2, 
    path = paste0(resource_dir, "facteurs_ehcvm2.dta")
)
