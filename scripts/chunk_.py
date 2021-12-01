import requests
import pandas as pd
from tqdm import tqdm
import string
import urllib
import datetime
from pathlib import Path

script_number = "0"

input_file = Path("..", "split", f"chunk_{script_number}.csv")
resultsDF = pd.read_csv(input_file)

# In case a column with the publication year is not called year, uncomment,
# change where necessary and run the following:
# resultsDF = resultsDF.rename(columns = {"YOUR_COL_NAME_HERE":"year"})

# Collect failed DOI attempts
failed_doi_attempts = []


# Define Crossref DOI finding function
def crossref_doi_find(row):
    """ Requests Crossref with title-year combination and returns DOI if good
        enough match is found.

    Args:
        row: DataFrame row containing year and title.

    Returns:
        string: Probable DOI of a paper
        None: If no good DOI could be found
    """

    headers = {"Accept": "application/json"}
    if pd.isna(row.year):
        return None
    if not 1800 <= row.year <= datetime.date.today().year+2:
        return None
    year = str(int(row.year))

    try:
        title = urllib.parse.quote(row.title)
    except:  # noqa: E722
        print("Failed to encode title: ", row.title)
        failed_doi_attempts.append(row)
        return None

    url = 'https://api.crossref.org/works/?query.title=' + title + \
        '&filter=from-pub-date:' + year + ',until-pub-date:' + year
    r = requests.get(url, headers=headers)

    try:
        first_entry = r.json()['message']['items'][0]
        title, found_title = [s.translate(string.punctuation).lower() for s in [row.title, first_entry['title'][0]]]
        perfect_match = (title in found_title) or (found_title in title)
        if perfect_match:
            return first_entry["DOI"].lower()
    except:  # noqa: E722
        # JSON decoding error
        failed_doi_attempts.append(row)
        print("JSON failed to decode response for: " + row.title)
        return None

    return None


# Set here the dataframe, for which you want to find missing DOIs
doiFixedDF = resultsDF.copy()
missing_doi_count = doiFixedDF.doi.isna().sum()
print("Requesting Crossref to infer %d missing DOIs" % missing_doi_count)
for i, row in tqdm(doiFixedDF[doiFixedDF.doi.isna()].iterrows(), total=missing_doi_count):
    doiFixedDF.loc[i, 'doi'] = crossref_doi_find(row)

fixed_doi_count = missing_doi_count - doiFixedDF.doi.isna().sum()

print("Out of %d initially missing DOIs, %d (%.2f%%) are found" % (missing_doi_count, fixed_doi_count, 100 * fixed_doi_count/missing_doi_count))
print("%d DOI attempts failed" % len(failed_doi_attempts))

if len(failed_doi_attempts) > 0:
    print("The following papers failed:")
    for row in failed_doi_attempts:
        print(row.title)

# Fixing the Unicode encoding in some of DOIs
doiFixedDF.loc[~doiFixedDF.doi.isna(), 'doi'] = doiFixedDF[~doiFixedDF.doi.isna()].doi.apply(urllib.parse.unquote)

# Saving the fixed DOI file
doiFixedDF.to_csv(Path("..", "split", f"chunk_doi_{script_number}.csv"), index=False)
