#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 21:34:28 2021

@author: xiaojingni
"""
### News "mortgage"

#####################################################################
## Due to assignment requirement, here Json is first converted to corpus 
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
f = open('mortgage.json')
 
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
## corpus --> dataframe using CountVectorizer
##################################################################

import warnings
from sklearn.feature_extraction import text 
from sklearn.feature_extraction.text import CountVectorizer
import numpy as np
import pandas as pd
import os

warnings.filterwarnings('ignore')


## Read the corpus files into a Document Term Matrix Object (or DTM)
path="/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/mortgage_news"


## Get the text data first
print("calling os...")
FileNameList=os.listdir(path)
## check the TYPE
print(type(FileNameList))
len(FileNameList)
print(FileNameList)


## create the path of each file
MyFileNameList=[]
for nextfile in os.listdir(path):
    fullpath=path+"/"+nextfile
    #print(fullpath)
    MyFileNameList.append(fullpath)


### the label is the first several words before ":"

## read the labels as a list
## initiate a labels list
labels = list()

for i in FileNameList:
    with open(path+"/"+i,"r") as f:
        L = f.readline()
        labels.append(L.split(':')[0])

### count the words with CountVectorizer() with input type of "filename"
## using labels as stop_words to remove the impact of labels (press name)



stop_words = text.ENGLISH_STOP_WORDS.union(labels)

mortgage_cv=CountVectorizer(input='filename',
                        stop_words='english',
                        #max_features=100
                        )
mortgage_DTM=mortgage_cv.fit_transform(MyFileNameList)

MyColumnNames=mortgage_cv.get_feature_names()
print("The vocab is: ", MyColumnNames, "\n\n")

## NEXT - Use pandas to create data frames
mortgage_DF=pd.DataFrame(mortgage_DTM.toarray(),columns=MyColumnNames)

## add lables to data frame
mortgage_DF["LABEL"]=labels

## save to csv
mortgage_DF.to_csv('mortgage_CSV_Data.csv', index=False)



