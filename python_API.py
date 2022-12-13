#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 15:07:42 2021

@author: xiaojingni
"""
## Zillow API
## http://www.zillow.com/webservice/GetSearchResults.htm
## required ZWSID
## documentation: https://www.zillow.com/howto/api/GetSearchResults.htm

import requests


###### Endpoint
BaseURL="http://www.zillow.com/webservice/GetSearchResults.htm"


######################################################## 
## WAY 1  
URLPost = {'zws-id': 'X1-ZWz1ii1lzd2m17_7nbg7',
                    'source': 'bbc-news', 
                    'pageSize': 85,
                    'sortBy' : 'top',
                    'totalRequests': 75}

###### requests.get() will get the format of the URL from endpoint (BaseURL) and build the query url for you
response1=requests.get(BaseURL, URLPost)
jsontxt = response1.json()
print(jsontxt)

####################################################

### WAY 2
url = ('https://newsapi.org/v2/everything?'
       'q=Sports&'
       'from=2019-11-20&'
       'sortBy=relevance&'
       'source=bbc-news&'
       'pageSize=100&'
       'apiKey=8f413- GET YOUR OWN KEY -2100f22b')

response2 = requests.get(url)
jsontxt2 = response2.json()
print(jsontxt2, "\n")
#####################################################

## Create a new csv file to save the headlines
MyFILE=open("BBCNews3.csv","w")
### Place the column names in - write to the first row
WriteThis="Author,Title,Headline\n"
MyFILE.write(WriteThis)
MyFILE.close()


## Open the file for append
MyFILE=open("BBCNews3.csv", "a")
for items in jsontxt["articles"]:
    print(items)
              
    Author=items["author"]