######## Retrieve and print information ############

### Print information on inclusions and exclusions.
included_excluded <- function (df,name, included_column){
  
  cat(paste0("The ", name, " dataset contains ", nrow(df), " records.\n",
            "Of which there are: \n", 
            nrow(df %>% filter(included_column == 1)), " included records. \n",
            nrow(df %>% filter(included_column == 0)), " excluded records.",
            "\n \n",
            "This dataset also contains:\n",
            length(which(!is.na(df$title))), "/", nrow(df), " titles, which is ", # number of titles
            length(which(!is.na(df$title)))/nrow(df)*100,"%. \n",# percentage of present titles
            length(which(!is.na(df$abstract))), "/", nrow(df), " abstracts, which is ", # number of abstracts
            length(which(!is.na(df$abstract)))/nrow(df)*100 , "%. \n", # percentage of present abstracts
            length(which(!is.na(df$doi))), "/", nrow(df), " doi's, which is ", # number of doi's
            length(which(!is.na(df$doi)))/nrow(df)*100,"%. \n" # percentage of present doi's.
  ))
  
  
  
  
}
