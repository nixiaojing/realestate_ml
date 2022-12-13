#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 06:25:46 2021

@author: xiaojingni
"""

###Twitter Homebuying
### txt/csv data

import pandas as pd
import os
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer

os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')


CSV_DF=pd.read_csv("homebuying_twitter.csv")

CSV_DF.head()

## take a sample from orginal data

s_df = CSV_DF

