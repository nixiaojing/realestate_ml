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
NHS_1990_2021.json<-fromJSON(txt = "NHS_1990_2021.json")
## Convert as data frame 
NHS_1990_2021.df <- as.data.frame(NHS_1990_2021.json)
## set the first row as column names, and no row names
names(NHS_1990_2021.df) <- as.matrix(NHS_1990_2021.df[1, ])
NHS_1990_2021.df <- NHS_1990_2021.df[-1, ]
rownames(NHS_1990_2021.df) <- NULL
head(NHS_1990_2021.df)
str(NHS_1990_2021.df)
##

###################
## Data Cleaning ##
###################

###################################
## drop empty levels: due to read in format, the column name was read as a level
## of the factor. After change the first row to column name, empty level of the 
## column name should be removed. 
levels(NHS_1990_2021.df$error_data)
NHS_1990_2021.df <- data.frame(lapply(NHS_1990_2021.df, droplevels))
str(NHS_1990_2021.df)

#############################################
## Check if there is any NA/missing values 

(sum(is.na(NHS_1990_2021.df))) ## no missing values in this dataset

#########################################
## Convert each column to correct type 

str(NHS_1990_2021.df)


## cell_value: based different data_type_code, the units of the value are different
## They all numbers, units include: K dollar, dollar, month and percentage. 
## thus, convert cell_value to numeric, all other variables should be factors.
NHS_1990_2021.df$cell_value <- 
  as.numeric(levels(NHS_1990_2021.df$cell_value))[NHS_1990_2021.df$cell_value]
str(NHS_1990_2021.df)

## remove time_slot_id as it is same as time column
NHS_1990_2021.df <- NHS_1990_2021.df[,-2]
head(NHS_1990_2021.df)

############################
## delete error_data column and seasonally_adj column
NHS_1990_2021.df <- NHS_1990_2021.df[,-2]
NHS_1990_2021.df <- NHS_1990_2021.df[,-4]
head(NHS_1990_2021.df)
str(NHS_1990_2021.df)

################
## keep data from 2019 to 2021
NHS_2019_2021.df <- NHS_1990_2021.df[which(as.numeric(str_sub(NHS_1990_2021.df$time,1,4))>2018),]
str(NHS_2019_2021.df)

##################
## delete records with data_type_code start with E- as they indicate error type
NHS_2019_2021.df <- NHS_2019_2021.df[-which(str_sub(NHS_2019_2021.df$data_type_code,1,1)=='E'),]
str(NHS_2019_2021.df)

## add a column "quarter" based on time. Meanwhile, I will keep the time column
## since there may be some monthly analysis
NHS_2019_2021.df <- NHS_2019_2021.df %>% mutate(Quarter = ifelse(str_sub(time,-2,-1) ==  '01' | str_sub(time,-2,-1) ==  '02' | str_sub(time,-2,-1) ==  '03', 
                                             paste0(str_sub(time,1,5),'Q1'), 
                                             ifelse(str_sub(time,-2,-1) ==  '04' | str_sub(time,-2,-1) ==  '05' | str_sub(time,-2,-1) ==  '06',
                                                    paste0(str_sub(time,1,5),'Q2'),
                                                    ifelse(str_sub(time,-2,-1) ==  '07' | str_sub(time,-2,-1) ==  '08' | str_sub(time,-2,-1) ==  '09',
                                                           paste0(str_sub(time,1,5),'Q3'),
                                                           ifelse(str_sub(time,-2,-1) ==  '10' | str_sub(time,-2,-1) ==  '11' | str_sub(time,-2,-1) ==  '12',
                                                                  paste0(str_sub(time,1,5),'Q4'),0)))))

head(NHS_2019_2021.df)
str(NHS_2019_2021.df)

######
## Change Quarter data type
NHS_2019_2021.df$Quarter <- as.factor(NHS_2019_2021.df$Quarter)
str(NHS_2019_2021.df)

##########
## drop levels
NHS_2019_2021.df <- data.frame(cell_value = NHS_2019_2021.df$cell_value, lapply(NHS_2019_2021.df[,-1], droplevels))
str(NHS_2019_2021.df)

########################################
## Check if regional values sum up as US values (bear with a little differences)
## Only for "TOTAL" data type (All Houses) 

df_all <- NHS_2019_2021.df%>%
  filter(data_type_code == 'TOTAL')

df_region <- df_all %>%
  filter(geo_level_code != 'US') %>%
  group_by(category_code, time) %>%
  summarise(sum_cell_value = sum(cell_value))

df_total <- df_all %>%
  filter(geo_level_code == 'US') %>%
  full_join(df_region, by = c("category_code", "time")) %>%
  select(sum_cell_value, everything())

###
# check na in df_total
(sum(is.na(df_total)))

## check if there is any differences of calculate sum and given sum (labeled as 
## "US" exceed 10% difference)

df_total<- df_total %>%
  mutate(large10pct = ((abs(sum_cell_value-cell_value)/cell_value)>0.1))
sum(df_total$large10pct)




##########
## save as csv
##########
write.csv(NHS_2019_2021.df,"NHS_2019_2021_df.csv", row.names = FALSE)


