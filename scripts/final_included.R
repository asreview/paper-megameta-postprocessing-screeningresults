final_included <- function(df){
  # Create a column with the final inclusions
  df$final_included <- 0
  for(i in 1:length(df$depression_included)){
    if(df$depression_included[i] == 1 & !is.na(df$depression_included[i]) || 
       df$substance_included[i] == 1 & !is.na(df$substance_included[i]) ||
       df$anxiety_included[i] == 1 & !is.na(df$anxiety_included[i])){df$final_included[i] <- 1}
  }
  
  return(df)
}