merge_datasets <- function(...){
  # Create unique included collumns
  names <- list("depression", "substance", "anxiety")
  for(i in 1:length(list(...))){
    df <- list(...)[[i]]
    df[, paste(names[[i]], "included", sep = "_")] <- df$included
    assign(paste("df", i, sep = "_"), df)
  }
  
  # Merge the datasets
  df <- bind_rows(df_1, df_2, df_3)
}