#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 27 12:25:31 2021

@author: xiaojingni
"""
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

pd.set_option('display.max_columns', 10)


os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')

MSP_all = pd.read_csv('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/Metro_median_sale_price_uc_sfrcondo_month.csv')
MSP_all.info()
MSP_all.head()

#### check for NA values
is_NaN = MSP_all.isnull()
## get rows with nan
row_has_NaN = is_NaN.any(axis=1)
rows_with_NaN = MSP_all[row_has_NaN]
rows_with_NaN.head()


### number of nan each row has
nan_num = is_NaN.sum(axis=1)
nan_num = nan_num[nan_num!=0]
nan_num

## get columns with nan
column_with_NaN = MSP_all.columns[MSP_all.isna().any()].tolist()
column_with_NaN[0:5]



### fill out the head
## due to both row 0 and colum statename has nan, we can fill out this missing value
## using "US"
MSP_all.StateName[0] = 'US'
MSP_all.head()
MSP_all.info()

#########
# before filling out other nan values, trim the dataset. Only data after 2019 
# are kept
a = MSP_all.columns[5:]
b = [x[0:4] for x in a]
c = [int(x) for x in b]
c[0:0]=[2019,2019,2019,2019,2019]
c
MSP_all = MSP_all.loc[:,[x>=2019 for x in c]]
MSP_all.info()
MSP_all.head()

## check nan again for numeric columns
#### check for NA values
is_NaN = MSP_all.isnull()
not any(is_NaN)

## no nan anymore


#######
## delete columns will not be used, SizeRank and RegionType
MSP_all = MSP_all.drop(['SizeRank', 'RegionType'], axis=1)
MSP_all.info()
MSP_all.head()

## add average column
MSP_all['average'] = MSP_all.mean(numeric_only=True, axis=1)
MSP_all.info()
MSP_all.head()


###
# check if there is any outliers, line plots


## Visualization of region comparison
## create a numeric  data frame

MSP_num = MSP_all.drop(['RegionID', 'StateName'], axis=1)
## remove "average" column
MSP_num = MSP_num.iloc[: , :-1]
MSP_num.info()

## change data formate to melt version
MSP_num = MSP_num.melt(id_vars=["RegionName"], 
                       var_name="Month", 
                       value_name="Value")


# multiple line plot
fig, ax = plt.subplots()

for key, grp in MSP_num.groupby(["RegionName"]):
    ax = grp.plot(ax=ax, kind='line', x='Month', y='Value', label=key)
    
plt.xlabel("Month")
plt.ylabel("Median Sale Prices, dollar")
plt.legend(title='Metropolitan area',prop={"size":5},loc='upper center', 
           bbox_to_anchor=(0.95, 1.15), ncol=2)

plt.title("Median Sale Prices of All Home Type")
plt.show()

MSP_all.to_csv (r'zillow_MSP_All_df.csv', index = True, header=True)



    



