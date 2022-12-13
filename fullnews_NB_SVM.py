#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 23 15:14:59 2021

@author: xiaojingni
"""

"""
This code is used to perform Naive Bayes and Support Vector Machine analysis 
using cleaned full news content
"""

import pandas as pd
import os
import string
import numpy as np
import matplotlib.pyplot as plt
import re  
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.svm import LinearSVC
from wordcloud import WordCloud, STOPWORDS
from sklearn.feature_extraction import text 
from sklearn import metrics
from sklearn.metrics import confusion_matrix
from sklearn.metrics import ConfusionMatrixDisplay
from sklearn.naive_bayes import MultinomialNB
import sklearn as sklearn
from sklearn.svm import SVC


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
#%% Create Training and Testing Data

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

#%% Naive Bayes -- 

topics = ["mortgage", "real estate", "home buying"]
#https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html#sklearn.naive_bayes.MultinomialNB.fit
#Create the modeler
MyModelNB= MultinomialNB()

NB=MyModelNB.fit(TrainDF, TrainLabels)
Prediction = MyModelNB.predict(TestDF)
print(np.round(MyModelNB.predict_proba(TestDF),2))


print("\nThe prediction from NB is:")
print(Prediction)
print("\nThe actual labels are:")
print(TestLabels)


## confusion matrix

cnf_matrix = confusion_matrix(TestLabels, Prediction)
print("\nThe confusion matrix is:")
print(cnf_matrix)

## Printing confusion matrix report
print(metrics.classification_report(TestLabels, Prediction, labels = topics))

#### Creating a visually appealing confusion matrix
disp = ConfusionMatrixDisplay(cnf_matrix, display_labels = topics)
fig, ax = plt.subplots(figsize = (9, 8))
disp.plot(ax = ax)
plt.title(label = "NB Confusion Matrix", loc = 'Center')
plt.savefig("NB_ConfMatrix.png")
plt.show()


#%% SVM

## linear kernel

SVM_Model_li=LinearSVC(C=1.0, class_weight=None, dual=True, fit_intercept=True,
          intercept_scaling=1, loss='squared_hinge', max_iter=1000,
          multi_class='ovr', penalty='l2', random_state=None, tol=0.0001,
          verbose=0)

SVM_Model_li.fit(TrainDF, TrainLabels)


SVM_matrix_li = confusion_matrix(TestLabels, SVM_Model_li.predict(TestDF))
print("\nThe confusion matrix is:")
print(SVM_matrix_li)
print("\n\n")

#### Creating a visually appealing confusion matrix
disp = ConfusionMatrixDisplay(SVM_matrix_li, display_labels = topics)
fig, ax = plt.subplots(figsize = (9, 8))
disp.plot(ax = ax)
plt.title(label = "SVM with Linear Kernel Confusion Matrix", loc = 'Center')
plt.savefig("SVM_ConfMatrix_li.png")
plt.show()

## polynomial kernel

SVM_Model_poly=sklearn.svm.SVC(C=100, kernel='poly', degree=2, gamma="auto")
SVM_Model_poly.fit(TrainDF, TrainLabels)


SVM_matrix_poly = confusion_matrix(TestLabels, SVM_Model_poly.predict(TestDF))
print("\nThe confusion matrix is:")
print(SVM_matrix_poly)
print("\n\n")

#### Creating a visually appealing confusion matrix
disp = ConfusionMatrixDisplay(SVM_matrix_poly, display_labels = topics)
fig, ax = plt.subplots(figsize = (9, 8))
disp.plot(ax = ax)
plt.title(label = "SVM with Polynomial Kernel Confusion Matrix", loc = 'Center')
plt.savefig("SVM_ConfMatrix_poly.png")
plt.show()


## radical kernel

## RBF
SVM_Model_rd=sklearn.svm.SVC(C=1, kernel='rbf', degree=3, gamma="auto")
SVM_Model_rd.fit(TrainDF, TrainLabels)


SVM_matrix_rd = confusion_matrix(TestLabels, SVM_Model_rd.predict(TestDF))
print("\nThe confusion matrix is:")
print(SVM_matrix_rd)
print("\n\n")

#### Creating a visually appealing confusion matrix
disp = ConfusionMatrixDisplay(SVM_matrix_rd, display_labels = topics)
fig, ax = plt.subplots(figsize = (9, 8))
disp.plot(ax = ax)
plt.title(label = "SVM with RBF Kernel Confusion Matrix", loc = 'Center')
plt.savefig("SVM_ConfMatrix_rd.png")
plt.show()



