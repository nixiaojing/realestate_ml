#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 17:20:48 2021

@author: xiaojingni
"""
################################################################
## For key safety, personal API key is not shown in this code ##
################################################################

## News API
## https://newsapi.org/
## documentation: https://newsapi.org/docs/endpoints/everything
'''
import os
'''

import requests
import csv
import pandas as pd

'''
os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')
'''

###### Endpoint 
BaseURL = "https://newsapi.org/v2/everything"
### read in my api key
key = pd.read_csv('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/news_api_key.txt')

## Keywords or phrases to search for in the article title and body
q = '"home buying" OR "buying a home" OR "housing market"'
q1 = "mortgage rate"
q3 = "real estate market"

t_from = "2021-08-25"
t_to = "2021-09-25"

URLPost = {'apiKey': {key.API_key[0]},
                    'q': q3, 
                    'from':t_from,
                    'to':t_to,
                    'language':'en',
                    'sortBy':'popularity',
                    }
                    
response=requests.get(BaseURL, URLPost)
jsontxt = response.json()


## save json homebuying
homebuying = response.content
with open('homebuying.json', 'wb') as f:
    f.write(homebuying)

## save other keyword :q= q1 = mortgage rate
mortgage = response.content
with open('mortgage.json', 'wb') as f:
    f.write(mortgage)
    

