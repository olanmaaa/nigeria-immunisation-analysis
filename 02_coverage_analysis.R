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

#3. visualising 
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