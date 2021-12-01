################################################
####### DEDUPLICATION AFTER DOI RETRIEVAL ######
################################################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - [your_file]_deduplicated.xslx                                              #
################################################################################

# INSTALL PACKAGES
## If necessary use the commands below to install the necessary packages
# install.packages("readxl")
# install.packages("writexl")
# install.packages("tidyverse")
# install.packages("janitor")

# LOADING LIBRARIES
library(readxl)    # reading the data
library(writexl)   # writing the data
library(tidyverse) # Data wrangling
library(janitor)   # Deduplication

# LOADING NECESSARY FUNCTIONS
source("scripts/identify_duplicates.R") # Identifies duplicates
source("scripts/deduplicate_doi.R") # Deduplication and merging rows based on doi
source("scripts/deduplicate_conservative.R") # an extra round of conservative deduplication

# CREATUNG DIRECTORIES
## Output
dir.create("output")

# DEFINING PATHS
## If necessary, change the name to your file name:
YOUR_FILE <- "megameta_asreview"

## Keep as is
DATA_PATH <- "data/"
OUTPUT_PATH <- "output/"
DOI_RETRIEVED_PATH <- paste0(YOUR_FILE, "_doi_retrieved.xlsx")

# IMPORTING RESULTS
## from doi retrieval 
df <- read_xlsx(paste0(OUTPUT_PATH, DOI_RETRIEVED_PATH))

################# FOR MEGAMETA ONLY ######################
### COMMENT (ADD # BEFORE A LINE) THE THREE COMMANDS BELOW 
### IF NOT USING THE MEGAMETA DATA 

## With the import, some columns were saved as logical, 
## instead of numeric. The important columns to change are:

cols_to_num <- c("depression_included",
                     "anxiety_included",
                     "substance_included",
                     "composite_label")

## Change these columns to integers:
df[, cols_to_num] <-
  apply(df[, cols_to_num], 2,
        function(x)
          as.numeric(as.character(x)))

##########################################################
############ END MEGAMETA SPECIFIC PART ##################


##### DATA DEDUPLICATION ######

# IDENTIFY DUPLICATES
## The duplicates need to be identified and deduplicated
## This function adds two extra columns: 
## - index: Simply an index to be able to rearrange the order, while still
##          preserving the knowledge of the order in which the records were
##          screened
## - unique_record: Where 1 indicates an unique record and 0 a duplicated one.
df <- identify_duplicates(df)

#  DOI DEDUPLICATION
## Before the actual deduplication commences the 
## Merging the values of duplicated rows is based on the following:
## -  A 1 in any of the columns should overwrite an NA or 0 of other rows.
## -  A 0 should overwrite an NA.
## -  Only NA in a column (meaning that a record was not present in one of 
##    the subjects) should stay NA!

## If NOT using the megameta dataset, make sure to set megameta to FALSE instead
## of TRUE

df <- deduplicate_doi(df = df, megameta = TRUE) 

#  CONSERVATIVE DEDUPLICATION
## The defaults for the conservative deduplication are set to the 
## conservative deduplication strategy of the Megameta project. 

###############################################################################
## If you are using this script for another project,                          #
## do the following in the command below:                                     #
## 1. Change megameta = TRUE to megameta = FALSE                              #
##                                                                            #
## 2. Fill in the names of the variables you would like to deduplicate on     #
##    for a *less conservative strategy*;                                     #
##                                                                            #
##    for example:                                                            #
##    less_conservative_cols = c("title", "authors", "year")                  #
##                                                                            #
## 3. Fill in the name of a variable that would be added to the above for the #
##    *conservative deduplication strategy*;                                  #
##                                                                            #
##    for example:                                                            #
##    conservative_col = c("journal")                                         #
###############################################################################

## In the case of megameta = TRUE, the following can be run as is.
## Conservative deduplication is automatically based on:
## title, authors, year AND issn/secondary_title.

df <- deduplicate_conservative(
  df,
  # less_conservative_cols = c([multiple variables here]),
  # conservative_col = c([one extra variable here]),
  megameta = TRUE
)

################# FOR MEGAMETA ONLY ######################
### COMMENT (ADD # BEFORE A LINE) THE COMMANDS BELOW OR
### SKIP COMMANDS IF NOT USING THE MEGAMETA DATA.

## Double check numbers:
sum(df$depression_included, na.rm = T)
sum(df$substance_included, na.rm = T)
sum(df$anxiety_included, na.rm = T)
sum(df$composite_label, na.rm = T)

##########################################################
############ END MEGAMETA SPECIFIC PART ##################

#### EXPORT ####

# SORTING
## Make sure that the data is sorted as it was before
df <- arrange(df, index)

# ORDER OF COLUMNS
## The order of the columns does not yet allow for easy interpretation.
## Therefore, the columns should be shuffled, which is done next

# IF NOT USING MEGAMETA PUT A # BEFORE:
#, <- this one is important! It is the comma after included!
#depression_included,
#anxiety_included,
#substance_included,
#composite_label
# REMOVE # BEFORE INCLUDED

df <-
  df %>% relocate(
    c(
      index,
      #included,
      depression_included,
      anxiety_included,
      substance_included,
      composite_label
    ),
    .after = last_col()
  )

# EXPORT
write_xlsx(df, path = paste0(OUTPUT_PATH, YOUR_FILE, "_deduplicated.xlsx"))

