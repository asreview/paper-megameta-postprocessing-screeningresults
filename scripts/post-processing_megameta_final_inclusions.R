#############################
####### Pre-processing ######
#############################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - final_inclusions_megameta                                                  #
################################################################################

# Loading Libraries
library(readxl)
library(tidyverse) # Data wrangling
library(janitor)   # Deduplication
library(stringr)

# Loading functions
source("scripts/merge_datasets.R") # Merges all three input datasets
source("scripts/final_included.R") # Adds a column indicating final_inclusions
source("scripts/identify_duplicates.R") # Identifies duplicates
# source("scripts/deduplicate.R") # not done yet

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

# First the datasets need to be merged
df <- merge_datasets(depression, substance, anxiety)

# Next, let's add a column of final_included
# final_included simply indicates whether the record was included.
df <- final_included(df)

# Then the duplicates need to be identified and deduplicated
# This function adds two extra columns: 
# - index: Simply an index to be able to rearrange the order, while still
#          preserving the knowledge of the order in which the records were
#          screened
# - unique_record: Where 1 indicates an unique record and 0 a duplicated one. 
df <- identify_duplicates(df)


