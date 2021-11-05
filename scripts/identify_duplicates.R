identify_duplicates <- function(df){
  # Add an index
  df$index <- 1:length(df$depression_included)
  
  # Split the data into a dataset with and without missing dois
  df_doi <- df %>%
    filter(!is.na(doi))
  
  df_non_doi <- df %>%
    filter(is.na(doi))
  
  # Rearrange such that the record with the longest abstract will be the record marked as 'unique'
  df_doi_unq <- df_doi %>%
    arrange(desc(str_length(abstract)))
  
  # Add a column showing which record is unique
  df_doi_unq <- df_doi_unq %>% mutate(
    unique_record = duplicated(doi),
    unique_record = case_when(unique_record == FALSE ~ 1, TRUE ~ 0)
  )
  
  # Bind the dataframes with and without dois back together
  df <- bind_rows(df_non_doi, df_doi_unq)
  
  # Sort the dataframe based on the index
  df <- df %>%
    arrange(index)
  
  return(df)
}