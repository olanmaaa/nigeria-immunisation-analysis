library(tidyverse)
library(readxl)
library(janitor)
library(lubridate)
library(car)
library(rstatix)

# ============================================
# 1. COVERAGE RATE BY STATE
# ============================================

df_clean |>
  group_by(state) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100))

# Lagos leads at 70.8%, followed by Anambra (58.2%) and Kano (48.3%)
# All three states fall below the 80% herd immunity threshold

# ============================================
# 2. COVERAGE RATE BY STATE AND SETTING
# ============================================

state_setting <- df_clean |>
  group_by(state, setting_urban_rural) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100), .groups = "drop")

state_setting

# Urban Lagos is the only state-setting combination to meet the 80% threshold
# The urban-rural gap is most severe in Kano (62.5% urban vs 38.9% rural)
# Anambra sits at 65.5% urban and 55.0% rural — the smallest urban-rural gap
# of the three states, suggesting more equitable distribution despite lower
# overall coverage

# ============================================
# 3. VISUALISING COVERAGE RATE BY STATE AND SETTING
# ============================================

state_setting_coverage <- ggplot(state_setting, 
                                 aes(x = state, y = mean_coverage_rate, 
                                     fill = setting_urban_rural)) +
  geom_col(position = "dodge") +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red") +
  labs(title = "Mean Coverage Rate by State and Setting",
       x = "State",
       y = "Mean Coverage Rate (%)",
       fill = "Setting") +
  scale_fill_manual(values = c("Rural" = "grey60", "Urban" = "#1A4F72")) +
  theme_minimal()

state_setting_coverage

ggsave("plots/state_setting_coverage.png",
       plot = state_setting_coverage,
       width = 8,
       height = 5,
       dpi = 300)

# ============================================
# 4. COVERAGE RATE BY VACCINE GROUP
# ============================================

df_clean |>
  group_by(vaccine_group) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100)) |>
  arrange(desc(mean_coverage_rate))

# Coverage decreases progressively as vaccine age increases, consistent with
# the immunisation dropout effect — a well-documented EPI challenge where
# caregivers deprioritise later-series doses as children get older.
# The 6-week dose slightly outperforming birth doses may reflect stronger
# outreach and PHC attendance at that contact point compared to facility
# delivery dependence for birth doses.
# All vaccine groups fall below the 80% herd immunity threshold.
# Next step: disaggregate by state to identify which states are driving
# low coverage in later dose groups (9-month and 15-month doses).

df_clean |>
  group_by(state, vaccine_group) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100), .groups = "drop") |>
  arrange(desc(mean_coverage_rate))

# Disaggregation reveals a masking effect — Lagos performs reasonably well
# across most vaccine groups (>70%), indicating that low aggregate coverage
# is driven disproportionately by Kano and to a lesser extent Anambra.
# Programmatic interventions should therefore be state-specific rather than
# uniform across all three states.

# Kano's 15-month dose coverage (38.7%) is the single worst performing
# state-vaccine group combination. Even Lagos, the best performer, drops
# below 60% at the 15-month dose, indicating that late-schedule dropout —
# where children who initially contacted the health system fail to complete
# the full immunisation schedule — is a cross-state challenge, albeit most
# severe in Kano.

# Notably, 6-week doses consistently outperform birth doses across all three
# states. This likely reflects the high prevalence of home births in Nigeria,
# where birth doses (BCG, OPV0, HepB0) are missed entirely due to absence
# of facility delivery. Children may only first contact the health system at
# the 6-week PHC visit, making that the de facto first immunisation contact
# point. Caregiver hesitancy at birth is an additional possible contributor
# but requires further investigation before conclusions can be drawn.

vaccine_group_state <- df_clean |>
  mutate(vaccine_group = factor(vaccine_group, levels = c(
    "Birth Doses", "6-Week Doses", "10-Week Doses",
    "14-Week Doses", "9-Month Doses", "15-Month Doses"))) |>
  group_by(state, vaccine_group) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100), .groups = "drop")

vaccine_group_state

vaccine_group_trend <- ggplot(vaccine_group_state,
                              aes(x = vaccine_group, y = mean_coverage_rate,
                                  color = state, group = state)) +
  geom_line() +
  geom_point() +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red") +
  labs(title = "Immunisation Coverage Rate by Vaccine Group Across States",
       x = "Vaccine Group",
       y = "Mean Coverage Rate (%)",
       color = "State") +
  scale_color_manual(values = c("Kano" = "grey60",
                                "Lagos" = "#1A4F72",
                                "Anambra" = "#4A90C4")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

vaccine_group_trend

ggsave("plots/vaccine_group_trend.png",
       plot = vaccine_group_trend,
       width = 8,
       height = 5,
       dpi = 300)

# ============================================
# 5. COVERAGE RATE BY FACILITY TYPE
# ============================================

facility_type_state <- df_clean |>
  group_by(state, facility_type) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100), .groups = "drop") |>
  arrange(desc(mean_coverage_rate))

