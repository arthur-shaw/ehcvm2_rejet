# =============================================================================
# Define function for checking that necessary objects exist
# =============================================================================

check_exists <- function(object_names) {
    names_sought <- object_names
    names_found <- purrr::map_lgl(
        .x = names_sought,
        .f = ~ exists(.x)
    )
    names_missing <- names_sought[!names_found]
    if (length(names_missing) > 0) {
        
        missing_list <- glue::glue_collapse(
            glue::glue("{glue::backtick(names_missing)}"), 
            sep = ", ", 
            last = ", et "
        )
        
        stop(glue::glue("Les objects suivant sont absents: {missing_list}"))
        
    }
}

# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "proj_dir"
)

check_exists(objects_needed)

# =============================================================================
# Folders for scripts
# =============================================================================

# scripts
script_dir <- paste0(proj_dir, "R/")

# =============================================================================
# Run scripts in required order
# =============================================================================

# prepare
# - set file paths
# - purge prior data
print("---- 00 Prépratifs -----")
source(paste0(script_dir, "00_setup.R"))

# get data
# - fetch
print("---- 01 Obtention des données -----")
source(paste0(script_dir, "01_get_data.R"))

# combine data
# - unpack data
# - combine and save unzipped Stata data
print("---- 02 Jonction des bases de différentes versions -----")
source(paste0(script_dir, "02_combine_data.R"))

# combine food consumption data
# - ingest all food files
# - harmonize variable names in files
# - extract, combine, and apply value labels
print("---- 03 Jonction des bases de consommation alimentaire -----")
source(paste0(script_dir, "03_combine_food.R"))

# identify cases to review
# - create frame of all cases to review
# - create data sets for filtering
print("---- 04 Identification des entretiens à valider -----")
source(paste0(script_dir, "04_cases_to_review.R"))

if (nrow(cases_to_review) == 0) {
    warning("Actuellement, il n'y a aucun entreten à valider")
} else {

# compute calories
print("---- 04b Calculer les calories -----")
source(paste0(script_dir, "04b_calculate_calories.R"))

# compile attributes
print("---- 05 Compilation d'attributs -----")
source(paste0(script_dir, "05_compile_attributes.R"))

# compile issues
# - from attributes and microdata
# - from interview metadata
print("---- 06 Compilation d'erreurs -----")
source(paste0(script_dir, "06_compile_issues.R"))

# make decisions
# - what to reject
# - wht to review
print("---- 07 Prise de décision sur les actions à prendre -----")
source(paste0(script_dir, "07_make_decisions.R"))

# execute decisions
# - post comments to individual questions
# - reject interviews
if (should_reject == TRUE) {
print("---- 08 Exécution des rejets -----")
source(paste0(script_dir, "08_execute_decisions.R"))
}

# save decisions to disk
print("---- 09 Sauvegarde des décisions sur disque -----")
source(paste0(script_dir, "09_save_results.R"))

}
