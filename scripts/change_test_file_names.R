## Changing file names of test files ##

# If you would like to use the test files to try-out the post-processing pipeline,
# please run the following lines to change the names of the test files to the correct files.

## NOTE: IF YOU ALSO HAVE THE ACTUAL EMPIRICAL DATA IN YOUR FOLDER, PLEASE MAKE SURE
## TO STORE IT SOMEWHERE ELSE AS WELL. THE NEXT COMMANDS WILL NAMELY OVERWRITE 
## THESE FILES!

# In case you already have downloaded the empirical data from DANS, you do not
# have to run this script.

# Install necessary packages if not installed already
#install.packages("tidyverse")

# Loading required packages
library(tidyverse)

DATA_PATH <-"data/"

# Obtain the names of the test files
test_file_names <- list.files(path = DATA_PATH, pattern = "TEST")

# Store the names without the TEST part
file_names_new <- str_remove_all(test_file_names, "TEST-")

# Change the old names with the new ones.
file.rename(paste0(DATA_PATH, test_file_names),
            paste0(DATA_PATH, file_names_new))
