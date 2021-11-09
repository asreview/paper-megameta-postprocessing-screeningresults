# paper-mega-meta-preprocessing

Within the folder scripts, one can find the following scripts.

## master_script_merging_after_asreview.R
The script `master_script_merging_after_asreview.R` is the master-script
within this repository. With the script the post-processing scripts
mentioned below are called for and used to create a merged dataset:

The three datasets on the subjects depression, anxiety, and
substance abuse are imported, merged and deduplicated. The result is saved as a
datafile which is placed in `output/megemeta_merged_after_screening_asreview.xslx`

To get started:
1. Add the required data into the data folder:
  - anxiety-screening-CNN-output.xlsx
  - depression-screening-CNN-output.xslx
  - substance-screening-CNN-output.xslx
2. Open the pre-processing.Rproject
3. Open scripts/master_script_merging_after_asreview.R
4. Install if necessary the packages required by uncommenting the lines
5. Run the script

### Post-processing functions
`merge_datasets.R` - This script contains a function to merge the datasets. An unique included column is added for each dataset before the merge.
`composite_label.R` - This script contains a function to create a column with the final inclusions.
`identify_duplicates.R` - This script contains a function to identify duplicate records in the dataset.
`deduplicate.R` - This script contaions a function to deduplicate the records while maintaining all information.


## script pre-processing_megameta.R
To use the script, you first need to add the respective data to the data folder.
An output folder is automatically created.
