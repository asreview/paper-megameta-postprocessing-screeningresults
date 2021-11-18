#####################################
####### POST-PROCESSING PART 1 ######
#####################################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - megameta_merged_after_screening_asreview_part_1.xlsx                       #
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
source("scripts/composite_label.R") # Adds a column indicating final_inclusions

# Creating Directories
## Output
dir.create("output")

# Defining Paths
DATA_PATH <- "data/"
RESULTS_DATA_PATH <- "-screening-CNN-output.xlsx"
OUTPUT_PATH <- "output/"

# Importing Results Data
depression <- read_xlsx(paste0(DATA_PATH, "depression", RESULTS_DATA_PATH))
substance <- read_xlsx(paste0(DATA_PATH, "substance", RESULTS_DATA_PATH))
anxiety <- read_xlsx(paste0(DATA_PATH, "anxiety", RESULTS_DATA_PATH))

##### Data wrangling ######

# MERGING
## First the datasets need to be merged
df <- merge_datasets(depression, substance, anxiety)

# FINAL INCLUSIONS
## Next, let's add a column of composite_label.
## Composite_label simply indicates whether the record was included.
df <- composite_label(df)

#### Preparation for exportation for part 2 ####

############# BEGIN OF EXTRA TEST COMMANDS ##############

# PART 2 (ONLY FOR TESTING!!!):
## For the next part of the post-processing, 
## doi's will be retrieved for the missing doi's.

## For the testing phase of the scripts, we will only
## retrieve the doi's for only the relevant records to save time. 
## Therefore, the next part should be deleted for the final script.

df <- df %>% filter(composite_label == 1)

############## END OF EXTRA TEST COMMANDS ###############
# THE COMMANDS BELOW ARE AGAIN FOR ANY SCRIPT:TESTING OR FINAL
# DO NOT REMOVE COMMANDS BELOW!
#########################################################

# SORTING
## Make sure that the data is sorted as it was before
df <- arrange(df, index)

# ORDER OF COLUMNS
## The order of the columns does not yet allow for easy interpretation.
## Therefore, the columns should be shuffled, which is done next

df <-
  df %>% relocate(
    c(
      depression_included,
      anxiety_included,
      substance_included,
      composite_label
    ),
    .after = last_col()
  )

# REMOVE REDUNDANT COLUMNS
df <- df %>%
  select(
    -c(
      matchdoi,
      doi_match,
      doimatch,
      included,
      Column1,
      Column2,
      Column3,
      asreview_ranking
    )
  )


# EXPORT
write_xlsx(df, path = paste0(OUTPUT_PATH, "megameta_merged_after_screening_asreview_part_1_preliminary.xlsx"))

