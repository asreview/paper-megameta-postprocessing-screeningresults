######################################################################
####### PROCESS QUALITY_CHECKED DATA FOR USE IN ASREVIEW PLUGIN ######
######################################################################

################################################################################
# This script creates multiple datafiles from the following input file:        #
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

# CREATUNG DIRECTORIES
## Output
dir.create("output")
dir.create("output/data_for_plugin")

# DEFINING PATHS
## If necessary, change the name to your file name:
YOUR_FILE <- "megameta_asreview"

## Keep as is
DATA_PATH <- "data/"
OUTPUT_PATH <- "output/"
OUTPUT_PLUGIN_PATH <- "output/data_for_plugin/"
QUALITY_CHECKED_PATH <- paste0(YOUR_FILE, "_quality_checked.xlsx")

# IMPORTING RESULTS
## from quality checked
df <- read_xlsx(paste0(OUTPUT_PATH, QUALITY_CHECKED_PATH))

############################################################
## PROCESS DATA SO IT CAN BE USED FOR THE ASREVIEW PLUGIN ##
############################################################

## With the following commands, 5 versions of the dataset will be stored
## in the output folder.

#  1. megameta_asreview_partly_labelled
## A dataset where a column called `label_included` is added, which is an exact
## copy of the composite_label_corrected.
df_1 <- df %>% mutate(label_included = composite_label_corrected)
write_xlsx(df_1, path = paste0(OUTPUT_PLUGIN_PATH, YOUR_FILE, "_partly_labelled.xlsx"))

# 2. megameta_asreview_only_potentially_relevant
## A dataset with only those records which have a 1 in composite_label_corrected
df_2 <- df %>% filter(composite_label_corrected == 1)
write_xlsx(df_2, path = paste0(OUTPUT_PLUGIN_PATH, YOUR_FILE, "_only_potentially_relevant.xlsx"))

# 3. megameta_asreview_potentially_relevant_depression
## A dataset with only those records which have a 1 in depression_included_corrected
df_3 <- df %>% filter(depression_included_corrected == 1)
write_xlsx(df_3, path = paste0(OUTPUT_PLUGIN_PATH, YOUR_FILE, "_potentially_relevant_depression.xlsx"))

# 4. megameta_asreview_potentially_relevant_substance
## A dataset with only those records which have a 1 in substance_included_corrected
df_4 <- df %>% filter(substance_included_corrected == 1)
write_xlsx(df_4, path = paste0(OUTPUT_PLUGIN_PATH, YOUR_FILE, "_potentially_relevant_substance.xlsx"))

# 5. megameta_asreview_potentially_relevant_anxiety
## A dataset with only those records which have a 1 in anxiety_included_corrected
df_5 <- df %>% filter(anxiety_included_corrected == 1)
write_xlsx(df_5, path = paste0(OUTPUT_PLUGIN_PATH, YOUR_FILE, "_potentially_relevant_anxiety.xlsx"))
