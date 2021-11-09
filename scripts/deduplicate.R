deduplicate <- function(df){
  
  # Remove irrelevant duplicates
  # Irrelevant duplicates are those where there is no final_inclusion
  df <- filter(df, final_included == 1 | unique_record == 1 | is.na(unique_record))
  
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
    # The columns to be merged are
    cols_merge <- c("doi", "depression_included", "substance_included", "anxiety_included", "final_included")
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
    
    # Obtain the merged values
    dedup_values <- dup_set %>%
      select(all_of(cols_merge_final), doi) %>%
      summarise(across(cols_merge_final, sum, na.rm = T)) %>%
      mutate(final_included = case_when(final_included > 1 ~ 1, TRUE ~ final_included)) %>%
      # With the line above, final_included is max. 1     
      select(!doi)
    
    
    # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
    df[which(df$index == keep_index), cols_merge_final] <- dedup_values
    
    # REMOVE DUPLICATE ROW(S)
    df <- df[-which(df$index %in% remove_index),]
  }

  return(df)
}
