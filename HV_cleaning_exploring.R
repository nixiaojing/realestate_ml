### NHS_1990_2021 data cleaning and exploring

library(ggplot2)
library(jsonlite)
library(rlist)
library(dplyr)
library(stringr)
setwd("~/Desktop/GU/ANLY501/portfolio/data")

#############################
## Read JSON to data frame 

### New Homes Sales, national
HV_1990_2021.json<-fromJSON(txt = "HV_1990_2021.json")
## Convert as data frame 
HV_1990_2021.df <- as.data.frame(HV_1990_2021.json)
## set the first row as column names, and no row names
names(HV_1990_2021.df) <- as.matrix(HV_1990_2021.df[1, ])
HV_1990_2021.df <- HV_1990_2021.df[-1, ]
rownames(HV_1990_2021.df) <- NULL
head(HV_1990_2021.df)
str(HV_1990_2021.df)
##

###################
## Data Cleaning ##
###################

###################################
## drop empty levels: due to read in format, the column name was read as a level
## of the factor. After change the first row to column name, empty level of the 
## column name should be removed. 
levels(HV_1990_2021.df$error_data)
HV_1990_2021.df <- data.frame(lapply(HV_1990_2021.df, droplevels))
str(HV_1990_2021.df)
#############################################
## Check if there is any NA/missing values 

(sum(is.na(HV_1990_2021.df))) ## no missing values in this dataset

#########################################
## Convert each column to correct type 

str(HV_1990_2021.df)

## cell_value: based different data_type_code, the units of the value are different
## They all numbers, units include: K dollar, dollar, month and percentage. 
## thus, convert cell_value to numeric, all other variables should be factors.
HV_1990_2021.df$cell_value <- 
  as.numeric(levels(HV_1990_2021.df$cell_value))[HV_1990_2021.df$cell_value]
str(HV_1990_2021.df)

### some NA introduced. there are some non-numeric values, remove those values

HV_1990_2021.df <- HV_1990_2021.df[-which(is.na(HV_1990_2021.df$cell_value)),]
str(HV_1990_2021.df)

## remove time_slot_id as it is same as time column
HV_1990_2021.df <- HV_1990_2021.df[,-2]
head(HV_1990_2021.df)

############################
## delete error_data column and seasonally_adj column
HV_1990_2021.df <- HV_1990_2021.df[,-2]
HV_1990_2021.df <- HV_1990_2021.df[,-4]
head(HV_1990_2021.df)
str(HV_1990_2021.df)

################
## keep data from 2019 to 2021
HV_2019_2021.df <- HV_1990_2021.df[which(as.numeric(str_sub(HV_1990_2021.df$time,1,4))>2018),]
str(HV_2019_2021.df)

#########################
## Devide the dataset into two based on cell_value type : rate or estimate

HV_2019_2021.df.estimate <- HV_2019_2021.df[HV_2019_2021.df$category_code == "ESTIMATE",]
HV_2019_2021.df.rate <- HV_2019_2021.df[HV_2019_2021.df$category_code == "RATE",]
head(HV_2019_2021.df.estimate)
head(HV_2019_2021.df.rate)
str(HV_2019_2021.df.estimate)
str(HV_2019_2021.df.rate)

## delete category_code column
HV_2019_2021.df.estimate <- HV_2019_2021.df.estimate[,-2]
HV_2019_2021.df.rate <- HV_2019_2021.df.rate[,-2]
str(HV_2019_2021.df.estimate)
str(HV_2019_2021.df.rate)
head(HV_2019_2021.df.estimate)
head(HV_2019_2021.df.rate)

########################
## Check if rates fall in the range 0-100
(sum(HV_2019_2021.df.rate$cell_value<0 | HV_2019_2021.df.rate$cell_value>100))



########################################
## Check if regional values sum up as US values (bear with a little differences)
## only in HV_1990_2021.df.estimate

