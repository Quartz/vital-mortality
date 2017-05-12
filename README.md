# vital-mortality

Provisional analysis of US mortality rates.

## Contents

* `acs.R`: Combine mortality data with ACS population data.
* `mortality.py`: Process bulk CDC/NVSS mortality data into a simple format.
* `usa_00024.cbk.txt`: IPUMS codebook

*Note:* Raw data are not included in this repository due to size.

## Usage

Download [CDC mortality data](https://www.cdc.gov/nchs/data_access/VitalStatsOnline.htm#Mortality_Multiple) and place in `data`.

Execute an [IPUMS query](https://usa.ipums.org/usa/) matching `usa_00024.cbk.txt`, unzip the results, and rename them `usa_00024.csv`.

Run `mortality.py` to preprocess the CDC mortality data.

Run `acs.R` to mash up ACS data and produce age-standardized death rates.