## this code is used to combine zillow median sale price data for SFR and all 
## homes and zillow for-sale inventory for SFR and all homes

## the combined dataset will be used in decision tree analysis

setwd("~/Desktop/GU/ANLY501/portfolio/data")

########################################################################
## Read data and trim data to 2018 to 2020                            ##
## Calculate average for median sale price and total annual inventory ##
########################################################################

############################
## median sale price for SFR
############################

sale_SFR <- read_csv("Metro_median_sale_price_uc_sfr_month.csv")
str(sale_SFR)

# remove NA
sale_SFR_NA <- na.omit(sale_SFR)

# keep only 2018 to 2020 data
sale_SFR_value <- sale_SFR_NA[,grepl('2018|2019|2020',names(sale_SFR_NA))]

# calculate average sales price for each year
avg_value <- as.data.frame(t(sale_SFR_value)) %>% 
  mutate(year = substr(rownames(.), 1, 4)) %>%
  group_by(year) %>%
  summarize_all(mean)

# merge average sales price with other categorical variables
# add a column named "label" of SFR

sale_SFR_avg <- data.frame(sale_SFR_NA$RegionName, sale_SFR_NA$StateName,
                           t(as.matrix(avg_value[-1])),
                           "label"="SFR","type"="sales")
colnames(sale_SFR_avg) <- c("region","state","2018","2019","2020","label","type")

# add a USregion column based on state
sale_SFR_avg<-sale_SFR_avg %>% mutate(USregion = case_when(
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

############################
## median sale price for all home (SFR + condo)
############################
sale_all <- read_csv("Metro_median_sale_price_uc_sfrcondo_month.csv")

# remove NA
sale_all_NA <- na.omit(sale_all)
# keep only 2018 to 2020 data
sale_all_value <- sale_all_NA[,grepl('2018|2019|2020',names(sale_all_NA))]
# calculate average sales price for each year
avg_value <- as.data.frame(t(sale_all_value)) %>% 
  mutate(year = substr(rownames(.), 1, 4)) %>%
  group_by(year) %>%
  summarize_all(mean)


# merge average sales price with other categorical variables
# add a column named "label" of All

sale_all_avg <- data.frame(sale_all_NA$RegionName, sale_all_NA$StateName,
                           t(as.matrix(avg_value[-1])),
                           "label"="all","type"="sales")
colnames(sale_all_avg) <- c("region","state","2018","2019","2020","label","type")
# add a USregion column based on state
sale_all_avg<-sale_all_avg %>% mutate(USregion = case_when(
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

############################
## for-sale inventory for SFR
############################
invt_SFR <- read_csv("Metro_invt_fs_uc_sfr_month.csv")
# remove NA
invt_SFR_NA <- na.omit(invt_SFR)
# keep only 2018 to 2020 data
invt_SFR_value <- invt_SFR_NA[,grepl('2018|2019|2020',names(invt_SFR_NA))]
# calculate annual total inventory for each year
sum_value <- as.data.frame(t(invt_SFR_value)) %>% 
  mutate(year = substr(rownames(.), 1, 4)) %>%
  group_by(year) %>%
  summarize_all(sum)


# merge annual total inventory with other categorical variables
# add a column named "label" of SFR

invt_SFR_sum <- data.frame(invt_SFR_NA$RegionName, invt_SFR_NA$StateName,
                           t(as.matrix(sum_value[-1])),
                           "label"="SFR","type"="inventory")
colnames(invt_SFR_sum) <- c("region","state","2018","2019","2020","label","type")
# add a USregion column based on state
invt_SFR_sum<-invt_SFR_sum %>% mutate(USregion = case_when(
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

############################
## for-sale inventory for all home (SFR + condo)
############################
invt_all <- read_csv("Metro_invt_fs_uc_sfrcondo_month.csv")
# remove NA
invt_all_NA <- na.omit(invt_all)
# keep only 2018 to 2020 data
invt_all_value <- invt_all_NA[,grepl('2018|2019|2020',names(invt_all_NA))]
# calculate annual total inventory for each year
sum_value <- as.data.frame(t(invt_all_value)) %>% 
  mutate(year = substr(rownames(.), 1, 4)) %>%
  group_by(year) %>%
  summarize_all(sum)


# merge annual total inventory with other categorical variables
# add a column named "label" of SFR

invt_all_sum <- data.frame(invt_all_NA$RegionName, invt_all_NA$StateName,
                           t(as.matrix(sum_value[-1])),
                           "label"="all","type"="inventory")
colnames(invt_all_sum) <- c("region","state","2018","2019","2020","label","type")
# add a USregion column based on state
invt_all_sum<-invt_all_sum %>% mutate(USregion = case_when(
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

## combine all together
combined <- rbind(sale_SFR_avg,sale_all_avg,invt_SFR_sum,invt_all_sum)

write_csv(combined,"zillow_DT_df.csv")