## first, remove empty level 
HV_2019_2021.df.rate <- data.frame(cell_value = HV_2019_2021.df.rate[,1],
                                   lapply(HV_2019_2021.df.rate[,-1], 
                                          droplevels))
HV_2019_2021.df.estimate <- data.frame(cell_value = HV_2019_2021.df.estimate[,1],
                                       lapply(HV_2019_2021.df.estimate[,-1], 
                                              droplevels))
str(HV_2019_2021.df.estimate)
str(HV_2019_2021.df.rate)


(type <- levels(HV_2019_2021.df.estimate$data_type_code))

df_all <- HV_2019_2021.df.estimate%>%
  filter(data_type_code %in% type)

df_region <- df_all %>%
  filter(geo_level_code != 'US') %>%
  group_by(data_type_code,time) %>%
  summarise(sum_cell_value = sum(cell_value))

df_total <- df_all %>%
  filter(geo_level_code == 'US') %>%
  full_join(df_region, by = c("data_type_code","time")) %>%
  select(sum_cell_value, everything())
###
# check na in df_total
(sum(is.na(df_total)))

## check if there is any differences of calculate sum and given sum (labeled as 
## "US" exceed 10% difference)

df_total<- df_total %>%
  mutate(large10pct = ((abs(sum_cell_value-cell_value)/cell_value)>0.1))
sum(df_total$large10pct)

#########
# Visual check potential outliers, scatter plot

## scatter plot
df_total %>%
  ggplot(aes(x = time,
             y = cell_value,
             group = data_type_code,
             color = data_type_code)) +
  geom_line() + 
  geom_point()

##########
## save as csv
##########
write.csv(HV_2019_2021.df.rate,"HV_2019_2021_df_rate.csv", row.names = FALSE)
write.csv(HV_2019_2021.df.estimate,"HV_2019_2021_df_estimate.csv", row.names = FALSE)
write.csv(df_all,"HV_estimate_regional.csv", row.names = FALSE)
write.csv(df_all,"HV_rate_regional.csv", row.names = FALSE)




###########################################3
## repeat above to get 2014 - 2021 data


library(ggplot2)
library(jsonlite)
library(rlist)
library(dplyr)
library(stringr)
setwd("~/Desktop/GU/ANLY501/portfolio/data")

#############################
## Read JSON to data frame 

### New Homes Sales, national
HV_1990_2021.json<-fromJSON(txt = "HV_1990_2021.json")
## Convert as data frame 
HV_1990_2021.df <- as.data.frame(HV_1990_2021.json)
## set the first row as column names, and no row names
names(HV_1990_2021.df) <- as.matrix(HV_1990_2021.df[1, ])
HV_1990_2021.df <- HV_1990_2021.df[-1, ]
rownames(HV_1990_2021.df) <- NULL
head(HV_1990_2021.df)
str(HV_1990_2021.df)
##

###################
## Data Cleaning ##
###################

###################################
## drop empty levels: due to read in format, the column name was read as a level
## of the factor. After change the first row to column name, empty level of the 
## column name should be removed. 
levels(HV_1990_2021.df$error_data)
HV_1990_2021.df <- data.frame(lapply(HV_1990_2021.df, droplevels))
str(HV_1990_2021.df)
#############################################
## Check if there is any NA/missing values 

(sum(is.na(HV_1990_2021.df))) ## no missing values in this dataset

#########################################
## Convert each column to correct type 

str(HV_1990_2021.df)

## cell_value: based different data_type_code, the units of the value are different
## They all numbers, units include: K dollar, dollar, month and percentage. 
## thus, convert cell_value to numeric, all other variables should be factors.
HV_1990_2021.df$cell_value <- 
  as.numeric(levels(HV_1990_2021.df$cell_value))[HV_1990_2021.df$cell_value]
str(HV_1990_2021.df)

### some NA introduced. there are some non-numeric values, remove those values

