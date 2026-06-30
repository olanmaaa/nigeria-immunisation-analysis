# ============================================
# 05_trend_analysis.R
# Monthly and quarterly immunisation coverage
# trends across Kano, Lagos, and Anambra
# (2022-2024)
# ============================================

quarterly_coverage <- df_clean |> 
  group_by(year, quarter, state) |>
  summarise(mean_coverage_rate=(mean(coverage_rate) * 100 ), .groups="drop")
  
quarterly_coverage

quarterly_coverage <- quarterly_coverage |>
  mutate (year_quarter = paste (year, quarter, sep = "_")) |>
  mutate(year_quarter = factor(year_quarter, levels = unique(year_quarter[order(year, quarter)])))

levels(quarterly_coverage$year_quarter)

quarterly_coverage_plot <- ggplot(quarterly_coverage,
                                  aes(x = year_quarter, y = mean_coverage_rate,
                                      color = state, group = state)) +
  geom_line() +
  geom_hline(yintercept = 80, linetype = "dashed", color = "red") +
  geom_point() +
  labs(title = "Quarterly Immunisation Coverage Trends by State (2022-2024)",
       subtitle = "All states show gradual improvement with consistent seasonal dips in Q2 and Q3",
       x = "Quarter",
       y = "Mean Coverage Rate (%)",
       color = "State") +
  scale_color_manual(values = c("Kano" = "grey60",
                                "Lagos" = "#1A4F72",
                                "Anambra" = "#4A90C4")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

quarterly_coverage_plot

ggsave("plots/quarterly_coverage_plot.png",
       plot = quarterly_coverage_plot,
       width = 12,
       height = 6,
       dpi = 300)


# All three states demonstrate a consistent seasonal pattern across 2022-2024 —
# coverage peaks in Q1 and Q4 and dips in Q2 and Q3, corresponding to Nigeria's
# rainy season (April-September). The synchronicity of this pattern across
# geographically and programmatically distinct states suggests a shared national
# driver rather than state-specific factors, most likely seasonal deterioration
# in facility access, outreach penetration, and caregiver mobility.


# Q3 2022 represents the universal lowest coverage point across all three states
# — Kano (43.7%), Anambra (53.5%), and Lagos (66.2%). This may reflect a
# combination of baseline programme weakness at the start of the analysis period
# and possible post-COVID health system recovery still incomplete in mid-2022.
# Encouragingly, Q3 coverage improves year-on-year across all states, suggesting
# gradual system strengthening even during the most challenging seasonal period.

# The plot reinforces findings from earlier analyses — Lagos consistently
# outperforms Anambra and Kano across all quarters. Despite three years of
# gradual improvement, Kano remains below 55% coverage in every quarter,
# never approaching the 80% herd immunity threshold — underscoring the
# depth of the programmatic challenge in the North-West region.



