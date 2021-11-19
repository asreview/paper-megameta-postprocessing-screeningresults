deduplicate <- function(df){
  
  # Create a subset of the duplicates
  df_doi <- filter(df, !is.na(doi))
  df_dup <- get_dupes(df_doi, doi)
  
  # Determine sets of duplicates
  doi_set <- df_dup %>% 
    group_by(doi) %>%
    mutate(dup_id = cur_group_id())

  # Merge duplicate rows
  for(i in 1:max(doi_set$dup_id)){
     
    # Add a counter:
    print(paste("deduplicating set", i, "out of", max(doi_set$dup_id)))
    
    # select a pair of duplicates
    dup_set <- doi_set[which(doi_set$dup_id == i),] 
    
    # determine the row of the set to which all information
    # of the duplicates will be saved.
    needed_row <- which(dup_set$unique_record == 1) 
    keep_index <- dup_set$index[needed_row] # finds the index of this row to keep
    remove_index <- dup_set$index[-needed_row] 
    
    ## MERGING CODE ##
    
    # Simple solution to merge the information across the duplicated rows is 
    # to sum the results:
    # The subject columns to be merged are
    cols_merge <- c("doi", "depression_included", "substance_included", "anxiety_included", "composite_label")
    # "doi" is added as a grouping variable
    
    # First find the columns which should be merged,
    # This should not be a column in which there are no values!
    # In other words, only the columns which have at least 1 value should be
    # included. (If not, the sum function will just put a 0, meaning that information
    # will be lost about which records were seen in what databases)
    cols_merge_final <- colnames(dup_set %>% 
                                   select(all_of(cols_merge)) %>%
                                   select(where(function(x) sum(is.na(x)) < nrow(dup_set))) %>%
                                   ungroup() %>%
                                   select(!doi)
                                 )
    
    # Obtain the merged value(s)
    dup_set[which(dup_set$index == keep_index), cols_merge_final] <-
      dup_set %>%
      select(all_of(cols_merge_final), doi) %>%
      summarise(across(cols_merge_final, sum, na.rm = T)) %>%
      select(!doi)
    
    # Precaution for all labels: 
    # they should not exceed 1!
    # Moreover, Composite label should be recalculated
    # Should be NA when all cols are NA
    dup_set[which(dup_set$index == keep_index), cols_merge] <-
      dup_set[which(dup_set$index == keep_index), ] %>%
      select(cols_merge) %>%
      mutate(
        depression_included = case_when(depression_included > 1 ~ 1
                                        TRUE ~ depression_included),
        substance_included = case_when(substance_included > 1 ~ 1
                                       TRUE ~ substance_included),
        anxiety_included = case_when(anxiety_included > 1 ~ 1
                                     TRUE ~ anxiety_included),
        composite_label = case_when(
          df$depression_included == 1 & !is.na(df$depression_included) ~ 1,
          df$substance_included == 1 &
            !is.na(df$substance_included) ~ 1 ,
          df$anxiety_included == 1 &
            !is.na(df$anxiety_included) ~ 1,
          df$depression_included == 0 &
            !is.na(df$depression_included) ~ 0,
          df$substance_included == 0 &
            !is.na(df$substance_included) ~ 0,
          df$anxiety_included == 0 &
            !is.na(df$anxiety_included) ~ 0,
          TRUE ~ NA_real_
        )
      )
    
    # Select only the columns which have changed values
    dedup_values <- dup_set[which(dup_set$index == keep_index), cols_merge_final]
    
    # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
    df[which(df$index == keep_index), cols_merge_final] <- dedup_values
    
    # REMOVE DUPLICATE ROW(S)
    df <- df[-which(df$index %in% remove_index),]
  }

  return(df)
}
