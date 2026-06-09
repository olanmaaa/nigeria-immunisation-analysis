# ============================================
# 04_zero_dose_analysis.R
# Analysis of zero-dose children across
# Kano, Lagos, and Anambra (2022-2024)
# Zero-dose defined as children who received
# no vaccines, proxied by Penta1 as the
# standard EPI tracer antigen
# ============================================

zero_dose <- df_clean |>
  filter(!is.na(zero_dose_children))

# ============================================
# NOTE ON DATA STRUCTURE
# ============================================
# Zero-dose and related indicators (zero_dose_children, zero_dose_rate,
# dropout_rate_penta1_penta3, missed_stockout, missed_access_barrier)
# are populated only for Penta1 rows — one observation per LGA per month.
# Penta1 is used as the standard EPI tracer antigen, consistent with
# NPHCDA and UNICEF reporting conventions. A child missing Penta1 is
# considered a proxy for having received no vaccines, as first scheduled
# contact with the immunisation system typically occurs at the 6-week visit.
# All other vaccine rows carry NA for these columns, as the indicators
# relate to a child's overall immunisation journey


# ============================================
# TOTAL ZERO-DOSE BURDEN BY STATE
# ============================================
total_zero_dose <- zero_dose|>
  group_by(state)|>
  summarise(total_zero_dose = sum(zero_dose_children))|>
  mutate (monthly_average= total_zero_dose/36,
          lga_monthly_average = monthly_average/10)
total_zero_dose



# Kano records the highest total zero-dose burden across the three-year period
# (59,118 children), nearly double that of Lagos (30,668) and Anambra (33,156).
# On a monthly basis, Kano produces approximately 1,642 zero-dose children
# per month — equivalent to 164 unreached children per LGA per month.
# In comparison, Lagos and Anambra average 852 and 921 zero-dose children
# per month respectively (85 and 92 per LGA per month). The scale of Kano's
# burden relative to the other states signals deep-rooted healthcare inequities
# characteristic of the North-West region, where geographic isolation, 
# infrastructural gaps, and demand-side barriers compound to leave large
# numbers of children completely unreached by the immunisation system.

# Notably, Lagos and Anambra record similar absolute zero-dose burdens despite
# Lagos demonstrating significantly higher coverage rates throughout this
# analysis. This reflects the coverage-burden paradox — Lagos' larger
# population means that even at higher coverage rates, the absolute number
# of missed children remains comparable to Anambra. This distinction is
# programmatically important: Lagos requires large-scale urban outreach
# to address its absolute burden, while Anambra requires system-wide
# coverage improvement to address its proportionally higher miss rate.
# Coverage rates and absolute zero-dose counts should therefore always
# be interpreted together rather than in isolation.

# ============================================
# ZERO-DOSE BURDEN BY STATE AND SETTING
# ============================================
zero_dose_setting <- zero_dose |>
  group_by(state, setting_urban_rural) |>
  summarise (total_zero_dose = sum(zero_dose_children),
             mean_zero_dose_rate = mean(zero_dose_rate * 100),
             .groups = "drop")
zero_dose_setting



# Rural areas carry a disproportionately higher zero-dose burden across all
# three states, consistent with the urban-rural coverage gaps identified in
# 02_coverage_analysis.R. This pattern reflects the compounding effect of
# geographic distance, limited facility access, and weaker outreach penetration
# in rural communities.

# Kano Rural records the highest absolute zero-dose burden (35,702 children)
# and the highest zero-dose rate (36.7%) — meaning more than 1 in 3 eligible
# children in rural Kano received no vaccines at all over the three-year period.
# This represents a critical public health failure requiring urgent targeted
# outreach and community mobilisation in rural North-West Nigeria.

# Kano Urban, despite being an urban setting, still records a substantial
# zero-dose rate of 20.5% — higher than both Lagos Rural (20.6%) and
# Anambra Urban (17.9%). This suggests that urbanicity alone does not
# guarantee adequate immunisation reach in Kano, and that demand-side
# barriers may be operating even in urban Kano settings.

# Lagos Urban records the lowest zero-dose rate at 7.59%, reflecting the
# combined effect of strong health infrastructure, higher socioeconomic
# status, and greater health-seeking behaviour in urban Lagos. However,
# Lagos Rural carries a zero-dose rate of 20.6% (about 1 in 5 children) — comparable to Kano Urban —
# indicating that rural Lagos remains significantly underserved despite the
# state's overall strong performance.

# Anambra Rural records a zero-dose rate of 24.9%, meaning approximately
# 1 in 4 eligible children in rural Anambra received no vaccines. Combined
# with Anambra Urban at 17.9%, this reinforces the earlier finding of a
# systemic state-wide gap rather than localised underperformance — both
# settings fall short, suggesting demand-generation interventions are
# needed uniformly across Anambra rather than selectively in rural areas alone.

# Important interpretive note: zero-dose rates cannot be summed across
# settings to derive a state-level rate, as rural and urban populations
# have different sizes. A weighted average accounting for population
# denominators would be required for a valid state-level zero-dose rate.
# Additionally, children not classified as zero-dose (75.1% in Anambra Rural
# for example) are not necessarily fully vaccinated — they may have received
# some but not all scheduled antigens, captured separately by the dropout
# rate analysis in section 4.


# ============================================
# ZERO-DOSE BURDEN BY LGA
# ============================================
lga_zero_dose <- zero_dose |>
  group_by(state,lga) |>
  summarise (total_zero_dose = sum(zero_dose_children),
             mean_zero_dose_rate = mean(zero_dose_rate * 100),
             .groups = "drop")|>
  arrange (desc(total_zero_dose)) |>
  as.data.frame()
lga_zero_dose


