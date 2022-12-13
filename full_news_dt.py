#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 11 10:06:52 2021

@author: xiaojingni
"""

"""
This code is used to perform decision tree analysis using cleaned full news 
content
"""
import pandas as pd
import re
import numpy as np
import matplotlib.pyplot as plt


from sklearn.feature_extraction import text 
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.metrics import confusion_matrix
from sklearn import tree

from wordcloud import WordCloud, STOPWORDS

import random as rd

## conda install python-graphviz
## restart kernel (click the little red x next to the Console)
import graphviz


#%% read data
full_news = pd.read_csv("full_news_clean.csv", 
                 encoding = "unicode_escape",index_col=0)

full_news.head()
full_news.info()

#%% Tokenize and Vectorize the news content
## Create the list of news content

ContentLIST=[]
LabelLIST=[]

for nextcontent, nextlabel in zip(full_news["clean_content"], full_news["label"]):
    ContentLIST.append(nextcontent)
    LabelLIST.append(nextlabel)

print("The content list is:\n")
print(ContentLIST)

print("The label list is:\n")
print(LabelLIST)

#%% vectorize and customize stopwords using TfidfVectorizer


## my stopwords include "www" since many of the news are online 
## with www in the text. And the news content includes days are also removed
## the content also include many "read more", thus, "read" is removed
## also remove many words are common in news article

my_stopword = ["www","_blank",
                        "sunday" ,"monday", "tuesday", "wednesday" ,"thursday" ,
                        "friday", "saturday","read","real estate", "real",
                        "estate", "mortgage", "home buying","home","buying", "said"]
stop_words = text.ENGLISH_STOP_WORDS.union(my_stopword)



news_cv=TfidfVectorizer(input='content',
                        stop_words=stop_words,
                        lowercase = True,
                        ngram_range=(1, 2)
                        )

## Use your CV 
MyDTM = news_cv.fit_transform(ContentLIST)  # create a sparse matrix
print(type(MyDTM))


ColumnNames=news_cv.get_feature_names()
#print(type(ColumnNames))


## Build the data frame
MyDTM_DF=pd.DataFrame(MyDTM.toarray(),columns=ColumnNames)

## Convert the labels from list to df
Labels_DF = pd.DataFrame(LabelLIST,columns=['label'])

## Check your new DF and you new Labels df:
print("Labels\n")
print(Labels_DF)
print("News df\n")
print(MyDTM_DF.iloc[:,0:6])

## keep words (phrase) with length between 4 to 20
MyDTM_DF = MyDTM_DF.loc[:,(4<MyDTM_DF.columns.str.len()) & (MyDTM_DF.columns.str.len()<=20)]

##Save original DF - without the lables
My_Orig_DF=MyDTM_DF
print(My_Orig_DF)

# a df with label
dfs = [Labels_DF, MyDTM_DF]

Final_News_DF_Labeled = pd.concat(dfs,axis=1, join='inner')
## DF with labels
print(Final_News_DF_Labeled)


#%% Word cloud for EDA (full news)
########################
## Word cloud for EDA ##
########################
### obtain four kinds of content: overall, mortgage, home_buying and real_estate

all_content= ' '.join(full_news['clean_content'].tolist())
mortgage=' '.join(full_news.loc[full_news['label'] == "mortgage"]['clean_content'].tolist())
home_buying=' '.join(full_news.loc[full_news['label'] == "home buying"]['clean_content'].tolist())
real_estate=' '.join(full_news.loc[full_news['label'] == "real estate"]['clean_content'].tolist())

## for overall content
all_wordcloud = WordCloud(stopwords=stop_words).generate(all_content)
# Open a plot of the generated image.
plt.imshow(all_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/all-news_wc_full.png')
plt.show()

## for mortgage 
mortgage_wordcloud = WordCloud(stopwords=stop_words).generate(mortgage)
# Open a plot of the generated image.
plt.imshow(mortgage_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/mortgage_news_wc_full.png')
plt.show()

## for home_buying
hb_wordcloud = WordCloud(stopwords=stop_words).generate(home_buying)
# Open a plot of the generated image.
plt.imshow(hb_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/hb_news_wc_full.png')
plt.show()

## for real estate
re_wordcloud = WordCloud(stopwords=stop_words).generate(real_estate)
# Open a plot of the generated image.
plt.imshow(re_wordcloud)
plt.axis("off")
plt.savefig('/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/re_news_wc_full.png')
plt.show()

#%% Gates wordclouds
## Before we start our modeling, let's visualize and
## explore.

##It might be very interesting to see the word clouds 
## for each  of the topics. 
##--------------------------------------------------------
List_of_WC=[]
topics = ["mortgage", "real estate", "home buying"]

for mytopic in topics:

    tempdf = Final_News_DF_Labeled[Final_News_DF_Labeled['label'] == mytopic]
    print(tempdf)
    
    tempdf =tempdf.sum(axis=0,numeric_only=True)
    #print(tempdf)
    
    #Make var name
    NextVarName=str("wc"+str(mytopic))
    #print( NextVarName)
    
    ##In the same folder as this code, I have three images
    ## They are called: food.jpg, bitcoin.jpg, and sports.jpg
    #next_image=str(str(mytopic) + ".jpg")
    #print(next_image)
    
    ## https://amueller.github.io/word_cloud/generated/wordcloud.WordCloud.html
    
    ###########
    ## Create and store in a list the wordcloud OBJECTS
    #########
    NextVarName = WordCloud(width=1000, height=600, background_color="white",
                   min_word_length=4, #mask=next_image,
                   max_words=200).generate_from_frequencies(tempdf)
    
    ## Here, this list holds all three wordclouds I am building
    List_of_WC.append(NextVarName)
    

##------------------------------------------------------------------
print(List_of_WC)
##########
########## Create the wordclouds
##########
fig=plt.figure(figsize=(25, 25))
#figure, axes = plt.subplots(nrows=2, ncols=2)
NumTopics=len(topics)
for i in range(NumTopics):
    print(i)
    ax = fig.add_subplot(NumTopics,3,i+1)
    plt.imshow(List_of_WC[i], interpolation='bilinear')
    plt.axis("off")
    plt.savefig("/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/NewClouds.png")

#%% Decision tree 

################################################
## Create Training and Testing Data
###############################################################

TrainDF, TestDF = train_test_split(Final_News_DF_Labeled, test_size=0.3)
print(TrainDF)
print(TestDF)

#################################################
## Separate LABELS
#################################################

### TEST ---------------------
TestLabels=TestDF["label"]
print(TestLabels)
TestDF = TestDF.drop(["label"], axis=1)
print(TestDF)
### TRAIN----------------------
TrainLabels=TrainDF["label"]
print(TrainLabels)
## remove labels
TrainDF = TrainDF.drop(["label"], axis=1)

##################################################
## Run DT
##################################################
#%% Decision tree 1
## Tree 1, criterion = gini
## Instantiate
MyDT=DecisionTreeClassifier(criterion='gini', 
                            splitter='best',  
                            max_depth=None, 
                            min_samples_split=2, 
                            min_samples_leaf=1, 
                            min_weight_fraction_leaf=0.0, 
                            max_features=None, 
                            random_state=None, 
                            max_leaf_nodes=None, 
                            min_impurity_decrease=0.0, 
                            min_impurity_split=None, 
                            class_weight=None)

##
MyDT.fit(TrainDF, TrainLabels)


feature_names=TrainDF.columns
Tree_Object = tree.export_graphviz(MyDT, out_file=None,
                    ## The following creates TrainDF.columns for each
                    ## which are the feature names.
                      feature_names=feature_names,  
                      class_names=["real estate","home buying","mortgage"],
                      #["food","sports","bitcoin"],  
                      filled=True, rounded=True,  
                      special_characters=True)      
                              
graph = graphviz.Source(Tree_Object) 
    
graph.render("MyTree") 


## COnfusion Matrix
print("Prediction\n")
DT_pred=MyDT.predict(TestDF)
print(DT_pred)
    
bn_matrix = confusion_matrix(TestLabels, DT_pred)
print("\nThe confusion matrix is:")
print(bn_matrix)


FeatureImp=MyDT.feature_importances_   
indices = np.argsort(FeatureImp)[::-1]
featurn_name = []
feature_imp = []

## print out the important features.....
for f in range(TrainDF.shape[1]):
    if FeatureImp[indices[f]] > 0:
        feature_imp.append(FeatureImp[indices[f]])
        featurn_name.append(feature_names[indices[f]])
        print("%d. feature %d (%f)" % (f + 1, indices[f], FeatureImp[indices[f]]))
        print ("feature name: ", feature_names[indices[f]])
        
fig1 = plt.figure(figsize=(10, 6))
ax = fig1.add_axes([0,0,1,1])
x = featurn_name
imp = feature_imp
ax.bar(x,imp)
ax.set_ylabel('Importance')
plt.title("Decision Tree 1 Feature Importance")
plt.savefig("/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/dt1_imp.png",
            bbox_inches = "tight")
plt.show()

#%% Decision tree 2
## Tree 2, criterion = entropy
## Instantiate
MyDT2=DecisionTreeClassifier(criterion='entropy', 
                            splitter='best',  
                            max_depth=None, 
                            min_samples_split=2, 
                            min_samples_leaf=1, 
                            min_weight_fraction_leaf=0.0, 
                            max_features=None, 
                            random_state=None, 
                            max_leaf_nodes=None, 
                            min_impurity_decrease=0.0, 
                            min_impurity_split=None, 
                            class_weight=None)

##
MyDT2.fit(TrainDF, TrainLabels)


feature_names=TrainDF.columns
Tree_Object2 = tree.export_graphviz(MyDT2, out_file=None,
                    ## The following creates TrainDF.columns for each
                    ## which are the feature names.
                      feature_names=feature_names,  
                      class_names=["real estate","home buying","mortgage"],
                      #["food","sports","bitcoin"],  
                      filled=True, rounded=True,  
                      special_characters=True)      
                              
graph = graphviz.Source(Tree_Object2) 
    
graph.render("MyTree") 


## COnfusion Matrix
print("Prediction\n")
DT_pred2=MyDT2.predict(TestDF)
print(DT_pred2)
    
bn_matrix2 = confusion_matrix(TestLabels, DT_pred2)
print("\nThe confusion matrix is:")
print(bn_matrix2)


FeatureImp2=MyDT2.feature_importances_   
indices = np.argsort(FeatureImp2)[::-1]
featurn_name = []
feature_imp = []

## print out the important features.....
for f in range(TrainDF.shape[1]):
    if FeatureImp2[indices[f]] > 0:
        feature_imp.append(FeatureImp2[indices[f]])
        featurn_name.append(feature_names[indices[f]])
        print("%d. feature %d (%f)" % (f + 1, indices[f], FeatureImp2[indices[f]]))
        print ("feature name: ", feature_names[indices[f]])
        
fig1 = plt.figure()
ax = fig1.add_axes([0,0,1,1])
x = featurn_name
imp = feature_imp
ax.bar(x,imp)
ax.set_ylabel('Importance')
plt.title("Decision Tree 2 Feature Importance")
plt.savefig("/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/dt2_imp.png",
            bbox_inches = "tight")
plt.show()

#%% Decision tree 3
## Tree 3, splitter = random
## Instantiate
MyDT3=DecisionTreeClassifier(criterion='gini', 
                            splitter='random',  
                            max_depth=None, 
                            min_samples_split=2, 
                            min_samples_leaf=1, 
                            min_weight_fraction_leaf=0.0, 
                            max_features=None, 
                            max_leaf_nodes=None, 
                            min_impurity_decrease=0.0, 
                            min_impurity_split=None, 
                            class_weight=None,
                            random_state = 2021)

##
MyDT3.fit(TrainDF, TrainLabels)


feature_names=TrainDF.columns
Tree_Object3 = tree.export_graphviz(MyDT3, out_file=None,
                    ## The following creates TrainDF.columns for each
                    ## which are the feature names.
                      feature_names=feature_names,  
                      class_names=["real estate","home buying","mortgage"],
                      #["food","sports","bitcoin"],  
                      filled=True, rounded=True,  
                      special_characters=True)      
                              
graph = graphviz.Source(Tree_Object3) 
    
graph.render("MyTree") 


## COnfusion Matrix
print("Prediction\n")
DT_pred3=MyDT3.predict(TestDF)
print(DT_pred3)
    
bn_matrix3 = confusion_matrix(TestLabels, DT_pred3)
print("\nThe confusion matrix is:")
print(bn_matrix3)


FeatureImp3=MyDT3.feature_importances_   
indices = np.argsort(FeatureImp3)[::-1]
featurn_name = []
feature_imp = []

## print out the important features.....
for f in range(TrainDF.shape[1]):
    if FeatureImp3[indices[f]] > 0:
        feature_imp.append(FeatureImp3[indices[f]])
        featurn_name.append(feature_names[indices[f]])
        print("%d. feature %d (%f)" % (f + 1, indices[f], FeatureImp3[indices[f]]))
        print ("feature name: ", feature_names[indices[f]])
        
fig1 = plt.figure(figsize=(10, 6))
ax = fig1.add_axes([0,0,1,1])
x = featurn_name
imp = feature_imp
ax.bar(x,imp)
ax.set_ylabel('Importance')
plt.title("Decision Tree 3 Feature Importance")
plt.savefig("/Users/xiaojingni/Desktop/GU/ANLY501/portfolio/figure/dt3_imp.png",
            bbox_inches = "tight")
plt.show()
