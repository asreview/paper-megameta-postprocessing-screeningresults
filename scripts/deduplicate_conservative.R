deduplicate_conservative <- function(df){
  
  # Create a copy of df
  df_1 <- df
  
  # Create counters for number of duplicates:
  n_labeled_dupes <- 0
  n_no_label_dupes <-  0
  
  # For the conservative deduplication round there are 4 steps:
  
  ### 1. Cleaning data before deduplication ###
  # Set strings in relevant columns to lowercase
  df_1 <- df_1 %>% mutate(issn = str_to_lower(as.character(issn)),
                          authors = str_to_lower(authors),
                          secondary_title = str_to_lower(secondary_title), # this column contains the jounal names
                          title = str_to_lower(title)
                          )
  
  # Remove all punctuation charachters
  df_1 <- df_1 %>% mutate(issn = str_replace_all(issn, "[[:punct:]]", ""),
                          authors = str_to_lower(authors),
                          secondary_title = str_replace_all(secondary_title, "[[:punct:]]", ""),
                          title = str_replace_all(title, "[[:punct:]]", "")
                          )
  
  # For the less conservative deduplication,
  # keep only the rows where there are no missing values for 
  # - title
  # - authors
  # - year
  df_1_no_NA <- 
    df_1 %>%
    filter_at(vars(title, authors, year), all_vars(!is.na(.)))
  
  # Add issn
  df_1_issn <-
    df_1 %>%
    filter_at(vars(issn, title, authors, year), all_vars(!is.na(.)))
  
  # Add the journal name (= secondary_title)
  df_1_journal <-  df_1 %>%
    filter_at(vars(secondary_title, title, authors, year), all_vars(!is.na(.)))
  
  ### 2. Count conservative duplicates ###  
  # Now let's find those rows where
  # Those where the issn is duplicated
  cons_1 <- df_1_issn %>% get_dupes(issn, title, authors, year)
  
  # Those where the exact journal name is duplicated
  cons_2 <- df_1_journal %>% get_dupes(c(secondary_title, title, authors, year))
  
  # Find the symmetric differences between cons_1 and cons_2
  symdiff <- function(x, y) {
    setdiff(union(x, y), intersect(x, y))
  }
  
  cons_dupes <- unique(symdiff(cons_1, cons_2))
  
  # Still there might be some index values duplicated.
  # Indexes cannot contain duplicates, because they were uniquely assigned
  # during the post-processing.
  # So let's double check and remove double index cases
  cons_dupes <- cons_dupes[!duplicated(cons_dupes$index),]
  
  ### 3. Count less conservative duplicates ###
  n_less_cons_duplicates <- df_1_no_NA %>% get_dupes(c(title, authors, year)) %>% nrow()
  
  cat(
    paste(
      "Using the less conservative strategy,",
      n_less_cons_duplicates - nrow(cons_dupes),
      "more records are identified as duplicates than with the conservative strategy.",
      "\n",
      "Conservative strategy: ", 
      nrow(cons_dupes), 
      "\n",
      "Less conservative strategy:",
      n_less_cons_duplicates,
      "\n"
    )
  )
  
  ### 4. Deduplicate using the conservative strategy ###
  
  ## Check if there are any duplicates:
  if (nrow(cons_dupes) > 0){
  
  # Determine sets of duplicates
  dup_sets <- cons_dupes %>% 
    group_by(title, authors, year) %>% # not by issn and journal because one or the other may be missing
    mutate(dup_id = cur_group_id())
  
  # Merge duplicate rows
  for(i in seq(unique(dup_sets$dup_id))){
    
    # Add a counter:
    print(paste("deduplicating set", i, "out of", max(dup_sets$dup_id)))
    
    # select a pair of duplicates
    current_dup_set <- dup_sets[which(dup_sets$dup_id == i),] 
    
    # determine the row of the set to which all information
    # of the duplicates will be saved (the one with the longest abstract)
    current_dup_set <- current_dup_set %>%
      arrange(desc(str_length(abstract)))
    # determine the row of the set to which all information
    # of the duplicates will be saved.
    keep_index <- current_dup_set$index[1] # takes the top row.
    # Index of the row(s) to remove
    remove_index <- current_dup_set$index[-1] 
    
    ## MERGING CODE ##
    
    # The columns to be merged are
    cols_merge <-
      c(
        "title",
        "authors",
        "year",
        "depression_included",
        "substance_included",
        "anxiety_included",
        "composite_label"
      )
    # "title", "authors", "year", are added as the grouping variable
    
    # First find the columns which should be merged,
    # This should not be a column in which there are no values!
    # In other words, only the columns which have at least 1 value should be
    # included. (If not, the sum function will just put a 0, meaning that information
    # will be lost about which records were seen in what databases)
    cols_merge_final <- colnames(current_dup_set %>% 
                                   select(all_of(cols_merge)) %>%
                                   select(where(function(x) sum(is.na(x)) < nrow(current_dup_set))) %>%
                                   ungroup() %>%
                                   select(!c(title, authors, year))
    )
    
    # In case the composite label is present in cols_merge_final,
    # we know that at least one of the duplicates has been labeled for at least
    # one subject. 
    
    if("composite_label" %in% cols_merge_final){
    
    # Merging the rows now has to take into account the aggregation of the
    # labels. Simple solution to merge the information across the duplicated rows is 
    # to sum the results:
    
    # Obtain the merged value(s)
    current_dup_set[which(current_dup_set$index == keep_index), cols_merge_final] <-
      current_dup_set %>%
      select(all_of(cols_merge_final), title, authors, year) %>%
      summarise(across(cols_merge_final, sum, na.rm = T), .groups = "drop") %>%
      ungroup() %>%
      select(!c(title, authors, year))
    
    # Precaution for all labels: 
    # they should not exceed 1!
    # Moreover, Composite label should be recalculated
    # Should be NA when all cols are NA
    current_dup_set[which(current_dup_set$index == keep_index), cols_merge] <-
      current_dup_set[which(current_dup_set$index == keep_index), ] %>%
      select(cols_merge) %>%
      mutate(
        depression_included = case_when(depression_included > 1 ~ 1,
                                        TRUE ~ depression_included),
        substance_included = case_when(substance_included > 1 ~ 1,
                                       TRUE ~ substance_included),
        anxiety_included = case_when(anxiety_included > 1 ~ 1,
                                     TRUE ~ anxiety_included),
        composite_label = case_when(
          depression_included == 1 & !is.na(depression_included) ~ 1,
          substance_included == 1 &
            !is.na(substance_included) ~ 1 ,
          anxiety_included == 1 &
            !is.na(anxiety_included) ~ 1,
          depression_included == 0 &
            !is.na(depression_included) ~ 0,
          substance_included == 0 &
            !is.na(substance_included) ~ 0,
          anxiety_included == 0 &
            !is.na(anxiety_included) ~ 0,
          TRUE ~ NA_real_
        )
      )
    
    # Select only the columns which have changed values
    dedup_values <- current_dup_set[which(current_dup_set$index == keep_index), cols_merge_final]
    
    # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
    df[which(df$index == keep_index), cols_merge_final] <- dedup_values
    
    # REMOVE DUPLICATE ROW(S)
    df <- df[-which(df$index %in% remove_index),]
    
    # ADD ONE TO COUNTER OF LABELED DUPES
    n_labeled_dupes <- n_labeled_dupes + 1
    
    } else {
      # If none of the duplicates have received any label, deduplication is easy!
      # The rows which can be removed according to remove_index can simply be deleted:
      df <- df[-which(df$index %in% remove_index), ]
      n_no_label_dupes <- n_no_label_dupes + 1
    }
    
  } # close for loop
  
  # Print information about the deduplication process
  cat(paste("In total", max(dup_sets$dup_id), "sets were deduplicated conservatively, of which: \n",
            n_labeled_dupes, "sets had at least one label \n",
            n_no_label_dupes, "sets had no label at all \n"))
  
  return(df)
  
  # In case there are no identified duplicates through the conservative way:
  } else {
    
    cat(paste("No duplicates identified through conservative deduplication.\n"))
    return(df)
  }
  
}
