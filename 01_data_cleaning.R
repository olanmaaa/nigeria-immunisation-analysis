library(lubridate)
library(dplyr)
library(readxl)
library(ggplot2)
library(janitor)
library(tidyverse)

# 1. Read the Excel file
df <- read_excel(
  "C:/Users/Olanma.O_SYDANI/Desktop/sample data/Nigeria_Immunisation_Dashboard_Data.xlsx"
)

# 2. Rename and mutate
df <- df |>
  rename(Period = `Period (YYYY-MM)`) |>
  mutate(
    Period = ym(Period),          # converts "2022-01" to a proper date
    Year   = as.integer(Year),
    Month  = as.integer(Month)
  )

# 3. Checking the data
dim(df)
str(df)
summary(df)
names (df)

#4. Cleaning up column names
df_clean <- df |>
  clean_names(case="snake")
names(df_clean)

#5. Checking for distinct categories in relevant columns
df_clean |>
  summarise(across(where(is.character), n_distinct)) |>
  pivot_longer(everything(), names_to = "column", values_to = "n_distinct") |>
  as.data.frame()
