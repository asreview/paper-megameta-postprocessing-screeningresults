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
2.	Obtain missing DOIs;
3.	Apply another round of de-duplication ([the first round](https://github.com/asreview/paper-megameta-preprocessing-searchresults) of de-duplication was applied before the screening started).
4. Deal with noisy labels corrected in two rounds of quality checks;

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

```
NOTE: For 3. it should be noted that these files are not finished yet. Therefore
the files currently have the following temporary names:
  - anxiety-incorrectly-included-records-preliminary-results.xslx
  - depression-incorrectly-included-records-preliminary-results.xslx
  - substance-incorrectly-included-records-preliminary-results.xslx

When quality check 2 is finished, the names will be changed to those mentioned
above.
```

## Installation

To get started:
1. Open the `pre-processing.Rproject` in Rstudio;
2. Open `scripts/master_script_merging_after_asreview_part_1.R`;
3. Install, if necessary, the packages required by uncommenting the lines and running them.

## Running the complete pipeline

### Using test data
Within the data folder, there are test-files which can be used to test the pipeline.

```
NOTE: When you want to use these test files; please make sure that the empirical
data is not saved solely in the same data folder as where these test files are stored!
The next step will overwrite these files. To be sure, save the empirical results
somewhere else on your device and put them back in the data folder when you want
to run this data through the pipeline.
```

1. Open the `pre-processing.Rproject` in Rstudio;
2. Open `scrips/change_test_file_names.R` and run the script. The test files
will now have the same file names as those of the empirical data. See [datasets](#Datasets)
for the specific names.
3. Continue from step 2 from the [using empirical data](#using-empirical-data) instructions

### Using empirical data
1. Open the `pre-processing.Rproject` in Rstudio;
2. Open `scripts/master_script_merging_after_asreview_part_1.R`;
3. Run the script. At the end of part_1, a file named  `megameta_merged_after_screening_asreview_part_1_preliminary.xlsx` is created and
saved in the output folder.
4. Next, run the `scripts/crossref_doi_retrieval_part_2.ipynb` to retrieve the missing
doi's. The input for this script `megameta_merged_after_screening_asreview_part_1_preliminary.xlsx` is automated.
The output from the doi retrieval is also stored in the output folder:
`megameta_asreview_added_doi_part_2_preliminary.xlsx`
Note. This might take some time!
5. For the final part, open and run `scripts/master_script_merging_after_asreview_part_3.R`.
Again the input data (`megameta_asreview_added_doi_part_2_preliminary.xlsx`) is automatically retrieved.
This will finally result in the final dataset stored in the output folder: `megameta_merged_after_screening_asreview_postprocessed_preliminary.xslx`

## Post-processing functions
-  `change_test_file_names.R` - With this script the filenames of the test files are converted to the empirical datafile names. 
-  `merge_datasets.R` - This script contains a function to merge the datasets. An unique included column is added for each dataset before the merge.
-  `composite_label.R` - This script contains a function to create a column with the final inclusions.
-  `identify_duplicates.R` - This script contains a function to identify duplicate records in the dataset.
-  `deduplicate.R` - This script contains a function to deduplicate the records, based on doi, while maintaining all information.
-  `quality_check.R` - This script corrects those labels which were incorrect according to 2 quality checks: Quality check 1 (incorrectly assigned irrelevant), Quality check 2 (incorrectly assigned relevant).
-  `deduplicate_titles.R` - This script is used in the `quality_check.R` to deduplicate the records from the quality check based on title.


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
