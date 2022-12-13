#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 27 18:20:47 2021

@author: xiaojingni

"""
import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt



os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')

MSP_all = pd.read_csv('zillow_MSP_All_df.csv').iloc[:, 1:]
MSP_all.info()
MSP_all.head()



## sort MSP_all by average
top_10 = MSP_all.sort_values('average', ascending=False)[:10]
top_10

## Visualization of region comparison
## create a numeric  data frame

MSP_num = top_10.drop(['RegionID', 'StateName'], axis=1)
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
plt.legend(title='Metropolitan area',prop={"size":8},ncol=1)

plt.title("Median Sale Prices of All Home Type")
plt.show()