# All ten top-burden LGAs belong to Kano, with Ungogo (6,693 children, 40.3%)
# and Kumbuntsau (6,490 children, 39.9%) recording the highest absolute and
# relative zero-dose burden. A rate of 40% indicates approximately 2 in 5
# eligible children in these LGAs received no vaccines — a public health
# emergency level finding warranting immediate targeted intervention.

# Ikeja (4,453 children, 13.8%) records a comparable absolute burden to
# Fagge — Kano's best performing LGA (4,819 children, 17.1%). However the
# rate difference reveals the underlying story — Ikeja's burden is
# population-driven while Fagge's reflects genuine system underreach.

# The population effect is further illustrated by Onitsha North (4,156
# children, 19.5%) vs Ikeja (4,453 children, 13.8%) — higher absolute
# count in Ikeja but lower rate, confirming that absolute burden and
# zero-dose rate must always be interpreted together.

# Surulere records the lowest zero-dose burden across all 30 LGAs
# (1,113 children, 3.5%) — the strongest performing LGA in the dataset.


zero_dose_boxplot <- ggplot(zero_dose, 
                            aes(x = state, y = zero_dose_rate * 100, 
                                fill = state)) +
  geom_boxplot() +
  labs(title = "Distribution of Zero-Dose Rates Across LGAs by State",
       x = "State",
       y = "Zero-Dose Rate (%)",
       caption = "Kano shows high inter-LGA variability, necessitating targeted LGA-level interventions.\nAnambra shows the most uniform distribution; Lagos shows moderate variability despite lower overall rates.") +
  scale_fill_manual(values = c("Kano" = "grey60",
                               "Lagos" = "#1A4F72",
                               "Anambra" = "#4A90C4")) +
  theme_minimal()+
  theme(plot.caption = element_text(size = 8, hjust = 0.5),
        plot.title = element_text(size = 12, hjust = 0.5))

zero_dose_boxplot

ggsave("plots/zero_dose_boxplot.png",
       plot = zero_dose_boxplot,
       width = 10,
       height = 6,
       dpi = 300)



# ============================================
# DROPOUT RATE ANALYSIS (PENTA1 -> PENTA3)
# ============================================

dropout_rate <- zero_dose |>
  group_by(state) |>
  summarise (mean_dropout_rate = mean(dropout_rate_penta1_3)* 100,
             .groups = "drop")|>
  arrange(desc(mean_dropout_rate))

dropout_rate


# Mean dropout rates are remarkably uniform across all three states:
# Kano (12.1%), Lagos (12.0%), and Anambra (11.8%) — a spread of only
# 0.3 percentage points despite dramatic differences in overall coverage
# and zero-dose burden. This uniformity across highly heterogeneous contexts
# suggests a demand-side behavioural pattern rather than a supply or
# system failure — if dropout were driven by health system capacity,
# Kano would be expected to significantly outperform Lagos.
# This pattern is consistent with complacency dropout — where caregivers
# perceive partial vaccination as sufficient or feel reduced urgency as
# children grow older and appear healthy. National-level behavioural
# interventions such as caregiver education campaigns, community health
# worker follow-up, and SMS reminder systems are warranted rather than
# state-specific programme fixes.

# ============================================
# MISSED VACCINATION DRIVERS
# ============================================
missed_drivers <- zero_dose |>
  group_by(state) |>
  summarise (mean_stockout_rate = mean(missed_stockout=="Yes")*100,
             mean_access_barrier_rate = mean(missed_access_barrier == "Yes")*100,
             .groups = "drop")
  
missed_drivers


# Access barriers are the dominant missed vaccination driver across all three
# states — Kano (17.8%), Anambra (17.5%), and Lagos (17.5%) — suggesting
# that geographic, financial, and logistical barriers to facility access
# are a consistent nationwide challenge regardless of state-level performance.

# Stockout rates are similar across Anambra (10.3%) and Kano (10.3%),
# while Lagos records a notably higher stockout rate (14.4%). This is
# counterintuitive given Lagos' stronger overall performance and may reflect:
# 1. Programme complacency: Lagos' relatively higher coverage may reduce
#    its prioritisation for supply chain reinforcement, paradoxically
#    increasing stockout frequency
# 2. Population pressure: higher population density accelerates vaccine
#    consumption, which can strain supply chains between resupply cycles
# Further investigation would be required to confirm which mechanism dominates.

# The consistency of access barrier rates across all three states — despite
# dramatic differences in geography, urbanicity, and health system strength —
# mirrors the uniform dropout pattern observed in section 4, further
# supporting the case for national-level demand-side interventions alongside
# state-specific supply chain improvements.

missed_drivers_long <- missed_drivers |>
  pivot_longer(cols = c(mean_stockout_rate, mean_access_barrier_rate),
               names_to = "driver",
               values_to = "rate") |>
  mutate(driver = dplyr::recode(driver,
                         "mean_stockout_rate" = "Stockout",
                         "mean_access_barrier_rate" = "Access Barrier"))

missed_drivers_plot <- ggplot(missed_drivers_long,
                              aes(x = driver, y = rate, fill = state)) +
  geom_col(position = "dodge") +
  labs(title = "Drivers of Missed Vaccination by State",
       x = "Driver",
       y = "Prevalence Rate (%)",
       fill = "State") +
  scale_fill_manual(values = c("Kano" = "grey60",
                               "Lagos" = "#1A4F72",
                               "Anambra" = "#4A90C4")) +
  theme_minimal()+
  theme(plot.title = element_text(size=12, hjust=0.5))

missed_drivers_plot

ggsave("plots/missed_drivers_plot.png",
       plot = missed_drivers_plot,
       width = 8,
       height = 5,
       dpi = 300)