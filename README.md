# Scripts for Post-Processing Mega-Meta Results

The repository is part of the so-called, Mega-Meta study on reviewing factors
contributing to substance use, anxiety, and depressive disorders. The study
protocol has been pre-registered at
[Prospero](https://www.crd.york.ac.uk/prospero/display_record.php?ID=CRD42021266297).
The procedure for obtaining the search terms, the exact search query, and
selecting key papers by expert consensus can be found on the [Open Science
Framework](https://osf.io/m5uhy/). The three datasets, one for each disorder,
used for screening in ASReview and the partly labeled output datasets can be
found on DANS[NEEDS LINK].  The current repository contains the
post-processing scripts to: 

1.	Merge the three output files after screening in
ASReview; 
2.	Deal with noisy labels corrected in two rounds of quality checks;
3.	Obtain missing DOIs and titles; 4.	Apply another round of de-duplication ([the first round](https://github.com/asreview/paper-megameta-preprocessing-searchresults) of de-duplication was applied before the screening started). 

The scripts in the current repository result in one single dataset that can be
used for future meta-analyses. The dataset itself is available on DANS[NEEDS
LINK].  

## Datasets
Add the required data into the data folder available on DANS[NEEDS LINK].

1. The three export-datasets with the partly labelled data after screening in
ASReview:  
  - `anxiety-screening-CNN-output.xlsx`
  - `depression-screening-CNN-output.xslx`
  - `substance-screening-CNN-output.xslx`

2. The three datasets resulting from Quality Check 1:
 - `anxiety-incorrectly-excluded-records.xlsx`
 - `depression-incorrectly-excluded-records.xlsx`
 - `substance-incorrectly-excluded-records.xlsx`

3. The three datasets resulting from Quality Check 2:
 - `anxiety-incorrectly-included-records`
 - `depression-incorrectly-included-records`
 - `substance-incorrectly-included-records`



The script `master_script_merging_after_asreview.R` is the master-script
within this repository. With the script the post-processing scripts
mentioned below are called for and used to create a merged dataset:

The three datasets on the subjects depression, anxiety, and
substance abuse are imported, merged and deduplicated. The result is saved as a
datafile which is placed in `output/megemeta_merged_after_screening_asreview.xslx`

To get started:
1. 
2. Open the pre-processing.Rproject
3. Open scripts/master_script_merging_after_asreview.R
4. Install if necessary the packages required by uncommenting the lines
5. Run the script

### Post-processing functions
`merge_datasets.R` - This script contains a function to merge the datasets. An unique included column is added for each dataset before the merge.
`composite_label.R` - This script contains a function to create a column with the final inclusions.
`identify_duplicates.R` - This script contains a function to identify duplicate records in the dataset.
`deduplicate.R` - This script contaions a function to deduplicate the records while maintaining all information.


## Results
As mentioned above, the result of the `master_script_merging_after_asreview.R` is
`output/megemeta_merged_after_screening_asreview.xslx`. In this dataset the following
columns have been added.

For all columns where there are only 0's 1's and NA's, a `0` indicates a negative
(excluded for example), while `1` indicates a positive (included for example). `NA`
means `Not Available`. 

- `index` (1-165045):
  A simple indexing column going from 1-165045. Some numbers are not present
  because they have been removed after deduplication.
- `unique_record` (0, 1, NA):
  Indicating whether the column has a unique DOI. This is NA when there is no
  DOI present.
- `depression_included` (0, 1, NA):
  A column indicating whether a record was included in depression.
- `anxiety_included` (0, 1, NA):
  A column indicating whether a record was included in anxiety.
- `substance_included` (0, 1, NA):
  A column indicating whether a record was included in substance_abuse.
- `composite_label` (0, 1, NA):
  A column indicating whether a record was included in at least one of the
  subjects.
- `quality_check_1(0->1)` (1, 2, 3, NA):
  This column indicates for which subjects a record was falsely excluded:
  - 1 = anxiety
  - 2 = depression
  - 3 = substance-abuse
- `quality_check_2(1->0)` (1, 2, 3, NA):
  This column indicates for which subjects a record was falsely included:
  - 1 = anxiety
  - 2 = depression
  - 3 = substance-abuse
- `depression_included_corrected` (0, 1, NA):
  Combining the information from the ..._included and quality_check columns,
  this column contains the inclusion/exclusion/not seen labels after correction.
- `data_extracted` (NA):
  An empty column to be filled manually about which records have been extracted.


## script pre-processing_megameta.R
To use the script, you first need to add the respective data to the data folder.
An output folder is automatically created.
