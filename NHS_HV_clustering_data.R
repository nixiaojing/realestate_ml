########################################
### This session describe how to generate a NHS and HV combined dataset for 
### later clustering based on region 
### (SO for South, MW for Midwest, NE for Northeast, and WE for West).
########################################

####################################################################
## Create a combined dataset for clustering using NHS and HV data ##
####################################################################

setwd("~/Desktop/GU/ANLY501/portfolio/data/")
library(tidyr)
library(ggplot2)
library(dplyr)
##############
## NHS data 
##############

## Read data

NHS_df <- read.csv(file = 'NHS_2014_2021_df.csv')
summary(NHS_df)
str(NHS_df)
head(NHS_df)

### extract regional data (geo_level_code exclude "US")
NHS_df <- NHS_df[NHS_df$geo_level_code!="US",]
# drop empty levels
NHS_df <- data.frame(cell_value = NHS_df$cell_value, lapply(NHS_df[,-1], droplevels))

summary(NHS_df)
str(NHS_df)

### Calculate quarter data

NHS_Q_df <- aggregate(NHS_df$cell_value,list(NHS_df$Quarter, 
                                             NHS_df$category_code,
                                             NHS_df$geo_level_code),
                      mean)
summary(NHS_Q_df)
str(NHS_Q_df)
head(NHS_Q_df)

## change column name
colnames(NHS_Q_df) <- c("time", "data_type_code", "geo_level_code", "cell_value")
head(NHS_Q_df)


### save csv
write.csv(NHS_Q_df,"NHS_Q_df.csv", row.names = FALSE)


## reshape the df, seperate "data_type_code"

NHS_Q_df_rs <- NHS_Q_df %>% spread(data_type_code, cell_value)

str(NHS_Q_df_rs)
head(NHS_Q_df_rs)

######################
## HV estimate data 
######################

## Read data
HV_df_estimate <- read.csv(file = 'HV_2014_2021_df_estimate.csv')
summary(HV_df_estimate)
str(HV_df_estimate)
head(HV_df_estimate)

### extract regional data (geo_level_code exclude "US")
HV_df_estimate <- HV_df_estimate[HV_df_estimate$geo_level_code!="US",]
# drop empty levels
HV_df_estimate <- data.frame(cell_value = HV_df_estimate$cell_value, lapply(HV_df_estimate[,-1], droplevels))

str(HV_df_estimate)
head(HV_df_estimate)

### Keep varibles of OFFMAR, RNTOCC, OWNOCC, and OCC
## Vacant Housing Units Held Off the Market, Renter Occupied Housing Units,
## Owner Occupied Housing Units, Occupied Housing Units

HV_df_estimate <- HV_df_estimate[HV_df_estimate$data_type_code %in% c("OFFMAR",
                                                                      "RNTOCC",
                                                                      "OWNOCC",
                                                                      "OCC"),]
head(HV_df_estimate)


## reshape the df, seperate "data_type_code"

HV_df_estimate <- HV_df_estimate %>% spread(data_type_code, cell_value)

str(HV_df_estimate)
head(HV_df_estimate)

##################
## HV rate data 
##################

## Read data
HV_df_rate <- read.csv(file = 'HV_2014_2021_df_rate.csv')
summary(HV_df_rate)
str(HV_df_rate)
head(HV_df_rate)

### extract regional data (geo_level_code exclude "US")
HV_df_rate <- HV_df_rate[HV_df_rate$geo_level_code!="US",]
# drop empty levels
HV_df_rate <- data.frame(cell_value = HV_df_rate$cell_value, lapply(HV_df_rate[,-1], droplevels))

summary(HV_df_rate)
str(HV_df_rate)
head(HV_df_rate)

### Keep varible of HOR : Homeownership Rate 

HV_df_rate <- HV_df_rate[HV_df_rate$data_type_code == "HOR",]
## delete data_type_code and rename cell_value
HV_df_rate <- HV_df_rate[,-3]
colnames(HV_df_rate)[1] <- "HOR"


head(HV_df_rate)
str(HV_df_rate)

## save csv
write.csv(HV_df_rate,"HV_df_HOR.csv", row.names = FALSE)


########################
### Create a merged data by time and add lebel as "geo_level_code"
########################

cluster_df <- inner_join(NHS_Q_df_rs, HV_df_estimate, 
                        by = c("time","geo_level_code")) %>%
  inner_join(., HV_df_rate, by=c("time","geo_level_code")) 

head(cluster_df)
str(cluster_df)

## seperate 2014 and 2015 to 2021 data
cluster_df_2014 <- cluster_df[lapply(cluster_df$time,
                                     substr, start = 1,stop =4)=="2014",]
cluster_df_2014

cluster_df <- cluster_df[lapply(cluster_df$time,
                                substr, start = 1,stop =4)!="2014",]
head(cluster_df)

########
## Delete time column
########
## 2015 to 2021 data
cluster_df <- cluster_df[,-1]
colnames(cluster_df)[1] <- "label"

head(cluster_df)
str(cluster_df)

### save as csv

write.csv(cluster_df,"NHS_HV_cluster_df.csv", row.names = FALSE)


## 2014 data
cluster_df_2014 <- cluster_df_2014[,-1]
colnames(cluster_df_2014)[1] <- "label"

head(cluster_df_2014)
str(cluster_df_2014)

####
## For clustering prediction, using data from 2014
####

(pred <- cluster_df_2014[1:3,])

### save as csv

write.csv(pred,"pred_clust.csv", row.names = FALSE)




