library(tidyverse)
library(readxl)
library(janitor)
library(lubridate)
library(car)
library(rstatix)

# ============================================
# 03_lga_analysis.R
# LGA-level variation in immunisation coverage
# across Kano, Lagos, and Anambra (2022-2024)
# ============================================

lga_coverage <- df_clean |>
  group_by(state,lga) |>
  summarise(mean_coverage_rate = mean (coverage_rate*100), .groups = "drop")|>
  arrange(desc(mean_coverage_rate))

lga_coverage
#visualising the findings
lga_coverage_plot <- ggplot(lga_coverage, 
                            aes(x = mean_coverage_rate, y = reorder(lga,mean_coverage_rate), fill = state)) +
  geom_col() +
  geom_vline(xintercept = 80, linetype = "dashed", color = "red") +
  labs(title = "LGA-Level Immunisation Coverage by State",
       x = "Mean Coverage Rate (%)",
       y = "LGA") +
  scale_fill_manual(values = c("Kano" = "grey60",
                               "Lagos" = "#1A4F72",
                               "Anambra" = "#4A90C4")) +
  theme_minimal() +
  facet_wrap(~state, scales = "free_y")

lga_coverage_plot

ggsave("plots/lga_coverage_plot.png",
       plot = lga_coverage_plot,
       width = 14,
       height = 6,
       dpi = 300)

# Surulere (87.1%), Lagos Island (85.1%), and Mushin (80.2%) are the only
# LGAs across all three states to meet or exceed the 80% herd immunity
# threshold. Their performance props up Lagos' state average, masking
# considerable underperformance in other Lagos LGAs including Badagry (60.0%),
# Alimosho (60.3%), and Kosofe (60.8%), all of which fall below 70%.

# Notably, Ikeja — the Lagos State capital — does not meet the 80% target
# at 72.0%, despite its concentration of health infrastructure. This may
# reflect the challenge of achieving high coverage proportions in densely
# populated administrative centres with large numbers of eligible children.

# Kano presents the most concerning picture at the LGA level — the majority
# of LGAs report coverage below 50%, with Nassarawa (33.1%), Ungogo (34.5%),
# and Kumbuntsau (34.6%) representing critical underperformance. At this scale,
# these figures translate to thousands of unvaccinated children and significant
# zero-dose risk concentrated in rural Kano LGAs.

# Anambra performs consistently across its LGAs — all ten report coverage above
# 50%, with Awka South leading at 69.5%. However, no Anambra LGA meets the
# 80% threshold, suggesting a state-wide systemic gap rather than localised
# underperformance. Targeted demand-generation interventions applied uniformly
# across Anambra LGAs may yield greater gains than selective outreach.

