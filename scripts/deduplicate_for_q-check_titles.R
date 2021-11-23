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
  for(i in 1:max(title_set$dup_id)){
    
    # select a pair of duplicates
    dup_set <- title_set[which(title_set$dup_id == i),] 
    
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
    
    # Obtain the merged value(s)
    dup_set[which(dup_set$index == keep_index), cols_merge_final] <-
      dup_set %>%
      select(all_of(cols_merge_final), title) %>%
      summarise(across(cols_merge_final, sum, na.rm = T)) %>%
      select(!title)
    
    # Precaution for all labels: 
    # they should not exceed 1!
    # Moreover, Composite label should be recalculated
    # Should be NA when all cols are NA
    dup_set[which(dup_set$index == keep_index), cols_merge] <-
      dup_set[which(dup_set$index == keep_index), ] %>%
      select(cols_merge) %>%
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
    dedup_values <- dup_set[which(dup_set$index == keep_index), cols_merge_final]
    
    
    # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
    df[which(df$index == keep_index), cols_merge_final] <- dedup_values
    
    # REMOVE DUPLICATE ROW(S)
    df <- df[-which(df$index %in% remove_index),]
    
  } # close for loop
  
  return(df)
  
  } else {
    
    return(df)
    
  }
  
  
  
  
} # close deduplication function
