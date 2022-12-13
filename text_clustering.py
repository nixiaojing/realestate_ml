#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 11 09:23:28 2021

@author: xiaojingni
"""

"""
This code describes using different clustering methods to classify text data

Corpus includes news abstracts with key word "home buying" (labeled as 
"home buying"), "mortgage" (labeled as "mortgage"), and real estate labeled as
"real estate".
"""

import warnings
from sklearn.feature_extraction import text 
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
import numpy as np
import pandas as pd
import os
import json
import re
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans, AgglomerativeClustering, DBSCAN
from scipy.cluster.hierarchy import dendrogram, linkage
from yellowbrick.cluster import SilhouetteVisualizer
from wordcloud import WordCloud, STOPWORDS

warnings.filterwarnings('ignore')

#%% Data Preparation

##########################################################
## read json files and combine them into one data frame ##
##########################################################

## set path to the corpus path
os.chdir('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data')

## Creat labels and content
my_label = list()
my_content = list()
my_title = list()

# Opening real_estate JSON file
f = open('real_estate.json')
 
# returns JSON object as
# a dictionary
data = json.load(f)
 
# Iterating through the json
# list
for i in range(len(data['articles'])):
    my_label.append("real estate")
    my_content.append(data['articles'][i]['description'])
    my_title.append(data['articles'][i]['title'])
 
# Closing file
f.close()

# Opening home buying JSON file
f = open('homebuying_news.json')
 
# returns JSON object as
# a dictionary
data = json.load(f)
 
# Iterating through the json
# list
for i in range(len(data['articles'])):
    my_label.append("home buying")
    my_content.append(data['articles'][i]['description'])
    my_title.append(data['articles'][i]['title'])
 
# Closing file
f.close()

# Opening mortgage JSON file
f = open('mortgage.json')
 
# returns JSON object as
# a dictionary
data = json.load(f)
 
# Iterating through the json
# list
for i in range(len(data['articles'])):
    my_label.append("mortgage")
    my_content.append(data['articles'][i]['description'])
    my_title.append(data['articles'][i]['title'])
 
# Closing file
f.close()



### check length of those lists

len(my_label)
len(my_content)
len(my_title)


### to pandas df

d = {'label': my_label, 'content': my_content, 'title':my_title}
news = pd.DataFrame(data=d)

## drop duplicate using my_title

news = news.drop_duplicates(subset=['title'], keep='last')

news.head()
news.info()

## delete "title" column
news = news.drop(columns=['title'])
news.head()
news.info()

news.to_csv('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/merged_news.csv')


#%% CountVectorizer() DTM dataframe
############################################
## df to  CountVectorizer() DTM dataframe ##
############################################

### count the words with CountVectorizer() with input type of "content"
## using labels as stop_words to remove the impact of labels (key words)
## also remove numbers

## get label and content list
news_Content_List=news.content.tolist()
news_Labels_List=news.label.tolist()

## my stopwords include "www" since many of the news are online 
## with www in the text. And the news content includes days are also removed

my_stopword = ["www","_blank",
                        "sunday" ,"monday", "tuesday", "wednesday" ,"thursday" ,
                        "friday", "saturday"]
stop_words = text.ENGLISH_STOP_WORDS.union(my_stopword)

## define a preprocessor to let CountVectorizer() ingnore numbers
def no_number_preprocessor(tokens):
    r = re.sub('(\d)+', '', tokens.lower())
    # This alternative just removes numbers:
    # r = re.sub('(\d)+', '', tokens.lower())
    return r


news_cv=CountVectorizer(input='content',
                        stop_words=stop_words,
                        preprocessor=no_number_preprocessor
                        )
## assign a variable to save the DTM
news_DTM=news_cv.fit_transform(news_Content_List)

## Get the words occur in the text files
MyColumnNames=news_cv.get_feature_names()
print("The vocab is: ", MyColumnNames, "\n\n")

## Use pandas to create data frames
news_DTM_DF=pd.DataFrame(news_DTM.toarray(),columns=MyColumnNames)

## add lables to data frame
news_DTM_DF["LABEL"]=news_Labels_List

news_DTM_DF.head()

## save to csv
news_DTM_DF.to_csv('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/news_cv_dtm.csv')

#%% TfidfVectorizer() DTM dataframe
############################################
## df to  TfidfVectorizer() DTM dataframe ##
############################################

news_tf = TfidfVectorizer(input='content',   
                        stop_words=stop_words,  
                        preprocessor=no_number_preprocessor
                        )

## assign a variable to save the Tfidf DTM
news_DTM_tf=news_tf.fit_transform(news_Content_List)

## Get the words occur in the text files
MyColumnNames=news_tf.get_feature_names()
print("The vocab is: ", MyColumnNames, "\n\n")

## Use pandas to create data frames
news_DTM_tf_DF=pd.DataFrame(news_DTM_tf.toarray(),columns=MyColumnNames)

## add lables to data frame
news_DTM_tf_DF["LABEL"]=news_Labels_List

news_DTM_tf_DF.head()

## save to csv
news_DTM_tf_DF.to_csv('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/data/news_tf_dtm.csv')

#%%PCA

from sklearn.decomposition import PCA

## remove label
news_DTM_tf_DF_n = news_DTM_tf_DF.iloc[:, :-1]

NumCols=news_DTM_tf_DF_n.shape[1]

## Instantiated my own copy of PCA
My_pca = PCA(n_components=2)  ## I want the two prin columns


## Transpose it

news_DTM_tf_DF_t=np.transpose(news_DTM_tf_DF_n)
My_pca.fit(news_DTM_tf_DF_t)
print(My_pca.explained_variance_ratio_)

print(My_pca)
print(My_pca.components_.T)
KnownLabels=news_Labels_List

# Reformat and view results
Comps = pd.DataFrame(My_pca.components_.T,
                        columns=['PC%s' % _ for _ in range(2)],
                        index=news_DTM_tf_DF_t.columns
                        )
print(Comps)
print(Comps.iloc[:,0])
#RowNames = list(Comps.index)
#print(RowNames)

########################
## Look at 2D PCA clusters
############################################

plt.figure(figsize=(12,12))
plt.scatter(Comps.iloc[:,0], Comps.iloc[:,1], s=100, color="green")

plt.xlabel("PC 1")
plt.ylabel("PC 2")
plt.title("Scatter Plot Clusters PC 1 and 2",fontsize=15)
for i, label in enumerate(KnownLabels):
    #print(i)
    #print(label)
    plt.annotate(label, (Comps.iloc[i,0], Comps.iloc[i,1]))
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/pca_news.png')
plt.show()


#%% Word cloud for EDA
########################
## Word cloud for EDA ##
########################
### obtain four kinds of content: overall, mortgage, home_buying and real_estate

all_content= ' '.join(news['content'].tolist())
mortgage=' '.join(news.loc[news['label'] == "mortgage"]['content'].tolist())
home_buying=' '.join(news.loc[news['label'] == "home buying"]['content'].tolist())
real_estate=' '.join(news.loc[news['label'] == "real estate"]['content'].tolist())

## for overall content
all_wordcloud = WordCloud(stopwords=stop_words).generate(all_content)
# Open a plot of the generated image.
plt.imshow(all_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/all-news_wc.png')
plt.show()

## for mortgage 
mortgage_wordcloud = WordCloud(stopwords=stop_words).generate(mortgage)
# Open a plot of the generated image.
plt.imshow(mortgage_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/mortgage_news_wc.png')
plt.show()

## for home_buying
hb_wordcloud = WordCloud(stopwords=stop_words).generate(home_buying)
# Open a plot of the generated image.
plt.imshow(hb_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/hb_news_wc.png')
plt.show()

## for real estate
re_wordcloud = WordCloud(stopwords=stop_words).generate(real_estate)
# Open a plot of the generated image.
plt.imshow(re_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/re_news_wc.png')
plt.show()


#%% Clustering
################
## Clustering ##
################

### k mean clustering

## correct classification
classnames, indices = np.unique(np.array(news_DTM_DF.LABEL), return_inverse=True)
print(indices)

# prepare input
# CV convert all numeric data to array (exlude label) 
news_DTM_ary = news_DTM_DF.loc[:, news_DTM_DF.columns != 'LABEL'].to_numpy()
# Tf convert all numeric data to array (exlude label)
news_DTM_tf_ary = news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL'].to_numpy()

## k =2
# CV
km_k2 = KMeans(n_clusters=2, random_state=42)
print(km_k2.fit_predict(news_DTM_ary))
# Tf
km_k2_t = KMeans(n_clusters=2, random_state=42)
print(km_k2_t.fit_predict(news_DTM_tf_ary))

## k = 3
# CV
km_k3 = KMeans(n_clusters=3, random_state=42)
print(km_k3.fit_predict(news_DTM_ary))
# Tf
km_k3_t = KMeans(n_clusters=3, random_state=42)
print(km_k3_t.fit_predict(news_DTM_tf_ary))

## k = 4
# CV
km_k4 = KMeans(n_clusters=4, random_state=42)
print(km_k4.fit_predict(news_DTM_ary))
# Tf
km_k4_t = KMeans(n_clusters=4, random_state=42)
print(km_k4_t.fit_predict(news_DTM_tf_ary))

#%% optimal k
## Elbow to find optimal k
wcss=[]
for i in range(1,7):
    kmeans = KMeans(i)
    kmeans.fit(news_DTM_ary)
    wcss_iter = kmeans.inertia_
    wcss.append(wcss_iter)

number_clusters = range(1,7)
plt.plot(number_clusters,wcss)
plt.title(' Elbow Method')
plt.xlabel('Number of clusters')
plt.ylabel('WCSS')
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/elbow_text.png')


## Silhouette to find optimal k

## Visualization of Sihouette plot, from 
## https://dzone.com/articles/kmeans-silhouette-score-explained-with-python-exam
fig, ax = plt.subplots(3, 2, figsize=(15,8))
for i in [2, 3, 4, 5,6,7]:
    '''
    Create KMeans instance for different number of clusters
    '''
    km = KMeans(n_clusters=i, init='k-means++', n_init=10, max_iter=100, random_state=42)
    q, mod = divmod(i, 2)
    '''
    Create SilhouetteVisualizer instance with KMeans instance
    Fit the visualizer
    '''
    visualizer = SilhouetteVisualizer(km, colors='yellowbrick', ax=ax[q-1][mod])
    visualizer.fit(news_DTM_tf_ary)

plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/sil_text.png')


#%% Hierarchical

model = AgglomerativeClustering(n_clusters=3, affinity='euclidean')
model.fit(news_DTM_tf_ary)
print(model.fit_predict(news_DTM_tf_ary))

## add label as index
news_DTM_tf_DF1= news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL']
news_DTM_tf_DF1.index = news_DTM_tf_DF.LABEL


import scipy.cluster.hierarchy as shc

plt.figure(figsize=(10, 7))
plt.title("Customer Dendograms")
dend = shc.dendrogram(shc.linkage(news_DTM_tf_DF1, method='ward'), 
                      labels=news_DTM_tf_DF1.index, leaf_font_size=14)
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/hc_dendro.png')
plt.show()



#%% DBSCAN
dbscan=DBSCAN()
dbscan.fit(news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL'])
print(dbscan.fit_predict(news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL']))

from sklearn.neighbors import NearestNeighbors
neigh = NearestNeighbors(n_neighbors=2)
nbrs = neigh.fit(news_DTM_tf_ary)
distances, indices = nbrs.kneighbors(news_DTM_tf_ary)

# Plotting K-distance Graph
distances = np.sort(distances, axis=0)
distances = distances[:,1]
plt.figure(figsize=(20,10))
plt.plot(distances)
plt.title('K-distance Graph',fontsize=20)
plt.xlabel('Data Points sorted by distance',fontsize=14)
plt.ylabel('Epsilon',fontsize=14)
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/db_eipsilon.png')
plt.show()

from sklearn.cluster import DBSCAN
dbscan_opt=DBSCAN(eps=1.1,min_samples=2)
dbscan_opt.fit(news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL'])
print(dbscan_opt.fit_predict(news_DTM_tf_DF.loc[:, news_DTM_tf_DF.columns != 'LABEL']))











