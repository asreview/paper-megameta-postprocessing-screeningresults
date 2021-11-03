deduplicate <- function(df){
  # Remove irrelevant duplicates
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
    dup_set <- doi_set[which(doi_set$dup_id == i),]
    needed_row <- which(dup_set$unique_record == 1)
    needed_index <- dup_set$index[needed_row]
    df_row <- which(df$index == needed_index)
    
    # Determine which row needs a one
    
    # Remove duplicate
  }

  return(df)
}