## This code is used to clean and process the datasets for NB and SVM
## Record data contains average of 2018-2020 ZORI, average of 2018-2020 Median 
## Sales price, average of 2018-2020 Median List price, average of 2018-2020 
## Inventory, and politics(categorical variable for NB), label as the U.S.Region


### ZORI data
###################################################
## Read data and Calculate average for ZORI data ##
###################################################
library(dplyr)
library(substr)

## read 
rent <- read.csv("Metro_ZORI_AllHomesPlusMultifamily_Smoothed.csv")
str(rent)

# remove NA
rent_NA <- na.omit(rent)
# add state name
rent_NA$StateName <- substr(rent_NA$RegionName,
                            (nchar(rent_NA$RegionName)+1)-2,
                            nchar(rent_NA$RegionName))
# delete the record of U.S. data
rent_NA <- rent_NA[-1,]

# keep only 2018 to 2020 data
rent_value <- rent_NA[,grepl('2018|2019|2020',names(rent_NA))]

# calculate average ZORI for each place
avg_value <- rowMeans(rent_value)

# merge average ZORI with other categorical variables

df_zori <- data.frame(rent_NA$RegionName, rent_NA$StateName,
                           as.matrix(avg_value))
colnames(df_zori) <- c("region","state","ZORI")

# add a USregion column based on state
df_zori<-df_zori %>% mutate(USregion = case_when(
  state %in% c("CO"
               ,"ID"
               ,"MT"
               ,"NV"
               ,"UT"
               ,"WY"
               ,"AK"
               ,"CA"
               ,"HI"
               ,"OR"
               ,"WA") ~ "West",
  state %in% c("CT","ME","MA","NH","NJ","NY","PA","RI","VT","DE","MD") ~ "Northeast",
  state %in% c("AL","AR","FL","GA","KY","LA","MS","NC","SC","TN","VA","WV","DC") ~ "Southeast",
  state %in% c("ND","SD","NE","KS","MO","IA","MN","WI","MI","IL","IN","OH") ~ "Midwest",
  state %in% c("AZ","NM","TX","OK") ~ "Southwest"
))

# based on 2016 political map
# add a politics column based on state
df_zori<-df_zori %>% mutate(politics = ifelse(
  state %in% c("ME", "VT","NY","MA","NJ","MD","DE",
               "VA","HI","DC","IL","MN","CO","NM","WA","OR","NV","CA"), "Blue",
  "Red"))

############################
## median sale price for all home (SFR + condo)
############################
sale_all <- read.csv("Metro_median_sale_price_uc_sfrcondo_month.csv")

# remove NA
sale_all_NA <- na.omit(sale_all)
# delete the record of U.S. data
sale_all_NA <- sale_all_NA[-1,]

# keep only 2018 to 2020 data
sale_all_value <- sale_all_NA[,grepl('2018|2019|2020',names(sale_all_NA))]
# calculate average sales price for each place
avg_value <- rowMeans(sale_all_value)

# merge average sales price with other categorical variables

sale_all_avg <- data.frame(sale_all_NA$RegionName,
                           as.matrix(avg_value))
colnames(sale_all_avg) <- c("region","Sales")

############################
## for-sale inventory for all home (SFR + condo)
############################
invt_all <- read.csv("Metro_invt_fs_uc_sfrcondo_month.csv")
# remove NA
invt_all_NA <- na.omit(invt_all)
# delete the record of U.S. data
invt_all_NA <- invt_all_NA[-1,]

# keep only 2018 to 2020 data
invt_all_value <- invt_all_NA[,grepl('2018|2019|2020',names(invt_all_NA))]
# calculate average inventory for each place
avg_value <- rowMeans(invt_all_value)

# merge annual total inventory with other categorical variables

invt_all_sum <- data.frame(invt_all_NA$RegionName, 
                           as.matrix(avg_value))
colnames(invt_all_sum) <- c("region","Inventory")


############################
## median list price for all home (SFR + condo)
############################
list_all <- read.csv("Metro_mlp_uc_sfrcondo_month.csv")

# remove NA
list_all_NA <- na.omit(list_all)
# delete the record of U.S. data
list_all_NA <- list_all_NA[-1,]

# keep only 2018 to 2020 data
list_all_value <- list_all_NA[,grepl('2018|2019|2020',names(list_all_NA))]
# calculate average list price for each place
avg_value <- rowMeans(list_all_value)

# merge average sales price with other categorical variables

list_all_avg <- data.frame(list_all_NA$RegionName, 
                           as.matrix(avg_value))
colnames(list_all_avg) <- c("region","List")


## combine all together
df_combined <- merge(df_zori,sale_all_avg, by="region", all=FALSE)
df_combined <- merge(df_combined,list_all_avg,by="region", all=FALSE)
df_combined <- merge(df_combined,invt_all_sum,by="region", all=FALSE)

write.csv(df_combined,"zillow_NB_df.csv")
write.csv(df_combined[, -which(names(df_combined) == "politics")],"zillow_SVM_df.csv")
