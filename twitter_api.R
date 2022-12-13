##################################
## This code are revided from Dr.Gates R twitter API code

---------------------------------
#############################################################
### The Twitter API   ########################################
############################################################
setwd("~/Desktop/GU/ANLY501/portfolio/data")

#install.packages("twitteR")
#install.packages("ROAuth")
#install.packages("rtweet")
library(rtweet)
library(twitteR)
library(ROAuth)
library(jsonlite)

## read my API keys 
## users should have their own keys
filename="Twitter_API_keys.txt"
(tokens<-read.csv(filename, header=TRUE, sep=","))


(consumerKey=as.character(tokens$consumerKey))
consumerSecret=as.character(tokens$consumerSecret)
access_Token=as.character(tokens$access_Token)
access_Secret=as.character(tokens$access_Secret)


requestURL='https://api.twitter.com/oauth/request_token'
accessURL='https://api.twitter.com/oauth/access_token'
authURL='https://api.twitter.com/oauth/authorize'

setup_twitter_oauth(consumerKey,consumerSecret,access_Token,access_Secret)
Search1<-twitteR::searchTwitter("#homebuying -filter:retweets",n=5000, lang = "en", 
                                since="2019-01-01")
Search_DF2 <- twListToDF(Search1)
head(Search_DF2)

(Search_DF2$text[1])


########## Place Tweets in a new file, named homebuying ###################
FName = "homebuying_2019.txt"
## Start the file
MyFile <- file(FName)
## Write Tweets to file
cat(unlist(Search_DF2), " ", file=MyFile, sep="\n")
close(MyFile)


