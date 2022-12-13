#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 06:46:28 2021

@author: xiaojingni
"""
#### News "real estate"

#####################################################################
## Due to assignment requirement, here Json is first converted to csv
## and then use CountVectorizer() to clean the data as in class
#####################################################################

## read json to lists
import json
import os

'''
os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')
'''

## Creat labels and content
my_label = list()
my_content = list()
my_title = list()

# Opening JSON file
f = open('real_estate.json')
 
# returns JSON object as
# a dictionary
data = json.load(f)
 
# Iterating through the json
# list
for i in range(len(data['articles'])):
    my_label.append(data['articles'][i]['source']['name'])
    my_content.append(data['articles'][i]['description'])
    my_title.append(data['articles'][i]['title'])
 
# Closing file
f.close()

### check length of those lists

len(my_label)
len(my_content)
len(my_title)


######### To txt files, each article is one txt file, with the name of article 
## title

for i in range(len(my_label)):
    filename = my_title[i]
    print(filename)
    with open(filename+".txt","w") as f:
        L = [my_label[i],":",my_content[i]]
        f.writelines(L)

## corpus contains articles with unique title. In this way, duplicated article 
## would be removed.
 
        
 
##################################################################
## csv --> dataframe using CountVectorizer
##################################################################

import pandas as pd
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer

news_re_df=pd.read_csv("news_homebuying.csv", header = None, names=None)

news_re_df.head()
news_re_df.info()

####### From Dr.Gates code

news_Content_List=news_re_df[1].tolist()
news_Labels_List=news_re_df[0].tolist()


#### using CountVectorizer()

news_content=CountVectorizer(input='content',
                        stop_words='english',
                        )

My_DTM2=news_content.fit_transform(news_Content_List)

ColNames=news_content.get_feature_names()
print("The vocab is: ", ColNames, "\n\n")

## NEXT - Use pandas to create data frames
News_DF_content=pd.DataFrame(My_DTM2.toarray(),columns=ColNames)

## Let's look!
print(News_DF_content)


print(news_Labels_List)

News_DF_content.insert(loc=0, column='LABEL', value=news_Labels_List)

## Have a look
print(News_DF_content)

## Write to csv file
News_DF_content.to_csv('NewsHB_CSV_count.csv', index=False)








