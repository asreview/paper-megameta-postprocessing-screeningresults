## Deduplication title ##

# Only used for the quality check part!

# Unfortunately, doi matching can not be used, because there are also many
# missing doi's present in both the quality check datasets as well as the 
# merged dataset. Hence, the following matching is based on title.

# Because deduplication only took place on matching dois, we may now
# still encounter duplicates, but on the title level.
# So before the correction function can be used, let's start with a deduplication
# function. This function only uses the elements from the deduplicate.R 
# script.

deduplicate_q_check <- function(df, error_set){

  # CREATE COUNTERS FOR NUMBER OF DUPLICATES
  n_labeled_dupes <- 0
  n_no_label_dupes <-  0
  
  # COLLECT THE NAME OF THE DATASET THAT IS CURRENTLY CHECKED
  error_set_name <- deparse(substitute(error_set))
  
  # First make sure that there are no empty titles
  ## If there are, they should be replaced with NA
  error_set$title <- ifelse(str_length(error_set$title) < 2, NA, error_set$title) 
  ## Retrieve those rows where a title is present:
  error_set_titles <- error_set[which(!is.na(error_set$title)), ]
  
  # Only apply deduplication to those titles present in the
  # quality check dataset.
  df_partly <- df[which(df$title %in% error_set_titles$title), ] 
  
  ## Check if there are any duplicates:
  if (any(duplicated(df_partly$title))){
 
  # find the duplicated titles
  df_dup <- get_dupes(df_partly, title)

  # Add an indicator for each set of duplicates
  title_set <- df_dup %>% 
    group_by(title) %>%
    mutate(dup_id = cur_group_id())
  
  # Merge duplicate rows
  for(i in seq(unique(title_set$dup_id))){
    
    # select a pair of duplicates
    dup_set <- title_set[which(title_set$dup_id == i),] 
    
    # Check manually whether the records are indeed duplicates
    cat("Possibly duplicated titles:\n", paste0(dup_set$title, collapse = "\n"), "\n \n",
          "Abstract:\n", paste0(dup_set$abstract, collapse = "\n \n"), "\n \n",
          "Authors:\n", paste0(dup_set$authors, collapse = "\n \n"), "\n \n",
          "Year:\n", paste0(dup_set$year, collapse = "\n"), "\n \n",
          "Journal:\n", paste0(dup_set$secondary_title, collapse = "\n"))
    
    input_user <- readline(prompt = "Is this an actual duplicate? Y or N?" )
    input_user <- as.character(input_user)
    
    if (input_user == "Y"){ 
    
    # determine the row of the set to which all information
    # of the duplicates will be saved (the one with the longest abstract)
    dup_set <- dup_set %>%
      arrange(desc(str_length(abstract)))
    # determine the row of the set to which all information
    # of the duplicates will be saved.
    keep_index <- dup_set$index[1] # takes the top row.
    # Index of the row to remove
    remove_index <- dup_set$index[-1] 
    
    # Columns to merge in general
    cols_merge <-
      c(
        "title",
        "depression_included",
        "substance_included",
        "anxiety_included",
        "composite_label"
      )
    
    # Which columns to merge specifically for this set
    cols_merge_final <- colnames(dup_set %>%
                                   select(all_of(cols_merge)) %>%
                                   select(where(function(x)
                                     sum(is.na(
                                       x
                                     )) < nrow(dup_set))) %>%
                                   ungroup() %>%
                                   select(!title)
    ) # close cols_merge_final
    
    # In case the composite label is present in cols_merge_final,
    # we know that at least one of the duplicates has been labeled for at least
    # one subject. 
    
    if ("composite_label" %in% cols_merge_final) {
      
      # Merging the rows has to take into account the aggregation of the
      # labels.
      
      # Obtain the merged value(s)
      dup_set[which(dup_set$index == keep_index), cols_merge_final] <-
        dup_set %>%
        select(all_of(cols_merge_final), title) %>%
        summarise(across(all_of(cols_merge_final), sum, na.rm = T)) %>%
        select(!title)
      
      # Precaution for all labels:
      # they should not exceed 1!
      # Moreover, Composite label should be recalculated
      # Should be NA when all cols are NA
      dup_set[which(dup_set$index == keep_index), cols_merge] <-
        dup_set[which(dup_set$index == keep_index),] %>%
        select(all_of(cols_merge)) %>%
        mutate(
          depression_included = case_when(depression_included > 1 ~ 1,
                                          TRUE ~ depression_included),
          substance_included = case_when(substance_included > 1 ~ 1,
                                         TRUE ~ substance_included),
          anxiety_included = case_when(anxiety_included > 1 ~ 1,
                                       TRUE ~ anxiety_included),
          composite_label = case_when(
            depression_included == 1 & !is.na(depression_included) ~ 1,
            substance_included == 1 &
              !is.na(substance_included) ~ 1 ,
            anxiety_included == 1 &
              !is.na(anxiety_included) ~ 1,
            depression_included == 0 &
              !is.na(depression_included) ~ 0,
            substance_included == 0 &
              !is.na(substance_included) ~ 0,
            anxiety_included == 0 &
              !is.na(anxiety_included) ~ 0,
            TRUE ~ NA_real_
          )
        )
      
      # Select only the columns which have changed values
      dedup_values <-
        dup_set[which(dup_set$index == keep_index), cols_merge_final]
      
      
      # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
      df[which(df$index == keep_index), cols_merge_final] <-
        dedup_values
      
      # REMOVE DUPLICATE ROW(S)
      df <- df[-which(df$index %in% remove_index), ]
      
      # ADD ONE TO COUNTER OF LABELED DUPES
      n_labeled_dupes <- n_labeled_dupes + 1
      
    } else {
      
      # If none of the duplicates have received any label, deduplication is easy!
      # The rows which can be removed according to remove_index can simply be deleted:
      df <- df[-which(df$index %in% remove_index),]
      
      # ADD ONE TO COUNTER OF UNLABELED DUPES
      n_no_label_dupes <- n_no_label_dupes + 1
     } # close else statement
    
    
    } # close checking whether the duplicate is a duplicate
    
  } # close for loop

  cat(
    paste0(
      "In total ",
      n_labeled_dupes + n_no_label_dupes,
      " sets were deduplicated based on title for ", error_set_name, " of which: \n",
      n_labeled_dupes,
      " (",
      round(n_labeled_dupes/max(dup_set$dup_id)*100, 2),
      "%) sets had at least one label \n",
      n_no_label_dupes,
      " (",
      round(n_no_label_dupes/max(dup_set$dup_id)*100, 2),
      "%) sets had no label at all.\n"
    )
  ) 
  
  return(df)
  
  } else {
    
    cat(paste(
      "No duplicates identified and removed through title deduplication for", error_set_name, ".\n"
    ))
    
    return(df)
    
  } # close else statement to check whether there are any duplicates
  
} # close deduplication function
