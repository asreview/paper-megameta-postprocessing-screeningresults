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
3.	Obtain missing DOIs and titles; 
4.	Apply another round of de-duplication ([the first round](https://github.com/asreview/paper-megameta-preprocessing-searchresults) of de-duplication was applied before the screening started).

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


## Installation

To get started:
1. Open the `pre-processing.Rproject` in Rstudio;
2. Open `scripts/master_script_merging_after_asreview.R`;
3. Install, if necessary, the packages required by uncommenting the lines;
4. Run the script.

### Post-processing functions
`merge_datasets.R` - This script contains a function to merge the datasets. An unique included column is added for each dataset before the merge.
`composite_label.R` - This script contains a function to create a column with the final inclusions.
`identify_duplicates.R` - This script contains a function to identify duplicate records in the dataset.
`deduplicate.R` - This script contains a function to deduplicate the records, based on doi, while maintaining all information.
`quality_check.R` - This script corrects those labels which were incorrect according to 2 quality checks: Quality check 1 (incorrectly assigned irrelevant), Quality check 2 (incorrectly assigned relevant).
`deduplicate_titles.R` - This script is used in the `quality_check.R` to deduplicate the records from the quality check based on title.


## Results
The result of the `master_script_merging_after_asreview.R` is
`output/megemeta_merged_after_screening_asreview.xslx`. In this dataset the following
columns have been added:

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
  Combining the information from the depression_included and quality_check columns,
  this column contains the inclusion/exclusion/not seen labels after correction.
- `substance_included_corrected` (0, 1, NA):
    Combining the information from the substance_included and quality_check columns,
    this column contains the inclusion/exclusion/not seen labels after correction.
- `anxiety_included_corrected` (0, 1, NA):
  Combining the information from the anxiety_included and quality_check columns,
  this column contains the inclusion/exclusion/not seen labels after correction.
- `composite_label_corrected` (0, 1, NA):
  A column indicating whether a record was included in at least one of the
  corrected_subject columns: The results after taking the quality checks into account.
- `data_extracted` (0, 1, NA):
  An empty column to be filled manually about which records have been extracted.

For all columns where there are only 0's 1's and NA's, a `0` indicates a negative
(excluded for example), while `1` indicates a positive (included for example). `NA`
means `Not Available`.


## Funding 
This project is funded by a grant from the Centre for Urban Mental Health, University of Amsterdam, The Netherlands

## Licence
The content in this repository is published under the MIT license.

## Contact
For any questions or remarks, please send an email to [ADD EMAIL].