###########################################3
## repeat above to get 2014 - 2021 data


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
NHS_1990_2021.json<-fromJSON(txt = "NHS_1990_2021.json")
## Convert as data frame 
NHS_1990_2021.df <- as.data.frame(NHS_1990_2021.json)
## set the first row as column names, and no row names
names(NHS_1990_2021.df) <- as.matrix(NHS_1990_2021.df[1, ])
NHS_1990_2021.df <- NHS_1990_2021.df[-1, ]
rownames(NHS_1990_2021.df) <- NULL
head(NHS_1990_2021.df)
str(NHS_1990_2021.df)
##

###################
## Data Cleaning ##
###################

###################################
## drop empty levels: due to read in format, the column name was read as a level
## of the factor. After change the first row to column name, empty level of the 
## column name should be removed. 
levels(NHS_1990_2021.df$error_data)
NHS_1990_2021.df <- data.frame(lapply(NHS_1990_2021.df, droplevels))
str(NHS_1990_2021.df)

#############################################
## Check if there is any NA/missing values 

(sum(is.na(NHS_1990_2021.df))) ## no missing values in this dataset

#########################################
## Convert each column to correct type 

str(NHS_1990_2021.df)


## cell_value: based different data_type_code, the units of the value are different
## They all numbers, units include: K dollar, dollar, month and percentage. 
## thus, convert cell_value to numeric, all other variables should be factors.
NHS_1990_2021.df$cell_value <- 
  as.numeric(levels(NHS_1990_2021.df$cell_value))[NHS_1990_2021.df$cell_value]
str(NHS_1990_2021.df)

## remove time_slot_id as it is same as time column
NHS_1990_2021.df <- NHS_1990_2021.df[,-2]
head(NHS_1990_2021.df)

############################
## delete error_data column and seasonally_adj column
NHS_1990_2021.df <- NHS_1990_2021.df[,-2]
NHS_1990_2021.df <- NHS_1990_2021.df[,-4]
head(NHS_1990_2021.df)
str(NHS_1990_2021.df)

################
## keep data from 2014 to 2021
NHS_2014_2021.df <- NHS_1990_2021.df[which(as.numeric(str_sub(NHS_1990_2021.df$time,1,4))>2013),]
str(NHS_2014_2021.df)

##################
## delete records with data_type_code start with E- as they indicate error type
NHS_2014_2021.df <- NHS_2014_2021.df[-which(str_sub(NHS_2014_2021.df$data_type_code,1,1)=='E'),]
str(NHS_2014_2021.df)

## add a column "quarter" based on time. Meanwhile, I will keep the time column
## since there may be some monthly analysis
NHS_2014_2021.df <- NHS_2014_2021.df %>% mutate(Quarter = ifelse(str_sub(time,-2,-1) ==  '01' | str_sub(time,-2,-1) ==  '02' | str_sub(time,-2,-1) ==  '03', 
                                                                 paste0(str_sub(time,1,5),'Q1'), 
                                                                 ifelse(str_sub(time,-2,-1) ==  '04' | str_sub(time,-2,-1) ==  '05' | str_sub(time,-2,-1) ==  '06',
                                                                        paste0(str_sub(time,1,5),'Q2'),
                                                                        ifelse(str_sub(time,-2,-1) ==  '07' | str_sub(time,-2,-1) ==  '08' | str_sub(time,-2,-1) ==  '09',
                                                                               paste0(str_sub(time,1,5),'Q3'),
                                                                               ifelse(str_sub(time,-2,-1) ==  '10' | str_sub(time,-2,-1) ==  '11' | str_sub(time,-2,-1) ==  '12',
                                                                                      paste0(str_sub(time,1,5),'Q4'),0)))))

head(NHS_2014_2021.df)
str(NHS_2014_2021.df)

######
## Change Quarter data type
NHS_2014_2021.df$Quarter <- as.factor(NHS_2014_2021.df$Quarter)
str(NHS_2014_2021.df)

##########
## drop levels
NHS_2014_2021.df <- data.frame(cell_value = NHS_2014_2021.df$cell_value, lapply(NHS_2014_2021.df[,-1], droplevels))
str(NHS_2014_2021.df)

########################################
## Check if regional values sum up as US values (bear with a little differences)
## Only for "TOTAL" data type (All Houses) 

df_all <- NHS_2014_2021.df%>%
  filter(data_type_code == 'TOTAL')

df_region <- df_all %>%
  filter(geo_level_code != 'US') %>%
  group_by(category_code, time) %>%
  summarise(sum_cell_value = sum(cell_value))

df_total <- df_all %>%
  filter(geo_level_code == 'US') %>%
  full_join(df_region, by = c("category_code", "time")) %>%
  select(sum_cell_value, everything())

###
# check na in df_total
(sum(is.na(df_total)))

## check if there is any differences of calculate sum and given sum (labeled as 
## "US" exceed 10% difference)

df_total<- df_total %>%
  mutate(large10pct = ((abs(sum_cell_value-cell_value)/cell_value)>0.1))
sum(df_total$large10pct)




##########
## save as csv
##########
write.csv(NHS_2014_2021.df,"NHS_2014_2021_df.csv", row.names = FALSE)























