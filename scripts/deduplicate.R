deduplicate <- function(df){
  # Remove irrelevant duplicates
  df <- filter(df, final_included == 1 | unique_record == 1 | is.na(unique_record))
  
  # Create a subset of the duplicates
  df_doi <- filter(df, !is.na(doi))
  df_dup <- get_dupes(df_doi, doi)
  
  return(df)
}