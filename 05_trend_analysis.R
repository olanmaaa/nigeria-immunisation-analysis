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