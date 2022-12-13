####
# This file used a results from NHS_cleaning_exploring.R
# and NHS_HV_clustering_data.R to conduct figures

setwd("~/Desktop/GU/ANLY501/portfolio/data")

NHS_Q_df <- read.csv(file = 'NHS_Q_df.csv')

## plot groups

NHS_Q_df %>% ggplot(aes(y = cell_value,
                        x = geo_level_code,
                        fill = geo_level_code)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("MW", "NE", "SO", "WE"))+ 
  facet_wrap(~data_type_code, scale = 'free')