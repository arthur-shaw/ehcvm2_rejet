# =============================================================================
# Check that necessary objects exist
# =============================================================================

objects_needed <- c(
    "download_dir"
)

check_exists(objects_needed)

# =============================================================================
# Check that zip files exist in download folder
# =============================================================================

downloaded_files <- fs::dir_ls(
    path = download_dir,
    recurse = FALSE,
    type = "file",
    regexp = "\\.zip$"
)

if (length(downloaded_files) == 0) {
    stop(glue::glue("No .zip files found in the download folder: {download_dir}"))
}

# =============================================================================
# Load necessary libraries
# =============================================================================

library(dplyr)

# =============================================================================
# Unpack data
# =============================================================================

# -----------------------------------------------------------------------------
# Define function
# -----------------------------------------------------------------------------

#' Unpack zip file to a folder bearing its name
#' 
#' Rather than unpack a file to the directory in which the file sits,
#' create a folder with the file's name (minus extension) and 
#' unpack its contents there.
#' 
#' @param zipfile Character. Full file path of the zip file.
#' 
#' @return Side-effect of creating a folder and unpacking zip contents there.
#' 
#' @importFrom fs path_dir path_file path_ext_remove
#' @importFrom zip unzip
unpack_to_dir <- function(zipfile) {

    parent_dir <- fs::path_dir(zipfile)
    file_name <- fs::path_file(zipfile)
    unpack_name <- fs::path_ext_remove(file_name) 
    unpack_dir <- paste0(parent_dir, "/", unpack_name, "/")

    zip::unzip(
        zipfile = zipfile,
        exdir = unpack_dir
    )
}

# -----------------------------------------------------------------------------
# Execute decompression
# -----------------------------------------------------------------------------

# obtain list of zip files
files <- fs::dir_ls(
    path = download_dir, 
    type = "file", 
    regexp = "\\.zip$", 
    recurse = FALSE
)

# unpack all identified zip files
purrr::walk(
    .x = files,
    .f = ~ unpack_to_dir(.x)
)

# =============================================================================
# Combine and save Stata data
# =============================================================================

# -----------------------------------------------------------------------------
# Define function
# -----------------------------------------------------------------------------

#' Combine and save Stata data files
#' 
#' @param file_info_df Data frame. Return value of `fs::file_info()` that contains an additioal column `file_name`.
#' @param name Character. Name of the file (with extension) to ingest from all folders where it is found.
#' @param dir Character. Directory where combined data will be saved.
#' 
#' @return Side-effect of creating data frame objects in the global environment with the name `name`.
#' 
#' @importFrom dplyr `%>%` filter pull
#' @importFrom purrr map_dfr
#' @importFrom haven read_dta
#' @importFrom fs path_ext_remove
combine_and_save <- function(
    file_info_df,
    name,
    dir
) {

    # file paths
    # so that can locate data files to combine
    file_paths <- file_info_df %>%
        dplyr::filter(.data$file_name == name) %>%
        dplyr::pull(path)

    # data frame
    # so that can assign this value to a name
    df <- purrr::map_dfr(
            .x = file_paths,
            .f = ~ haven::read_dta(file = .x)
        )

    # TODO: attempt to add tryCatch above
    # so if any fail, there will be a list of where it fails and why

    # assign df to a name in the global environment
    # so that can loop over names without
    # assign(
    #     x = fs::path_ext_remove(name),
    #     value = df,
    #     envir = .GlobalEnv
    # )

    # save to destination directory
    haven::write_dta(data = df, path = paste0(dir, name))

}

# -----------------------------------------------------------------------------
# Execute appending of same-named files
# -----------------------------------------------------------------------------

# obtain list of all directories of unpacked zip files
dirs <- fs::dir_ls(
    path = download_dir, 
    type = "directory", 
    recurse = FALSE
)

# compile list of all Stata files in all directories
files_df <- purrr::map_dfr(
        .x = dirs,
        .f = ~ fs::dir_info(
            path = .x, 
            recurse = FALSE,
            type = "file",
            regexp = "\\.dta$"
        )
    ) %>%
    dplyr::mutate(file_name = fs::path_file(path))

# extract a list of all unique files found in the directories
file_names <- files_df %>%
    dplyr::distinct(file_name) %>%
    dplyr::pull(file_name)

# combine and save all same-named Stata files
purrr::walk(
    .x = file_names,
    .f = ~ combine_and_save(
        file_info_df = files_df,
        name = .x,
        dir = combined_dir
    )
)


