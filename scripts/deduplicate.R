deduplicate <- function(df){
  # Remove irrelevant duplicates
  df <- filter(df, final_included == 1 | unique_record == 1 | is.na(unique_record))
  
  return(df)
}