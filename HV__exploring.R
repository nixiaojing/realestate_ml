####
# This file used a results from HV_cleaning_exploring.R 
# and NHS_HV_clustering_data.R to conduct figures

setwd("~/Desktop/GU/ANLY501/portfolio/data")

df_all <- read.csv(file = 'HV_estimate_regional.csv')

str(df_all)
## boxplot
df_all %>%
  filter(geo_level_code != 'US') %>%
  ggplot(aes(y = cell_value,
             x = geo_level_code,
             fill = geo_level_code)) +
  geom_boxplot() + 
  #scale_y_continuous(trans='log10') + 
  scale_x_discrete(limits = c("MW", "NE", "SO", "WE")) + 
  facet_wrap(~data_type_code, scale = 'free')



HV_df_rate <- read.csv(file = 'HV_df_HOR.csv')

str(HV_df_rate)
## boxplot
HV_df_rate %>% ggplot(aes(y = HOR,                         
                            x = geo_level_code,                         
                            fill = geo_level_code)) +
  geom_boxplot() +
  scale_x_discrete(limits = c("MW", "NE", "SO", "WE"))