### Quality check function ###
## Some records had been falsely included or excluded. The following function
## identifies which records, based on doi have been incorrectly labeled and 
## adds a column for each type of mistake:
## quality_check_1 = those records which have been falsely excluded
## quality_check_2 = those records which have been falsely included
## The values within the column indicate for which subject the mistake has been 
## made:
## 1 = anxiety
## 2 = depression
## 3 = substance_abuse


####### For testing ########
# df_original <-  df # after deduplication save the dataset
# df <- df_original # after making a mistake you can now easily go back to it
# error_set <- anxiety_q1 # to test the deduplication of titles
############################

# Unfortunately, doi matching can not be used, because there are also many
# missing doi's present in both the quality check datasets as well as the 
# merged dataset. Hence, the following matching is based on title.

quality_check <- function(df){
  
  ## Quality check 1 ##
  # Excluded records that should have been included. 

  # Step 1 deduplication for those where the doi is present:
  # Deduplicate the merged dataset based on titles only for those records that
  # should be altered according to the quality check datasets. 
  df <- deduplicate_titles(df, anxiety_q1)
  df <- deduplicate_titles(df, depression_q1)
  df <- deduplicate_titles(df, substance_q1)
  
  # Step 2:
  # Find the rows in the merged dataframe that should be adapted, without
  # duplicates, matched on title
  anx_error_1  <- df[which(df$title %in% anxiety_q1$title), ] 
  depr_error_1 <- df[which(df$title %in% depression_q1$title), ]
  sub_error_1  <- df[which(df$title %in% substance_q1$title), ]
  
  # Step 3:
  # Add a column to df called `quality_check_1(0->1)`, where:
  # 1 = anxiety
  # 2 = depression
  # 3 = substance-abuse
  # NA = No change needed
  # Add columns with the corrected labels.
  
  df <-
    df %>% mutate(
      `quality_check_1(0->1)` = case_when(
        df$index %in% anx_error_1$index  ~ 1,
        df$index %in% depr_error_1$index ~ 2,
        df$index %in% sub_error_1$index  ~ 3,
        TRUE ~ NA_real_
      ),
      anxiety_included_corrected = case_when(`quality_check_1(0->1)` == 1 ~ 1,
                                             TRUE ~ anxiety_included),
      depression_included_corrected = case_when(`quality_check_1(0->1)` == 2 ~ 1,
                                                TRUE ~ depression_included),
      substance_included_corrected = case_when(`quality_check_1(0->1)` == 3 ~ 1,
                                               TRUE ~ substance_included)
    )
  
  
  ## Quality check 2 ##
  # Included records that should have been excluded 
  
  # Step 1 deduplication for those where the doi is present:
  # Deduplicate the merged dataset based on titles only for those records that
  # should be altered according to the quality check datasets. 
  df <- deduplicate_titles(df, anxiety_q2)
  df <- deduplicate_titles(df, substance_q2)
  df <- deduplicate_titles(df, depression_q2)
  
    # Step 2:
  # Find the rows in the merged dataframe that should be adapted, without
  # duplicates, matched on title
  
  anx_error_2  <- df[which(df$title %in% anxiety_q2$title), ] 
  depr_error_2 <- df[which(df$title %in% depression_q2$title), ]
  sub_error_2  <- df[which(df$title %in% substance_q2$title), ]
  
  # THE PROBLEM HERE IS WITH DEPRESSION, SOME TITLES ARE NA, HENCE A TOO LARGE
  # SET IS RETURNED! THEREFORE, THOSE RECORDS IN DEPRESSION_Q2 WITHOUT A TITLE
  # SHOULD BE MATCHED ON RECORD_ID OR SOMETHING. 
  
  
  # Step 3:
  # Add a column to df called `quality_check_2(1->0)`, where:
  # 1 = anxiety
  # 2 = depression
  # 3 = substance-abuse
  # NA = No change needed
  
  df <- df %>% mutate(`quality_check_2(1->0)` = case_when(df$index %in% anx_error_2$index  ~ 1,
                                                          df$index %in% depr_error_2$index ~ 2,
                                                          df$index %in% sub_error_2$index  ~ 3,
                                                          TRUE ~ NA_real_),
                      
                      )
  
  
  return(df)
  
}
