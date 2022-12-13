#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  4 13:26:56 2021

@author: xiaojingni
"""
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 06:46:28 2021

@author: xiaojingni
"""
#### News "home buying"

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
f = open('homebuying_news.json')
 
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
 
        









