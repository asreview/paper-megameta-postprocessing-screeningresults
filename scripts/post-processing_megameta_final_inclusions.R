#############################
####### Pre-processing ######
#############################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - final_inclusions_megameta                                                  #
################################################################################

# install.packages
## If necessary use the commands below to install the necessary packages
# install.packages("readxl")
# install.packages("writexl")
# install.packages("tidyverse")
# install.packages("janitor")

# Loading Libraries
library(readxl)    # reading the data
library(writexl)   # writing the data
library(tidyverse) # Data wrangling
library(janitor)   # Deduplication

# Loading functions
source("scripts/merge_datasets.R") # Merges all three input datasets
source("scripts/final_included.R") # Adds a column indicating final_inclusions
source("scripts/identify_duplicates.R") # Identifies duplicates
source("scripts/deduplicate.R") # Merging and deduplicating rows

# Creating Directories
## Output
dir.create("output")

# Defining Paths
DATA_PATH <- "data/"
RESULTS_DATA_PATH <- "data/asreview_result_"
OUTPUT_PATH <- "output/"

# Loading Input Data
depression <- read_xlsx(paste0(RESULTS_DATA_PATH, "depression.xlsx"))
substance <- read_xlsx(paste0(RESULTS_DATA_PATH, "substance-abuse.xlsx"))
anxiety <- read_xlsx(paste0(RESULTS_DATA_PATH, "anxiety.xlsx"))

##### Data wrangling ######

# MERGING
## First the datasets need to be merged
df <- merge_datasets(depression, substance, anxiety)

# FINAL INCLUSIONS
## Next, let's add a column of final_included
## final_included simply indicates whether the record was included.
df <- final_included(df)

# IDENTIFY DUPLICATES
## Then the duplicates need to be identified and deduplicated
## This function adds two extra columns: 
## - index: Simply an index to be able to rearrange the order, while still
##          preserving the knowledge of the order in which the records were
##          screened
## - unique_record: Where 1 indicates an unique record and 0 a duplicated one.
df <- identify_duplicates(df)

# DEDUPLICATION
## Before the actual deduplication commences the 
## Merging the values of duplicated rows is based on the following:
## -  A 1 in any of the columns should overwrite an NA or 0 of other rows.
## -  A 0 should overwrite an NA.
## -  Only NA in a column (meaning that a record was not present in one of 
##    the subjects) should stay NA!
df <- deduplicate(df)

#### Preparation for exportation ####

# SORTING
## Make sure that the data is sorted as it was before
df <- arrange(df, index)

# ORDER OF COLUMNS
## The order of the columns does not yet allow for easy interpretation.
## Therefore, the columns should be shuffled, which is done next

df <-
  df %>% relocate(
    c(
      asreview_ranking,
      depression_included,
      anxiety_included,
      substance_included,
      final_included
    ),
    .after = last_col()
  )


# EXPORT
write_xlsx(df, path = paste0(OUTPUT_PATH, "final_inclusions_megameta.xlsx"))

