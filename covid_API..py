#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 17:20:48 2021

@author: xiaojingni
"""
################################################################
## For key safety, personal API key is not shown in this code ##
################################################################

## CovidActNow API
## https://apidocs.covidactnow.org/
## required apiKey, register at https://apidocs.covidactnow.org/
## documentation: https://apidocs.covidactnow.org/api/#tag/CBSA-Data/paths/~1cbsa~1%7Bcbsa_code%7D.json?apiKey=%7BapiKey%7D/get

import requests
import csv


###### Endpoint csv file all counties summary
BaseURL_csv = "https://api.covidactnow.org/v2/counties.csv"



URLPost = {'apiKey': {APIKEY}}

###### requests.get() will get the format of the URL from endpoint (BaseURL) and build the query url for you
## json file  of all counties data in New York state
url_state = ('https://api.covidactnow.org/v2/county/'
       'NY'
       '.timeseries.json?'
       'apiKey={APIKEY}')
response1=requests.get(url_state)
## json file of New York State
## csv
response2=requests.get(BaseURL_csv, URLPost)

## save json
county_time_series_NY = response1.content
with open('county_time_series_NY.json', 'wb') as f:
    f.write(county_time_series_NY)
    
## save csv
with open('covid_county_summary.csv', 'w') as f:
    writer = csv.writer(f)
    for line in response2.iter_lines():
        writer.writerow(line.decode('utf-8').split(','))
