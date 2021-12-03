################################################
####### QUALITY CHECK AFTER DEDUPLICATION ######
################################################

################################################################################
# This script creates from the input files (see below) the following output:   #
# - [your_file]_quality_checked.xslx                                           #
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
source("scripts/deduplicate_for_q-check_titles.R") # Deduplication and merging based on titles for the quality checks
source("scripts/quality_check.R") # Adding columns with corrected values.

# CREATING DIRECTORIES
## Output
dir.create("output")

# DEFINING PATHS
## If necessary, change the name to your file name:
YOUR_FILE <- "megameta_asreview"

## Keep as is
DATA_PATH <- "data/"
OUTPUT_PATH <- "output/"
DEDUPLICATED_PATH <- paste0(YOUR_FILE, "_deduplicated.xlsx")
QUALITY_CHECK_1_PATH <- "-incorrectly-excluded-records.xlsx"
QUALITY_CHECK_2_PATH <- "-incorrectly-included-records.xlsx"

# IMPORT DEDUPLICATED DATA
df <- read_xlsx(paste0(OUTPUT_PATH, DEDUPLICATED_PATH))

# IMPORT QUALITY CHECK DATA
## In short Quality check 1 checks which records have been falsely excluded.
## Quality check 2 checks which records have been falsely included.
## More information in the `quality_check.R` script. 

## Quality check 1 Data
depression_q1 <- read_xlsx(paste0(DATA_PATH, "depression", QUALITY_CHECK_1_PATH))
substance_q1 <- read_xlsx(paste0(DATA_PATH, "substance_abuse", QUALITY_CHECK_1_PATH))
anxiety_q1 <- read_xlsx(paste0(DATA_PATH, "anxiety", QUALITY_CHECK_1_PATH))

## Quality check 2 Data
depression_q2 <- read_xlsx(paste0(DATA_PATH, "depression", QUALITY_CHECK_2_PATH))
substance_q2 <- read_xlsx(paste0(DATA_PATH, "substance", QUALITY_CHECK_2_PATH))
anxiety_q2 <- read_xlsx(paste0(DATA_PATH, "anxiety", QUALITY_CHECK_2_PATH))

# QUALITY CHECK
# This function adds multiple columns:
# 1. "quality_check_1(0->1)": 
#    Indicating for which subject a record was wrongly excluded:
#    1 = Anxiety
#    2 = Depression
#    3 = Substance Abuse

# 2. "quality_check_2(1->0)":      
#    Indicating for which subject a record was wrongly included:
#    1 = Anxiety
#    2 = Depression
#    3 = Substance Abuse

# 3. "anxiety_included_corrected":
#    The corrected label, taking the previous columns into account. 

# 4. "depression_included_corrected"
#    The corrected label, taking the previous columns into account. 

# 5. "substance_included_corrected"  
#    The corrected label, taking the previous columns into account. 

# 6. "composite_label_corrected" 
#    The corrected composite label, based on the subject_included_corrected
#    columns.

df <- quality_check(df)

## Check how many values were changed

# Quality check 1:
cat(
  paste0(
    "The number of changed labels through quality check 1 (irrelevant turned relevant) is ",
    nrow(df %>% filter(!is.na(
      `quality_check_1(0->1)`
    ))),
    # number of changed labels.
    " (",
    round(nrow(df %>% filter(
      !is.na(`quality_check_1(0->1)`)
    )) / nrow(df) * 100, 2),
    "%)." # percentage of changed labels.
  )
)

# Quality check 2:
cat(
  paste0(
    "The number of changed labels through quality check 2 (relevant turned irrelevant) is ",
    nrow(df %>% filter(!is.na(
      `quality_check_2(1->0)`
    ))),
    # number of changed labels.
    " (",
    round(nrow(df %>% filter(
      !is.na(`quality_check_2(1->0)`)
    )) / nrow(df) * 100, 2),
    "%)." # percentage of changed labels.
  )
)

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
      depression_included,
      anxiety_included,
      substance_included,
      composite_label,
      `quality_check_1(0->1)`,
      `quality_check_2(1->0)`,
      anxiety_included_corrected,
      depression_included_corrected,
      substance_included_corrected,
      composite_label_corrected
    ),
    .after = last_col()
  )

# ADD DATA-EXTRACTED COLUMN
# However below the column is created as a mockup
df <- df %>% mutate(data_extracted = NA)

# EXPORT
write_xlsx(df, path = paste0(OUTPUT_PATH, YOUR_FILE, "_quality_checked.xlsx"))
