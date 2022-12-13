#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 28 09:33:27 2021

@author: xiaojingni
"""
from os import path
import matplotlib.pyplot as plt
##install wordcloud
from wordcloud import WordCloud, STOPWORDS

'''
os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')
'''
## define a function convert list to string
def listToString(s): 
    
    # initialize an empty string
    str1 = "" 
    
    # traverse in the string  
    for ele in s: 
        str1 += ele  
    
    # return string  
    return str1 

## wordcloud of "home buying" news

text = [x.split(',')[1] for x in open("news_homebuying.csv").readlines()]      
text = listToString(text)
print(text)

wordcloud = WordCloud().generate(text)
# Open a plot of the generated image.
plt.imshow(wordcloud)
plt.axis("off")
plt.show()



