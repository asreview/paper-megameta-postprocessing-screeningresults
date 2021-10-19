#############################
####### Pre-processing ######
#############################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - mismatch_included: The dataset created by the students, where records that #
#   were excluded in the screening, but should be included for a different     #
#   subject were recorded, after preprocessing according to the steps below.   #
#                                                                              #
# - megameta_dataset: A dataset including all three subjects with their final  #
#   inclusions and information for which subject it was included. This dataset #
#   will be the output according to the steps below.                           #
################################################################################

# Loading Libraries
library(readxl)
library(tidyverse) # Data wrangling
library(janitor)   # Deduplication
library(stringr)

# Creating Directories
## Output
dir.create("output")

# Defining Paths
DATA_PATH <- "data/"
RESULTS_DATA_PATH <- "data/asreview_result_"
OUTPUT_PATH <- "output/"

# Loading Input Data

# For the mismatch included raw, the last 3 columns are redundant.
mir <- read_xlsx(paste0(DATA_PATH, "mismatch_included_raw.xlsx")) %>% select(1:last_col(3)) 
depression <- read_xlsx(paste0(RESULTS_DATA_PATH, "depression.xlsx"))
substance <- read_xlsx(paste0(RESULTS_DATA_PATH, "substance-abuse.xlsx"))
anxiety <- read_xlsx(paste0(RESULTS_DATA_PATH, "anxiety.xlsx"))


###################################
## Preparing mismatch inclusions ##
###################################

# Create new colnames !

## First let's replace the NA's in the first row with the respective subject
mir[1, ] <- replace_na(mir[1, ], list(...2 = "Affective_Disorder", ...5 = "Addictive_Disorders", ...8 = "Anxiety"))

## The colnames should be a combination of the first 2 rows:
colnames_mir <- paste(mir[1,], mir[2,], sep = "_")
colnames_mir

## Lastly, clean the names:
colnames_mir <- str_to_lower(colnames_mir)
colnames_mir <- str_replace(colnames_mir, " ", "_")

## Update the colnames and remove the first two rows
colnames(mir) <- colnames_mir
mir <- mir[3:nrow(mir),]


# Changing the data to long format!


# First pivot the title and doi columns
mismatch_included_no_source <- mir %>% 
  select(-contains("source")) %>%
  pivot_longer(cols = ends_with(c("title","doi")),
    names_to = c("intended_subject", ".value"),
    names_pattern = "(.+)_(.+)"
  )

# Then pivot the source separately, because it is different than the rest
mismatch_included_source <- mir %>%
  select(contains("source")) %>%
  pivot_longer(
    cols = starts_with("source"),
    names_to = "possible_sources",
    values_to = "source")

# Bind the two frames
mismatch_included <-  cbind(mismatch_included_no_source, source = mismatch_included_source$source)
## Need to build in an extra check!

# Remove NA rows (except for when doi is rightfully missing):
## As you can see here, there are NA rows present
tail(mismatch_included) 

## remove rows if title is NA
mismatch_included <- mismatch_included[!is.na(mismatch_included$title), ]

## All cleaned up!
tail(mismatch_included)

# Removing anything before the actual doi number:
mismatch_included <- mismatch_included %>%
  mutate_at("doi", str_replace, "^\\D+", "")