HV_1990_2021.df <- HV_1990_2021.df[-which(is.na(HV_1990_2021.df$cell_value)),]
str(HV_1990_2021.df)

## remove time_slot_id as it is same as time column
HV_1990_2021.df <- HV_1990_2021.df[,-2]
head(HV_1990_2021.df)

############################
## delete error_data column and seasonally_adj column
HV_1990_2021.df <- HV_1990_2021.df[,-2]
HV_1990_2021.df <- HV_1990_2021.df[,-4]
head(HV_1990_2021.df)
str(HV_1990_2021.df)

################
## keep data from 2014 to 2021
HV_2014_2021.df <- HV_1990_2021.df[which(as.numeric(str_sub(HV_1990_2021.df$time,1,4))>2013),]
str(HV_2014_2021.df)

#########################
## Devide the dataset into two based on cell_value type : rate or estimate

HV_2014_2021.df.estimate <- HV_2014_2021.df[HV_2014_2021.df$category_code == "ESTIMATE",]
HV_2014_2021.df.rate <- HV_2014_2021.df[HV_2014_2021.df$category_code == "RATE",]
head(HV_2014_2021.df.estimate)
head(HV_2014_2021.df.rate)
str(HV_2014_2021.df.estimate)
str(HV_2014_2021.df.rate)

## delete category_code column
HV_2014_2021.df.estimate <- HV_2014_2021.df.estimate[,-2]
HV_2014_2021.df.rate <- HV_2014_2021.df.rate[,-2]
str(HV_2014_2021.df.estimate)
str(HV_2014_2021.df.rate)
head(HV_2014_2021.df.estimate)
head(HV_2014_2021.df.rate)

########################
## Check if rates fall in the range 0-100
(sum(HV_2014_2021.df.rate$cell_value<0 | HV_2014_2021.df.rate$cell_value>100))



########################################
## Check if regional values sum up as US values (bear with a little differences)
## only in HV_1990_2021.df.estimate

## first, remove empty level 
HV_2014_2021.df.rate <- data.frame(cell_value = HV_2014_2021.df.rate[,1],
                                   lapply(HV_2014_2021.df.rate[,-1], 
                                          droplevels))
HV_2014_2021.df.estimate <- data.frame(cell_value = HV_2014_2021.df.estimate[,1],
                                       lapply(HV_2014_2021.df.estimate[,-1], 
                                              droplevels))
str(HV_2014_2021.df.estimate)
str(HV_2014_2021.df.rate)


(type <- levels(HV_2014_2021.df.estimate$data_type_code))

df_all <- HV_2014_2021.df.estimate%>%
  filter(data_type_code %in% type)

df_region <- df_all %>%
  filter(geo_level_code != 'US') %>%
  group_by(data_type_code,time) %>%
  summarise(sum_cell_value = sum(cell_value))

df_total <- df_all %>%
  filter(geo_level_code == 'US') %>%
  full_join(df_region, by = c("data_type_code","time")) %>%
  select(sum_cell_value, everything())
###
# check na in df_total
(sum(is.na(df_total)))

## check if there is any differences of calculate sum and given sum (labeled as 
## "US" exceed 10% difference)

df_total<- df_total %>%
  mutate(large10pct = ((abs(sum_cell_value-cell_value)/cell_value)>0.1))
sum(df_total$large10pct)

#########
# Visual check potential outliers, scatter plot

## scatter plot
df_total %>%
  ggplot(aes(x = time,
             y = cell_value,
             group = data_type_code,
             color = data_type_code)) +
  geom_line() + 
  geom_point()

##########
## save as csv
##########
write.csv(HV_2014_2021.df.rate,"HV_2014_2021_df_rate.csv", row.names = FALSE)
write.csv(HV_2014_2021.df.estimate,"HV_2014_2021_df_estimate.csv", row.names = FALSE)
write.csv(df_all,"HV_estimate_regional.csv", row.names = FALSE)











