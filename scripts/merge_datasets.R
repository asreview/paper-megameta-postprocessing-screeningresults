merge_datasets <- function(...){ #Input is the three datasets as a list
  # Create unique included columns
  names <- list("depression", "substance", "anxiety")
  for(i in 1:length(list(...))){
    df <- list(...)[[i]]
    df[, paste(names[[i]], "included", sep = "_")] <- df$included
    assign(paste("df", i, sep = "_"), df)
  }
  
  # Merge the datasets
  df <- bind_rows(df_1, df_2, df_3)
}

## Improvement of the script should focus on:
#  - Having the user specify the names of the datasets to make it more generic.