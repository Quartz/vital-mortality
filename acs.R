library(dplyr)

# Load ACS data
# This is from IPUMS (extract #24 on my account).
# It contains: "Race, Hispanic ethnicity, age, and education level for all people over 20 years of age (2000 - 2015)"
acs <- read.csv("usa_00024.csv", stringsAsFactors = FALSE)

# Delete unneeded columns
acs$DATANUM <- NULL
acs$SERIAL <- NULL
acs$HHWT <- NULL
acs$GQ <- NULL
acs$PERNUM <- NULL
acs$RACED <- NULL
acs$HISPAND <- NULL
acs$EDUC <- NULL

# Convert years to a factor
acs$year <- as.factor(as.character(acs$YEAR))

# Convert race and Hispanic ethnicity to categories
acs$racehisp <- NA

acs$racehisp[acs$HISPAN > 0 & acs$HISPAN <= 4] <- "Hispanic"
acs$racehisp[acs$RACE == 1 & acs$HISPAN == 0] <- "White"
acs$racehisp[acs$RACE == 2 & acs$HISPAN == 0] <- "Black"

acs$racehisp <- factor(acs$racehisp, level=c("White", "Black", "Hispanic"))

# Convert education to categories
acs$educ <- NA

acs$educ[acs$EDUCD >= 2 & acs$EDUCD <= 64] <- "High school degree or less"
acs$educ[acs$EDUCD >= 65 & acs$EDUCD <= 100] <- "Some college but no BA"
acs$educ[acs$EDUCD >= 101 & acs$EDUCD <= 116] <- "BA or more"

acs$educ <- factor(acs$educ, levels=c("High school degree or less", "Some college but no BA", "BA or more"))

# Convert age to categories (for age-adjustment)
acs$age.group <- NA

acs$age.group[acs$AGE < 30] <- "20-29"
acs$age.group[acs$AGE >= 30 & acs$AGE < 40] <- "30-39"
acs$age.group[acs$AGE >= 40 & acs$AGE < 50] <- "40-49"
acs$age.group[acs$AGE >= 50 & acs$AGE < 60] <- "50-59"
acs$age.group[acs$AGE >= 60 & acs$AGE < 70] <- "60-69"
acs$age.group[acs$AGE >= 70 & acs$AGE < 80] <- "70-79"
acs$age.group[acs$AGE >= 80 & acs$AGE < 90] <- "80-89"
acs$age.group[acs$AGE >= 90] <- "90+"

acs$age.group <- factor(acs$age.group, levels = c("20-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80-89", "90+"))

# Population age-standardization proportions
age.shares <- acs %>%
  filter(year == 2009) %>%
  group_by(age.group) %>%
  summarise(count = n()) %>%
  mutate(share = count / sum(count)) %>%
  select(-count)

# Compute totals by year, race/hispanic, and education
acs.totals <- acs %>%
  group_by(YEAR, racehisp, educ, age.group) %>%
  summarise(population = sum(PERWT))

# Save totals
write.csv(acs.totals, "acs.totals.csv", row.names = FALSE)

# Attach population shares for age-adjustment
acs.totals.with.shares <- merge(
  acs.totals,
  age.shares,
  by.x = "age.group",
  by.y = "age.group")

# Load pre-processed mortality data (see `mortality.py`)
mortality <- read.csv("mortality.csv")

# Merge mortality data with acs totals
merged <- merge(
  acs.totals.with.shares,
  mortality,
  by.x = c("YEAR", "racehisp", "educ", "age.group"),
  by.y = c("year", "race_key", "ed_key", "age_key")
)

# Compute age-standardized death rates for each group
rates <- merged %>%
  mutate(
    crude.rate = deaths / (population / 100000),
    weighted.rate = crude.rate * share)

rates.asdr <- rates %>%
  group_by(YEAR, racehisp, educ) %>%
  summarise(asdr = sum(weighted.rate))

rates.pivot <- dcast(rates.asdr, racehisp + educ ~ YEAR)

# Save rates
write.csv(rates.pivot, "asdr.csv", row.names = FALSE)
