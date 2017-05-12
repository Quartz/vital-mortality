#!/usr/bin/env python

from collections import defaultdict
import csv

'''
Mortality data is from the CDC/NVSS
Downloads: https://www.cdc.gov/nchs/data_access/VitalStatsOnline.htm#Mortality_Multiple
Documentation: https://www.cdc.gov/nchs/nvss/mortality_public_use_data.htm
'''

FILENAMES = [
    'VS09MORT.DUSMCPUB',
    'VS10MORT.DUSMCPUB',
    'VS11MORT.DUSMCPUB',
    'VS12MORT.DUSMCPUB',
    'VS13MORT.DUSMCPUB',
    'VS14MORT.DUSMCPUB',
    'VS15MORT.DUSMCPUB'
]

RACE_MAP = {
    '1': 'Hispanic',
    '2': 'Hispanic',
    '3': 'Hispanic',
    '4': 'Hispanic',
    '5': 'Hispanic',
    '6': 'White',
    '7': 'Black',
    '8': 'Other',
    '9': 'Unknown',
    ' ': 'Unknown'
}

# 2003 revision
EDUCATION_MAP = {
    '1': 'High school degree or less',
    '2': 'High school degree or less',
    '3': 'High school degree or less',
    '4': 'Some college but no BA',
    '5': 'Some college but no BA',
    '6': 'BA or more',
    '7': 'BA or more',
    '8': 'BA or more',
    '9': 'Unknown',
    ' ': 'Unknown'
}

AGE_MAP = {
    '30': '20-29',
    '31': '20-29',
    '32': '30-39',
    '33': '30-39',
    '34': '40-49',
    '35': '40-49',
    '36': '50-59',
    '37': '50-59',
    '38': '60-69',
    '39': '60-69',
    '40': '70-79',
    '41': '70-79',
    '42': '80-89',
    '43': '80-89',
    '44': '90+',
    '45': '90+',
    '46': '90+',
    '47': '90+',
    '48': '90+',
    '49': '90+',
    '50': '90+',
    '51': '90+',
    '52': 'Unknown'
}

# years
sums = defaultdict(
    # race
    lambda: defaultdict(
        # education
        lambda: defaultdict(
            # age group
            lambda: defaultdict(
                # count
                int))))

for filename in FILENAMES:
    print(filename)

    with open('data/%s' % filename) as f:
        n = 0

        for line in f:
            year = line[101:105]

            resident = int(line[19])

            # Exclude non-residents
            if resident == 4:
                continue

            age_flag = line[74:76]

            # Exclude those under 20 years of age
            if int(age_flag) < 30:
                continue

            race_flag = line[487]
            race_key = RACE_MAP[race_flag]

            ed_flag = line[62]
            ed_key = EDUCATION_MAP[ed_flag]

            age_key = AGE_MAP[age_flag]

            sums[year][race_key][ed_key][age_key] += 1

            n += 1

            if n % 100000 == 0:
                print(n)

output = []

for year, races in sums.items():
    for race_key, eds in races.items():
        for ed_key, ages in eds.items():
            for age_key, count in ages.items():
                output.append([year, race_key, ed_key, age_key, count])

with open('mortality.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['year', 'race_key', 'ed_key', 'age_key', 'deaths'])
    writer.writerows(output)
