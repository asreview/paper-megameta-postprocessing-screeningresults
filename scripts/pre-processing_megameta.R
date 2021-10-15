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
mir <- read_xlsx(paste0(DATA_PATH, "mismatch_included_raw.xlsx"))
depression <- read_xlsx(paste0(RESULTS_DATA_PATH, "depression.xlsx"))
substance <- read_xlsx(paste0(RESULTS_DATA_PATH, "substance-abuse.xlsx"))
anxiety <- read_xlsx(paste0(RESULTS_DATA_PATH, "anxiety.xlsx"))


###################################
## Preparing mismatch inclusions ##
###################################
# Create new colnames !


# Creating all combinations of functional columns and subjects.
possible_colnames <- expand.grid("function" = c("title", "DOI", "source"),
                                 "subject" = c("Intended_Depression", "Intended_Substance_abuse", "Intended_Anxiety"))

colnames_mir <- unite(possible_colnames, colnames, c("subject", "function"))

mir <- colnames()

# Changing to a long format (NEEDS A MORE ELEGANT SOLUTION!!)
mismatch_included_title <- mir %>%
  select(affective_disorder_title, addictive_disorder_title, anxiety_title) %>%
  pivot_longer(
    cols = ends_with("title"),
    names_to = "intended_subject",
    values_to = "title")

mismatch_included_DOI <- mir %>%
  select(affective_disorder_DOI, addictive_disorder_DOI, anxiety_DOI) %>%
  pivot_longer(
    cols = ends_with("DOI"),
    names_to = "intended_subject",
    values_to = "DOI") 

mismatch_included_source <- mir %>%
  select(affective_disorder_source, addictive_disorder_source, anxiety_source) %>%
  pivot_longer(
    cols = ends_with("source"),
    names_to = "intended_subject",
    values_to = "source")

mismatch_included <- mutate(mismatch_included_title, mismatch_included_DOI, mismatch_included_source)

# Removing 'DOI:':
mismatch_included <- mismatch_included %>%
  mutate_at("DOI", str_replace, "DOI:", "")