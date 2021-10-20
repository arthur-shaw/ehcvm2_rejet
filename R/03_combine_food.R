# =============================================================================
# Define utility functions
# =============================================================================

#' Ingest all Stata files that match a pattern
#' 
#' @param path Character. Path where Stata files can be found.
#' @param pattern Characetr. Regular expression that identifies Stata files in `path` directory.
#' 
#' @return List of data frames
#' 
#' @importFrom fs dir_ls
#' @importFrom cli cli_alert_info cli_bullets
#' @importFrom purrr map
#' @importFrom haven read_dta
#' 
#' @export 
ingest_matching_files <- function(
    path,
    pattern
) {

    # find files
    files <- fs::dir_ls(path = path, recurse = FALSE, type = "file", regexp = pattern)

    # print info message about files found
    cli::cli_alert_info("Matching found files: ")
    cli::cat_bullet(fs::path_file(files), bullet = "line")

    dfs <- purrr::map(
        .x = files,
        .f = ~ haven::read_dta(file = .x)
    )

    return(dfs)

}

#' Extract value labels from all labelled variables
#' 
#' First, determines which variables are labelled. 
#' Then, extracts the labels
#' Next, creates a named list: names are variable names; values are associated labels. 
#' Then, creates a label object in the global environment whose name is the `{df}_lbls`.
#' 
#' @param df Data frame whose value labels to extract
#' @param type Character. Type of label: "labels", value labels; or "label", variable label.
#' 
#' @return List of value labels. Each element is a named numeric vector. Each vector consists of a named values. The names correspond to character labels and the values to the numerical values.
#' 
#' @importFrom purrr map_lgl map
#' @importFrom haven is.labelled
#' 
#' @export 
extract_labels <- function(
    df,
    type = "labels"
) {

    # get list of all variable names
    vars_in_df <- names(df)

    # determine--TRUE/FALSE--which have labels
    which_have_labels_lgl <- purrr::map_lgl(
        .x = vars_in_df, 
        .f = ~ haven::is.labelled(df[[.x]]))

    # return the names of those variables with labels
    which_have_labels_names <- names(df)[which_have_labels_lgl]

    # extract labels for each variable into a list
    all_labels <- purrr::map(
        .x = which_have_labels_names,
        .f = ~ attr(x = df[[.x]], which = type)
    )

    # create a named list: name is variable name; value is corresponding labels
    labels_named <- stats::setNames(
        nm = which_have_labels_names,
        object = all_labels
    )

}

#' Combine raw extracted labels into unique labels
#' 
#' @param label_list List of labels returned by `extract_labels`
#' 
#' @importFrom purrr pmap modify
#' 
#' @export 
combine_val_labels <- function(
    label_list
) {

    # concatenate labels into a single list of named labels
    # where each element of the list corresponds to 
    combined_labels <- purrr::pmap(
        .l = unname(label_list), 
        .f = c
    )

    # create list of unique labels
    # remove duplicate labels by modify each vector by removing duplicates
    unique_labels <- purrr::modify(
        .x = combined_labels, 
        .f = ~ .x[!duplicated(.x)]
    )

    return(unique_labels)

}

#' Apply value label variables to variables
#' 
#' Apply labels to all variables in the data frame that need them. To do this:
#' 
#' First, determine the variables that have labels for them in the list of labels.
#' Then, apply those labels to each column
#' 
#' @param df Data frame
#' @param label_list List that contains the consolidated labels
#' 
#' @return Data frame with labelled columns
#' 
#' @importFrom dplyr `%>%` mutate across all_of cur_column
#' @importFrom haven labelled
apply_val_labels <- function(
    df,
    label_list
) {

    # extract variable names from label list
    vars_to_label <- names(label_list)

    # apply labels to columns 
    df <- df %>%
        dplyr::mutate(
            dplyr::across(
                .cols = dplyr::all_of(vars_to_label),
                .fns = ~ haven::labelled(
                    .x, 
                    labels = label_list[[dplyr::cur_column()]]
                )
            )
        )

    return(df)

}

# =============================================================================
# Check that necessary objects exist
# =============================================================================

if (!exists("data_dir")) {
    stop("The folder `data_dir` has not been defined.")
}

# =============================================================================
# Load necessary libraries
# =============================================================================

library(dplyr)
library(purrr)
library(stringr)

# =============================================================================
# Define utility functions
# =============================================================================

# ingest all consumption as a list of data frames
# so that renaming functions can be applied to all data frames
food_dfs_raw <- ingest_matching_files(
    path = combined_dir, 
    pattern = "cereales|viandes|poissons|huiles|laitier|fruits|legumes|legtub|sucreries|epices|boissons"
)

# harmonize variable names across files
# so that all data frames can be combined
food_dfs_renamed <- purrr::map(
    .x = food_dfs_raw,
    .f = ~ .x %>%
        dplyr::rename_with(
            .fn = ~ stringr::str_replace(., pattern = "(?<=_autre)_[a-z]+|(?<=3[abc])_[a-z]+|(?<=7[abc])_[a-z]+|(?<=0[4568])_[a-z]+", "")
        ) %>%
        dplyr::rename_with(
            .fn = ~ stringr::str_replace(., pattern = "(cereales|viandes|poissons|huiles|laitier|fruits|legumes|legtub|sucreries|epices|boissons)__id", "aliment__id")
        )
)

# extract all values labels into a list where each element is a set of variable labels
# so that labels can can be combined across data frames
food_labels_all <- purrr::map(
    .x = food_dfs_renamed,
    .f = ~ extract_labels(df = .x)
)

# combine all labels
# so that a single set of value labels are applied to the combined data frame
food_labels <- combine_val_labels(label_list = food_labels_all)

# combine all data frames
# so that the output is a single data frame
food_df <- dplyr::bind_rows(food_dfs_renamed)

# apply value labels to each variable
# so that the output data frame uses comprehensive labels
food_df <- apply_val_labels(
    df = food_df,
    label_list = food_labels
)

# remove intermediary objects
# both to lighten the memory load and to avoid confusion over objects
rm(food_dfs_raw, food_dfs_renamed, food_labels, food_labels_all)
