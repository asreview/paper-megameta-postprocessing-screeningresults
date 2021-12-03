###########################################################
####### MERGING DATASETS AFTER SCREENING IN ASREVIEW ######
###########################################################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - [your_file]_merged.xslx                                                    #
################################################################################

# INSTALL PACKAGES
## If necessary use the commands below to install the necessary packages
# install.packages("readxl")
# install.packages("writexl")
# install.packages("tidyverse")
# install.packages("janitor")

# LOAD LIBRARIES
library(readxl)    # reading the data
library(writexl)   # writing the data
library(tidyverse) # Data wrangling
library(janitor)   # Deduplication

# LOAD FUNCTIONS
source("scripts/merge_datasets.R") # Merges all three input datasets
source("scripts/composite_label.R") # Adds a column indicating final_inclusions
source("scripts/print_information_datasets.R") # Function to print information.

# CREATE DIRECTORIES
## Output
dir.create("output")

# DEFINE PATHS
## If necessary, change the name to your file name:
YOUR_FILE <- "megameta_asreview"
RESULTS_DATA_PATH <- "-screening-CNN-output.xlsx"

## Keep as is
DATA_PATH <- "data/"
OUTPUT_PATH <- "output/"

## If necessary, change below to your specific path(s):
# Importing Results Data

#DEPRESSION
depression <- read_xlsx(paste0(DATA_PATH, "depression", RESULTS_DATA_PATH))

## Printing information, change the `included` if necessary.
info_datasets(df = depression, name = "depression", included_column = depression$included)

# SUBSTANCE
substance <- read_xlsx(paste0(DATA_PATH, "substance", RESULTS_DATA_PATH))
## Printing information, change the `included` if necessary.
info_datasets(df = substance, name = "substance", included_column = substance$included)

# ANXIETY
anxiety <- read_xlsx(paste0(DATA_PATH, "anxiety", RESULTS_DATA_PATH))
## Printing information, change the `included` if necessary.
info_datasets(df = anxiety, name = "anxiety", included_column = anxiety$included)

##### DATA WRANGLING ######

# MERGING
## First the datasets need to be merged
df <- merge_datasets(depression, substance, anxiety)

# FINAL INCLUSIONS
## Next, let's add a column of composite_label.
## Composite_label simply indicates whether the record was included in at least
## one subject.
df <- composite_label(df)

## Print information
info_datasets(df = df, name = "merged", included_column = df$composite_label)


#### PREPARE FOR EXPORT TO DOI RETRIEVAL ####

############# BEGIN OF EXTRA TEST COMMANDS ##############

# # (ONLY FOR TESTING!!!):
# ## For the next part of the post-processing, 
# ## doi's will be retrieved for the missing doi's.
# 
# ## For the testing phase of the scripts, we will only
# ## retrieve the doi's for only the relevant records to save time. 
# ## Therefore, the next part should be deleted for the final script.
# 
# df <- df %>% filter(composite_label == 1)

############## END OF EXTRA TEST COMMANDS ###############
# THE COMMANDS BELOW ARE AGAIN FOR ANY SCRIPT: TESTING OR FINAL
# DO NOT REMOVE COMMANDS BELOW!
#########################################################

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
write_xlsx(df, path = paste0(OUTPUT_PATH, YOUR_FILE, "_merged.xlsx"))

