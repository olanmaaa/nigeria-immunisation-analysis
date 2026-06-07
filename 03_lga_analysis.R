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

# Surulere (87.1%) and Lagos Island (85.1%) are the highest performing LGAs
# overall, both situated in densely urbanised Lagos. However, Lagos shows
# considerable intra-state variation — several LGAs fall well below the
# state average of 70.8%, including Badagry (60.0%), Kosofe (60.8%), and
# Alimosho (60.3%), indicating that the state average masks significant
# localised underperformance.

# Notably, Ikeja — Lagos State capital — ranks only 5th within the state
# at 72.0%. This may reflect the paradox of high population density in
# administrative centres, where large numbers of eligible children make
# achieving high coverage proportions more challenging despite strong
# health infrastructure.

# Two Kano LGAs — Fagge (67.1%) and Dala (63.8%) — appear in the top 10
# overall, both urban LGAs within Kano city. This reinforces the urban-rural
# finding from 02_coverage_analysis.R — even within a consistently
# low-performing state, urban LGAs can perform comparably to mid-tier
# Anambra LGAs, underscoring that geography and urbanicity are stronger
# predictors of coverage than state-level factors alone.

# The five lowest performing LGAs are all in Kano — Nassarawa (33.1%),
# Ungogo (34.5%), Kumbuntsau (34.6%), Garo (41.7%), and Wudil (43.3%) —
# all rural, representing critical zero-dose risk areas warranting
# urgent targeted outreach.


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