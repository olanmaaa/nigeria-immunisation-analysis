#1. coverage rate by state 

df_clean |> 
  group_by (state)|>
  summarise (mean_coverage_rate = mean(coverage_rate * 100))
# Lagos leads at 70.8%, followed by Anambra (58.2%) and Kano (48.3%)
# All three states fall below the 80% herd immunity threshold

#2. coverage rate by state-setting

state_setting <- df_clean |> 
  group_by (state, setting_urban_rural)|>
  summarise (mean_coverage_rate = mean(coverage_rate * 100))
state_setting
#Urban-Lagos is the only state settong to hit the 80% coverage rate
#Anambra and Kano perform below ideal with the Urban-Rural gap in Kano being extremely low 62.5% vs 38.9%
#Anambra falls at about 55.5% for Rural and 65.5% for Urban

#3. visualising coverage rate by state and setting
state_setting_coverage <- ggplot(state_setting, aes(x = state, y = mean_coverage_rate, fill = setting_urban_rural)) +
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

#4. coverage by vaccine group
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
  group_by(state,vaccine_group) |>
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
  mutate(vaccine_group = factor(vaccine_group, levels = c("Birth Doses", "6-Week Doses", "10-Week Doses", "14-Week Doses", "9-Month Doses", "15-Month Doses")))|>
  group_by(state, vaccine_group) |>
  summarise(mean_coverage_rate = mean(coverage_rate * 100, .groups="drop"))

vaccine_group_state

vaccine_group_trend <- ggplot(vaccine_group_state, 
                              aes(x = vaccine_group, y = mean_coverage_rate, color = state, group = state)) +
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