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
| `02_coverage_analysis.R` | Coverage summaries by state, setting, vaccine group, facility type, and target disease — includes Welch's ANOVA and Games-Howell post-hoc tests |
| `03_lga_analysis.R` | LGA-level coverage variation and ranking within each state |
| `04_zero_dose_analysis.R` | Zero-dose burden, dropout rates, and missed vaccination drivers by state and setting |
| `05_trend_analysis.R` | Quarterly immunisation coverage trends across 2022-2024 |
---

## Tools

- **R version 4.6.1** (2026-06-24)
- **tidyverse** — data manipulation, visualisation (dplyr, ggplot2, tidyr, lubridate)
- **readxl** — Excel data import
- **janitor** — column name cleaning
- **car** — Levene's test for homogeneity of variance
- **rstatix** — Games-Howell post-hoc test

## Statistical Methods

Assumption checking and inferential testing were conducted for the 
facility type coverage analysis, stratified by state:

- **Normality** — assessed visually using Q-Q plots of model residuals
- **Homogeneity of variance** — tested formally using Levene's Test 
  (car package); violated across all three states (p < 0.001)
- **Welch's ANOVA** — used in place of standard ANOVA to account for 
  unequal variances across facility type groups
- **Games-Howell post-hoc test** — used for pairwise comparisons 
  following Welch's ANOVA, as it does not assume equal variances

  All analyses were stratified by state (Kano, Lagos, Anambra) rather 
than pooled, to account for the distinct programmatic contexts of 
each state. 

## Key Findings

- No state meets the **80% herd immunity threshold** across any indicator 
  over 2022-2024, indicating a systemic nationwide immunisation gap.
- **Kano** records the weakest performance across all indicators — lowest 
  coverage, highest zero-dose burden (59,118 children), and deepest dropout.
- **Coverage improved gradually** across all three states from 2022-2024, 
  but the pace remains insufficient to reach programme targets near term.
- **Lagos and Anambra have comparable absolute zero-dose burdens** despite 
  Lagos' higher coverage — a coverage-burden paradox driven by population size.
- **Outreach posts outperform PHCs in Kano**, suggesting community-based 
  delivery is more effective than fixed facility attendance in the North-West.
- A **consistent Q2/Q3 seasonal dip** affects all states simultaneously, 
  warranting targeted campaign intensification during Nigeria's rainy season.

## Visualisations

All plots are saved in the `plots/` folder. Key visualisations include:

- `state_setting_coverage.png` — Mean coverage rate by state and urban/rural setting
- `vaccine_group_trend.png` — Coverage dropout trend across vaccine groups by state
- `lga_coverage_plot.png` — LGA-level coverage ranking within each state
- `disease_coverage_heatmap.png` — Annotated heatmap of coverage by target disease and state
- `zero_dose_boxplot.png` — Distribution of zero-dose rates across LGAs by state
- `missed_drivers_plot.png` — Stockout vs access barrier rates by state
- `quarterly_coverage_plot.png` — Quarterly coverage trends across 2022-2024
