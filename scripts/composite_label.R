composite_label <- function(df){
  # Create a column with the final inclusions
  df <- df %>%
    mutate(composite_label = case_when(
      df$depression_included == 1 & !is.na(df$depression_included) ~ 1,
      df$substance_included == 1 & !is.na(df$substance_included) ~ 1 ,
      df$anxiety_included == 1 & !is.na(df$anxiety_included) ~ 1,
      df$depression_included == 0 & !is.na(df$depression_included) ~ 0,
      df$substance_included == 0 & !is.na(df$substance_included) ~ 0,
      df$anxiety_included == 0 & !is.na(df$anxiety_included) ~ 0,
      TRUE ~ NA_real_
    ))
  
  return(df)
}