facility_type_state

# Teaching hospitals report the highest coverage in Lagos (73.7%),
# while private clinics lead in Anambra (59.1%) and outreach posts in Kano (50.1%)
# suggesting that the most effective delivery channel varies by state context.

# PHC coverage is lowest in Kano despite being the backbone of Nigeria's primary
# healthcare system, indicating that fixed facility attendance is a barrier in
# the North-West. The strong performance of outreach posts in Kano suggests
# caregiver willingness to access services when brought closer to communities,
# pointing to demand-side barriers rather than outright vaccine hesitancy.

# Private clinic performance across Lagos and Anambra may reflect socioeconomic
# selection bias — caregivers accessing private providers likely have greater
# means and health-seeking behaviour, which should be considered when
# interpreting these figures.

# ============================================
# ANOVA: COVERAGE RATE BY FACILITY TYPE
# STRATIFIED BY STATE
# ============================================

# ASSUMPTION 1: INDEPENDENCE
# Observations are stratified by state and analysed separately. Within each
# state, LGA-level measurements are treated as independent. However, the
# repeated monthly measurements from the same LGAs across 36 months introduce
# potential autocorrelation — a form of non-independence that standard ANOVA
# does not account for. A mixed effects model with LGA as a random effect
# would be more rigorous. This limitation is acknowledged and the ANOVA
# results should be interpreted with appropriate caution.

# ASSUMPTION 2: NORMALITY
# Q-Q plots of model residuals show approximate normality for Anambra, with
# mild S-shaped deviation in Lagos and Kano, indicative of slight platykurtosis
# (lighter tails than a normal distribution). Given the large sample size
# (n = 6,840 per state), the Central Limit Theorem ensures these mild violations
# are unlikely to meaningfully affect the validity of results. We proceed
# with caution and note this as a limitation.

anova_lagos <- aov(coverage_rate * 100 ~ facility_type,
                   data = df_clean |> filter(state == "Lagos"))

anova_anambra <- aov(coverage_rate * 100 ~ facility_type,
                     data = df_clean |> filter(state == "Anambra"))

anova_kano <- aov(coverage_rate * 100 ~ facility_type,
                  data = df_clean |> filter(state == "Kano"))

qqnorm(residuals(anova_lagos), main = "Q-Q Plot: Lagos")
qqline(residuals(anova_lagos), col = "red")

qqnorm(residuals(anova_anambra), main = "Q-Q Plot: Anambra")
qqline(residuals(anova_anambra), col = "red")

qqnorm(residuals(anova_kano), main = "Q-Q Plot: Kano")
qqline(residuals(anova_kano), col = "red")

# ASSUMPTION 3: HOMOGENEITY OF VARIANCE
# Levene's test was significant across all three states:
# Lagos: F(4, 6835) = 10.54, p < 0.001
# Anambra: F(4, 6835) = 9.27, p < 0.001
# Kano: F(4, 6835) = 11.21, p < 0.001
# The homogeneity of variance assumption is violated in all three states.
# Welch's ANOVA was therefore used in place of standard ANOVA, as it does
# not assume equal variances across groups.

leveneTest(coverage_rate * 100 ~ facility_type,
           data = df_clean |> filter(state == "Lagos"))

leveneTest(coverage_rate * 100 ~ facility_type,
           data = df_clean |> filter(state == "Anambra"))

leveneTest(coverage_rate * 100 ~ facility_type,
           data = df_clean |> filter(state == "Kano"))

# WELCH'S ANOVA RESULTS
# All three states returned highly significant F-statistics:
# Lagos: F(4, 2205.9) = 16.47, p < 0.001
# Anambra: F(4, 2157.8) = 14.01, p < 0.001
# Kano: F(4, 2286.7) = 8.36, p < 0.001
# These results indicate that at least one facility type has a significantly
# different mean coverage rate from the others within each state.

oneway.test(coverage_rate * 100 ~ facility_type,
            data = df_clean |> filter(state == "Lagos"),
            var.equal = FALSE)

oneway.test(coverage_rate * 100 ~ facility_type,
            data = df_clean |> filter(state == "Anambra"),
            var.equal = FALSE)

oneway.test(coverage_rate * 100 ~ facility_type,
            data = df_clean |> filter(state == "Kano"),
            var.equal = FALSE)

# POST-HOC ANALYSIS: GAMES-HOWELL TEST
# The Games-Howell test was used for post-hoc comparisons as it does not
# assume equal variances, consistent with Welch's ANOVA.

