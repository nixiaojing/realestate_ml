#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 22:09:04 2021

@author: xiaojingni
"""
"""
This code is used to generate a clean dataset using full news content based on 
the search results from NewsAPI
"""
import pandas as pd
import re

#%% read data
df = pd.read_csv("~/Desktop/GU/ANLY501/portfolio/data/full_news.csv", 
                 encoding = "unicode_escape", header = None,
                names = ["label", "content"])

df.head()

#%% clean data

## special characters to white space
df["clean_content"] = df["content"].str.replace(r'[^A-Za-z ]+', ' ', regex=True)

## compress white spaces
df["clean_content"] = df["clean_content"].str.replace(r'\s+', ' ', regex=True)

#%% save to a new csv
clean_df = df[["label", "clean_content"]]
clean_df.to_csv("~/Desktop/GU/ANLY501/portfolio/data/full_news_clean.csv")