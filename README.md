# Nigeria Routine Immunisation Coverage Analysis (2022-2024)

This project examines routine immunisation coverage trends across three Nigerian 
states (Kano, Lagos, and Anambra), with a focus on identifying zero-dose children, 
urban-rural equity gaps, vaccine dropout patterns, and making actionable 
recommendations for targeted outreach by identifying facility types associated 
with better coverage outcomes.

---

## Data Disclaimer

The dataset used in this project is **synthetic**. It was generated using Claude 
(Anthropic) to mimic realistic Nigerian immunisation data trends, informed by 
actual EPI programme structure, NPHCDA reporting conventions, and known 
state-level coverage patterns. It is intended solely for the purpose of 
demonstrating public health data analysis skills.

---

## Data Structure

- 20,520 observations across 26 variables
- Three states: Kano (North-West), Lagos (South-West), Anambra (South-East)
- 10 LGAs per state (30 total), classified as urban or rural
- 19 vaccine antigens across 6 age-based groups (birth doses through 15-month doses)
- Monthly data spanning January 2022 to December 2024
- Key variables include: state, LGA, setting, facility type, vaccine, vaccine group,
  eligible children, children vaccinated, coverage rate, zero-dose children, 
  zero-dose rate, and dropout rate (Penta1 to Penta3)

---

## Analysis Structure

| Script | Description |
|--------|-------------|
| `01_data_cleaning.R` | Data loading, column renaming, type conversion, and validation |
| `02_coverage_analysis.R` | Coverage summaries by state, LGA, vaccine group, and urban-rural setting |
| `03_zero_dose_analysis.R` | Zero-dose burden, dropout rates, and missed vaccination drivers |
| `04_trend_analysis.R` | Monthly and quarterly coverage trends across 2022-2024 |

---

## Tools

- **R version 4.5.2** (2025-10-31 ucrt)
- **tidyverse** (includes dplyr, ggplot2, tidyr, lubridate)
- **janitor** — column name cleaning
- **readxl** — Excel data import