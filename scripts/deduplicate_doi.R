deduplicate_doi <- function(df, megameta) {
  
  # Create counters for number of duplicates:
  n_labeled_dupes <- 0
  n_no_label_dupes <- 0
  
  # Create a subset of the duplicates
  df_doi <- filter(df, !is.na(doi))
  df_dup <- get_dupes(df_doi, doi)
  
  # Determine sets of duplicates
  doi_set <- df_dup %>%
    group_by(doi) %>%
    mutate(dup_id = cur_group_id())
  
  # In case of the megameta data, the for loop below should be used.
  
  if (megameta == TRUE) {

    # Merge duplicate rows
    for (i in seq(unique(doi_set$dup_id))) {
      # Add a counter:
      print(paste("deduplicating set", i, "out of", max(doi_set$dup_id)))
      
      # select a pair of duplicates
      dup_set <- doi_set[which(doi_set$dup_id == i),]
      
      # determine the row of the set to which all information
      # of the duplicates will be saved.
      needed_row <- which(dup_set$unique_record == 1)
      keep_index <-
        dup_set$index[needed_row] # finds the index of this row to keep
      remove_index <- dup_set$index[-needed_row]
      
      ## MERGING CODE ##
      # The subject columns to be merged are
      cols_merge <-
        c(
          "doi",
          "depression_included",
          "substance_included",
          "anxiety_included",
          "composite_label"
        )
      # "doi" is added as a grouping variable
      
      # First find the columns which should be merged,
      # This should not be a column in which there are no values!
      # In other words, only the columns which have at least 1 value should be
      # included. (If not, the sum function will just put a 0, meaning that information
      # will be lost about which records were seen in what databases)
      cols_merge_final <- colnames(dup_set %>%
                                     select(all_of(cols_merge)) %>%
                                     select(where(
                                       function(x)
                                         sum(is.na(x)) < nrow(dup_set)
                                     )) %>%
                                     ungroup() %>%
                                     select(!doi))
      
      # In case the composite label is present in cols_merge_final,
      # we know that at least one of the duplicates has been labeled for at least
      # one subject.
      
      if ("composite_label" %in% cols_merge_final) {
        # Merging the rows has to take into account the aggregation of the
        # labels. Simple solution to merge the information across the duplicated rows is
        # to sum the results:
        
        # Obtain the merged value(s)
        dup_set[which(dup_set$index == keep_index), cols_merge_final] <-
          dup_set %>%
          select(all_of(cols_merge_final), doi) %>%
          summarise(across(all_of(cols_merge_final), sum, na.rm = T)) %>%
          select(!doi)
        
        # Precaution for all labels:
        # they should not exceed 1!
        # Moreover, Composite label should be recalculated
        # Should be NA when all cols are NA
        dup_set[which(dup_set$index == keep_index), cols_merge] <-
          dup_set[which(dup_set$index == keep_index), ] %>%
          select(all_of(cols_merge)) %>%
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
        
        # SELECT ONLY THE COLUMNS WHICH HAVE CHANGED VALUES
        dedup_values <-
          dup_set[which(dup_set$index == keep_index), cols_merge_final]
        
        # REPLACE THE CORRECT COLUMNS IN DF WITH THE MERGED VALUES
        df[which(df$index == keep_index), cols_merge_final] <-
          dedup_values
        
        # REMOVE DUPLICATE ROW(S)
        df <- df[-which(df$index %in% remove_index),]
        
        # ADD ONE TO COUNTER OF LABELED DUPES
        n_labeled_dupes <- n_labeled_dupes + 1
        
        # ELSE STATEMENT FOR CHECKING LABELS
        ## If none of the duplicates have received any label, there will be no composite_label
        ## in cols_merge_final and deduplication is easy!
      } else {
        
        ## The rows which can be removed according to remove_index can simply be deleted:
        
        # REMOVE DUPLICATE ROW(S)
        df <- df[-which(df$index %in% remove_index), ]
        
        # ADD ONE TO COUNTER OF UNLABELED DUPES
        n_no_label_dupes <- n_no_label_dupes + 1
        
      } # close else statement for checking if any labels are present
      
    } # close for loop megameta == TRUE
    
    
    ##############################################################
    # If not using the megameta data, use this for loop instead: #
    ##############################################################
    
  } else {
    
    ### MERGING CODE ###
    
    # START FOR LOOP
    for (i in seq(unique(doi_set$dup_id))) {
      
      # ADD INFORMATIVE MESSAGE FOR EACH ITERATION
      print(paste("deduplicating set", i, "out of", max(doi_set$dup_id)))
      
      # SELECT THE NEXT PAIR OF DUPLICATES
      dup_set <- doi_set[which(doi_set$dup_id == i),]
      
      # IDENTIFY ROW TO KEEP AND ROW(S) TO REMOVE
      ## determine the row of the set to which all information
      ## of the duplicates will be saved.
      needed_row <- which(dup_set$unique_record == 1)
      
      ## find the index of the row to keep
      keep_index <-
        dup_set$index[needed_row]
      
      ## find the index of this row to remove
      remove_index <- dup_set$index[-needed_row]
      
      # CHECK FOR ANY LABELS
      ## Check whether there is at least one of the rows has a label
      any_label <-
        dup_set %>% select(where(function(x)
          sum(is.na(x)) < nrow(dup_set)))
      
      ## If at least one does have a label:
      
      # MERGE ROWS WITH AT LEAST ONE LABELED RECORD
      if (nrow(any_label) > 0) {
        
        ## Obtain the merged value(s)
        dup_set[which(dup_set$index == keep_index), "included"] <-
          dup_set %>%
          select(doi, included) %>%
          summarise(included = sum(included, na.rm = T)) %>%
          select(!doi)
        
        ## Set the maximum value of included to 1.
        dup_set <-
          dup_set %>% mutate(included = case_when(included > 1 ~ 1,
                                                  TRUE ~ included))
        
        ## Save the label of the row we want to keep
        dedup_value <-
          dup_set[which(dup_set$index == keep_index), "included"]
        
        # KEEP ONE OF THE DUPLICATES
        ## Replace the value of included with the deduplicated value
        df[which(df$index == keep_index), "included"] <- dedup_value
        
        # REMOVE DUPLICATE ROW(S)
        df <- df[-which(df$index %in% remove_index), ]
        
        # ADD ONE TO COUNTER OF LABELED DUPES
        n_labeled_dupes <- n_labeled_dupes + 1
        
        ## If none of the duplicates have received any label, there will be no composite_label
        ## in cols_merge_final and deduplication is easy!
      } else {
        ## The rows which can be removed according to remove_index can simply be deleted:
        df <- df[-which(df$index %in% remove_index), ]
        
        # ADD ONE TO COUNTER OF UNLABELED DUPES
        n_no_label_dupes <- n_no_label_dupes + 1
        
      } # close else statement to check for the presence of labels.
      
    } # close for loop
    
  } # close else statement megameta == FALSE
  
  # Print information about the deduplication process
  cat(
    paste(
      "In total",
      max(doi_set$dup_id),
      "sets were deduplicated based on doi, of which: \n",
      n_labeled_dupes,
      "sets had at least one label \n",
      n_no_label_dupes,
      "sets had no label at all \n"
    )
  )
  
  return(df)
  
} # close function
