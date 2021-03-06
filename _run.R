# =============================================================================
# Localisation de la racine du projet
# =============================================================================

# suivre ces consignes dans la spécification du répertoire racine
# - utiliser / au lieu de \ dans le chemin
# - être certain de mettre / à la fin du chemin
proj_dir    <- ""

# =============================================================================
# Décrire les fichiers de référence
# =============================================================================

# calories
nom_fichier_calories <- "calories_ehcvm2.dta" 

# facteurs de conversion
nom_fichier_facteurs <- "facteurs_ehcvm2.dta"
facteurs_niv    <- "national" # "national" ou "strate"
facteurs_prod_id <- ""
facteurs_region <- NULL # si niveau national, mettre NULL
facteurs_milieu <- NULL # si niveau national, mettre NULL
facteurs_unite  <- ""
facteurs_taille <- ""
facteurs_poids  <- ""

# =============================================================================
# Fournir les détails du serveur Survey Solutions
# =============================================================================

# fournir
server      <- ""
workspace   <- ""
user        <- ""
password    <- ""

# enregistrer
susoapi::set_credentials(
    server = server,
    user = user,
    password = password
)

# =============================================================================
# Questionnaire sur Headquarters dont les données sont à passer en revue
# =============================================================================

# fournir un texte qui identifie le questionanire. il peut s'agir du:
# - nom complet
# - sous-texte
# - expression régulière
qnr_expr <- ""

# =============================================================================
# Questionnaire sur Designer
# =============================================================================

# fournir la "variable du questionnaire".
# normalement, ça doit être "menage", comme la valeur de défaut ici-bas
# pour certains, ça a été modifié, parfois pour des raisons d'organisation interne
# pour vérifier ou modifier, voici comment faire:
# - se connecter à Designer
# - ouvrir le questionnaire ménage
# - cliquer sur paramètres
# - copier ce qui figure dans le champs "questionnaire variable" et le coller ici-bas
# pour des informations complémentaires, voir ici: https://docs.mysurvey.solutions/questionnaire-designer/components/questionnaire-variable/
main_file_name <- "menage"
main_file_dta <- paste0(main_file_name, ".dta")

# =============================================================================
# Comportement du rejet: quels statuts et quels problèmes rejeter
# =============================================================================

# Fournir une liste délimitée par virgule des statuts d'entretien à passer en revue
# Voir les valeurs ici: https://docs.mysurvey.solutions/headquarters/export/system-generated-export-file-anatomy/#coding_status
# Statuts admis par ce script: 
# - Completed: 100
# - ApprovedBySupervisor: 120
# - ApprovedByHeadquarters: 130
statuses_to_reject <- c(100, 120)

# Fournir une liste délimitée par virgule des types de problèmes à rejeter
# {susoreview} utilise les codes suivants:
# - 1 = Rejeter
# - 2 = Commenter une variable
# - 3 = Erreur de validation de Survey Solutions
# - 4 = Passer en revue
issues_to_reject <- c(1)

# Rejeter les entretiens automatiquement
# - Si TRUE, le programme demande au serveur de rejeter ces entretiens.
# - Si FALSE, le programme ne rejette pas.
# - Dans les deux cas, les entretiens à rejeter, ainsi que les motifs de rejet,
#   sont sauvegardés dans `/output/`
should_reject <- FALSE

# =============================================================================
# Load required packages from {renv} lockfile
# =============================================================================

renv::restore()

# =============================================================================
# Confirm that inputs provided
# =============================================================================

#' Check whether the object exists
#' 
#' @param object Character. Name of the object whose existence to check.
#' 
#' @importFrom glue glue
object_exists <- function(object) {
    if(!exists(object)) {
        stop(glue::glue("No object named `{object}` exists. Please provide it above."))
    } 
}

# -----------------------------------------------------------------------------
# Project directory
# -----------------------------------------------------------------------------

object_exists("proj_dir")

dir.exists(proj_dir)

# -----------------------------------------------------------------------------
# Reference files
# -----------------------------------------------------------------------------

# files exist
ref_dir <- paste0(proj_dir, "data/00_resource/")

check_file <- function(path) {
    if (!file.exists(path)) {
        file_name <- fs::path_file(path)
        parent_folder <- fs::path_dir(path)
        stop(glue::glue(
            "Fichier {file_name} n'existe pas dans le répertoire escompté: ",
            "{parent_folder}",
            .sep = "\n"
        ))
    }
}

check_file(path = paste0(ref_dir, nom_fichier_calories))
check_file(path = paste0(ref_dir, nom_fichier_facteurs))

# factors file has all columns
check_facteurs <- haven::read_dta(file = paste0(ref_dir, nom_fichier_facteurs))

vars_facteurs <- c(
    facteurs_prod_id,
    facteurs_region,
    facteurs_milieu,
    facteurs_unite,
    facteurs_taille,
    facteurs_poids
)

if (!all(vars_facteurs %in% names(check_facteurs))) {
    colonnes_absentes <- vars_facteurs[(!vars_facteurs %in% names(check_facteurs))]
    colonnes_absentes_liste <- glue::glue_collapse(colonnes_absentes, sep = ", ", last = ", et ")
    stop(glue::glue(
        "Au moins une colonne attendue est absente de la base {nom_fichier_facteurs}",
        "Colonnes absente : {colonnes_absentes_liste}",
        .sep = "\n"
    ))
}

# -----------------------------------------------------------------------------
# Program behavior parameters
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Statuses to reject
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exists
object_exists("statuses_to_reject")

# contains only expected values
allowed_statuses <- c(100, 120, 130)
if (any(!statuses_to_reject %in% allowed_statuses)) {
    stop(
        glue::glue(
            "Unexpected values found in `statuses_to_reject`.",
            "Expected: {allowed_statuses}",
            "Found: {statuses_to_reject}",
            .sep = "\n"
        )
    )
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Statuses to reject
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# exists
object_exists("should_reject")

# contains expected values
if (!is.logical(should_reject)) {
    stop(
        glue::glue(
            "Unexpected values found in `should_reject`.",
            "Expected: TRUE/FALSE",
            "Found: {should_reject}",
            .sep = "\n"
        )
    )
}

# -----------------------------------------------------------------------------
# Survey Solutions details
# -----------------------------------------------------------------------------

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Specified
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

suso_details <- c(
    "server",
    "workspace",
    "user",
    "password"
)

purrr::walk(
    .x = suso_details,
    .f = ~ object_exists(.x)
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Valid
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

susoapi::check_credentials(
    workspace = workspace,
    verbose = TRUE
)

# =============================================================================
# Run scripts
# =============================================================================

# specify script directory
script_dir <- paste0(proj_dir, "R/")

# run logic in logical order
source(paste0(script_dir, "_run_all.R"))