# Lagos: Teaching Hospital and Private Clinic consistently outperform PHC,
# General Hospital, and Outreach Post. A clear two-cluster structure emerges —
# tertiary and private facilities outperform public primary facilities.
# The largest significant gap is between Outreach Post and Teaching Hospital
# (4.15 percentage points, p < 0.001).

# Anambra: The pattern reverses — Teaching Hospital performs significantly
# worse than PHC, Private Clinic, and Outreach Post. This may reflect
# differences in the patient populations accessing tertiary care in Anambra,
# or structural challenges specific to Teaching Hospital operations in the
# South-East. Private Clinic and PHC perform comparably (ns).

# Kano: Fewer significant pairs and smaller effect sizes than Lagos or Anambra.
# The most notable finding is that Outreach Post significantly outperforms PHC
# (2.76 percentage points, p < 0.001), consistent with the descriptive finding
# that bringing services to communities is more effective than fixed facility
# attendance in the North-West context — likely reflecting geographic barriers
# and distance to formal health facilities.

df_clean |>
  filter(state == "Lagos") |>
  mutate(coverage_pct = coverage_rate * 100) |>
  games_howell_test(coverage_pct ~ facility_type)

df_clean |>
  filter(state == "Anambra") |>
  mutate(coverage_pct = coverage_rate * 100) |>
  games_howell_test(coverage_pct ~ facility_type)

df_clean |>
  filter(state == "Kano") |>
  mutate(coverage_pct = coverage_rate * 100) |>
  games_howell_test(coverage_pct ~ facility_type)

# OVERALL CONCLUSION
# No single facility type consistently outperforms others across all three states.
# The relationship between facility type and immunisation coverage is
# context-dependent, challenging any blanket national recommendation about
# which facility type to prioritise. State-specific programmatic strategies
# are warranted, with outreach intensification particularly indicated for Kano.
# All observed differences, while statistically significant, are modest in
# magnitude (< 5 percentage points) and should be interpreted alongside
# programmatic significance — small percentage gaps can represent hundreds


#coverage by disease target

disease_coverage <- df_clean |>
  group_by (target_disease,state) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100), .groups="drop")|>
  arrange(desc(mean_coverage_rate))|>
  as.data.frame()

disease_coverage

# No disease achieves the general 80% herd immunity threshold across any state,
# underscoring the systemic nature of immunisation underperformance across
# Kano, Lagos, and Anambra.

# Measles/Rubella records the lowest coverage in both Anambra (46.6%) and
# Kano (38.7%), and is among the lowest in Lagos (56.5%). This is particularly
# alarming given the WHO measles elimination target of 95% two-dose coverage —
# all three states fall critically short, with Kano sitting 56 percentage points
# below the elimination threshold. Given measles' exceptionally high
# transmissibility (R0 of 12-18), coverage at these levels leaves populations
# highly vulnerable to outbreak. State-funded targeted measles outreach and
# supplementary immunisation activities are urgently warranted across all
# three states.

# Rotavirus records the highest coverage in both Kano (51.6%) and Anambra
# (62.3%), and leads in Lagos (75.7%) as well. This relative strength may
# reflect targeted supplementary immunisation activities or prioritisation
# of rotavirus within state EPI programmes. However, even the highest
# performing disease-state combination falls short of the 80% threshold,
# indicating that strong relative performance does not equate to adequate
# absolute coverage.

# Hepatitis B and Tuberculosis (birth dose antigens) perform consistently
# across states, reflecting their position at the first health system contact
# point. Their relatively stronger performance compared to later-schedule
# antigens is consistent with the dropout effect documented in section 4.

# Overall, disease-specific coverage remains insufficient across all three
# states. The South-West (Lagos) consistently leads but does not meet targets
# for later-schedule antigens. The North-West (Kano) presents the most urgent
# disease-specific gaps, particularly for measles, meningitis A, and
# yellow fever — all diseases with significant outbreak potential in
# northern Nigeria.

#visualisizng disease coverage

disease_coverage_heatmap <- ggplot(disease_coverage, 
                                   aes(x = state, y = target_disease, 
                                       fill = mean_coverage_rate)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = round(mean_coverage_rate, 1)), 
            color = "black", size = 3) +
  scale_fill_gradient2(low = "red", mid = "yellow", high = "green",
                       midpoint = 80,
                       limits = c(30, 90),
                       name = "Coverage (%)") +
  labs(title = "Immunisation Coverage Rate by Target Disease and State",
       x = "State",
       y = "Target Disease") +
  theme_minimal() +
  theme(axis.text.y = element_text(size = 8))

disease_coverage_heatmap

ggsave("plots/disease_coverage_heatmap.png",
       plot = disease_coverage_heatmap,
       width = 10,
       height = 6,
       dpi = 300)

disease_coverage_heatmap