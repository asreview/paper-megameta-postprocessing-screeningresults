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
    
    # select a pair of duplicates
    dup_set <- doi_set[which(doi_set$dup_id == i),] 
    
    # determine the row of the set to which all information
    # of the duplicates will be saved.
    needed_row <- which(dup_set$unique_record == 1) 
    keep_index <- dup_set$index[needed_row] # finds the index of this row to keep
    remove_index <- dup_set$index[-needed_row] 
    
    # MERGING CODE HERE
    
    # REPLACE THE ROW IN DF WITH THE MERGED ONE
    df[which(df$index == keep_index),] # <-  replace with merged row
    
    # REMOVE DUPLICATE ROW
    df <- df[-which(df$index == remove_index),]
  }

  return(df)
}

## MERGING CODE WORK IN PROGRESS!!

# Define merging rules:
# A 1 in any of the columns should overwrite an NA or 0.
# A 0 should overwrite an NA
# Both NA? Should stay NA? <- This is the question that remains.. 

# Simple solution for the three subjects is to sum the results:
# The columns to be merged are
cols_merge <- c("depression_included", "substance_included", "anxiety_included", "final_included")

############################################################
# The problem is that NA's become 0, but does that matter? #
############################################################

dup_set %>% 
  summarise(across(cols_merge, sum, na.rm = T)) %>%
  mutate(final_included = case_when(final_included > 1 ~ 1, TRUE ~ final_included))
  # With the last row, final_included is max. 1     

