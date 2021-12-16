######## Retrieve and print information ############

### Print information on inclusions and exclusions.
info_datasets <- function (df,name, included_column){
  
  cat(paste0("The ", name, " dataset contains ", nrow(df), " records.\n",
            "Of which there are: \n", 
            nrow(df %>% filter(included_column == 1))," (", # number of included records
            round(nrow(df %>% filter(included_column == 1))/nrow(df)*100,2), "%) included records. \n", # percentage of included records
            nrow(df %>% filter(included_column == 0)), " (", # number of excluded records
            round(nrow(df %>% filter(included_column == 0))/nrow(df)*100,2),"%) excluded records.", # percentage of excluded records
            
            "\n \n",
            "This dataset also contains:\n",
            nrow(df %>% filter(!is.na(title))), "/", nrow(df), " titles, which is ", # number of titles
            round(nrow(df %>% filter(!is.na(title)))/nrow(df)*100, 2),"%. \n",# percentage of present titles
            nrow(df %>% filter(!is.na(abstract))), "/", nrow(df), " abstracts, which is ", # number of abstracts
            round(nrow(df %>% filter(!is.na(abstract)))/nrow(df)*100, 2) , "%. \n", # percentage of present abstracts
            nrow(df %>% filter(!is.na(doi))), "/", nrow(df), " doi's, which is ", # number of doi's
            round(nrow(df %>% filter(!is.na(doi)))/nrow(df)*100, 2),"%. \n" # percentage of present doi's.
  ))
  
  
  
  
}
