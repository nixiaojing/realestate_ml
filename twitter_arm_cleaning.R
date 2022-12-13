### This session contains tweets cleaning code used to produce twitter 
### association rule mining analysis

### read input, the twitter input is in txt format and obtained by twitter_api.R
############################################################
### Obtaining data from Twitter API, same as twitter_api.###
############################################################
setwd("~/Desktop/GU/ANLY501/portfolio/data")

#install.packages("twitteR")
#install.packages("ROAuth")
#install.packages("rtweet")
library(rtweet)
library(twitteR)
library(ROAuth)
library(jsonlite)
library(tokenizers)
library(stopwords)
library(tm)
library(arules)


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

token <- create_token(
  consumer_key = consumerKey,
  consumer_secret = consumerSecret,
  access_token = access_Token,
  access_secret = access_Secret)

## seach and eliminate retweets
Search1<-search_tweets("#homebuying -filter:retweets",n=5000, lang = "en", 
                       include_rts = FALSE, token=token)
Search_text <- Search1$text
head(Search_text)

########## Place Tweets in a new file, named homebuying ###################
FName = "homebuying_tweets.txt"
## Start the file
MyFile <- file(FName)
## Write Tweets to file
cat(unlist(Search_DF2), " ", file=MyFile, sep="\n")
close(MyFile)


##################################################################
### Below is revised from Dr.Gates code to tokenlize the tweets ##
##################################################################
#make data frame
## do.call is a list that holds all arguments in a function
## https://www.stat.berkeley.edu/~s133/Docall.html
##(Search2_DF <- do.call("rbind", lapply(Search2, as.data.frame)))
## OR
#tokenize_tweets(x, lowercase = TRUE, stopwords = NULL, strip_punct = TRUE, 
#                 strip_url = FALSE, simplify = FALSE)

#tokenize_tweets(Search2_DF$text[1],stopwords = stopwords::stopwords("en"), 
#               lowercase = TRUE,  strip_punct = TRUE, 
#               strip_url = TRUE, simplify = TRUE)

## Start the file
Trans <- file("TransactionTweetsFile")
## Tokenize to words, using tokenize_tweets() and remove url,
Tokens<-tokenizers::tokenize_tweets(
  Search_text[1],stopwords = stopwords::stopwords("en"), 
  lowercase = T,  strip_punct = T,
  simplify = T, strip_url = TRUE)
## remove numbers
Tokens <- removeNumbers(Tokens)

## Write tokens
cat(unlist(Tokens), "\n", file=Trans, sep=",")
close(Trans)

## Append remaining lists of tokens into file
## Recall - a list of tokens is the set of words from a Tweet
Trans <- file("TransactionTweetsFile", open = "a")
for(i in 2:length(Search_text)){
  Tokens<-tokenizers::tokenize_tweets(Search_text[i],
                                      stopwords = stopwords::stopwords("en"), 
                                      lowercase = T,  strip_punct = T,
                                      simplify = T, strip_url = TRUE)
  Tokens <- removeNumbers(Tokens)
  
  cat(unlist(Tokens), "\n", file=Trans, sep=",")
  cat(unlist(Tokens))
}
close(Trans)

#######################
### Tweets cleaning ###
#######################

## Read the transactions data into a dataframe
TweetDF <- read.csv("TransactionTweetsFile", 
                    header = FALSE, sep = ",")
head(TweetDF)
(str(TweetDF))

## Convert all columns to char 
TweetDF<-TweetDF %>%
  mutate_all(as.character)
(str(TweetDF))


# Remove certain words
TweetDF[TweetDF == "t.co"] <- ""
TweetDF[TweetDF == "http"] <- ""
TweetDF[TweetDF == "https"] <- ""

## remove words start with "@"
## check values, should be a word starting with "@"
TweetDF$V1[53]

TweetDF <- data.frame(lapply(TweetDF, function(x) gsub("@\\w+ *", "", x)))

## check if the word was removed
TweetDF$V1[53]


## remove emoji
## check values, should be an emoji
TweetDF$V2[16]
## remove non-ASCII characters
TweetDF <- data.frame(lapply(TweetDF, function(x) gsub("[^\x01-\x7F]", "", x)))
## check if emoji is removed
TweetDF$V2[16]


## Check it so far....
TweetDF

## Clean with grepl - every row in each column
MyDF<-NULL
MyDF2<-NULL
for (i in 1:ncol(TweetDF)){
  MyList=c() 
  MyList2=c() # each list is a column of logicals ...
  MyList=c(MyList,grepl("[[:digit:]]", TweetDF[[i]]))
  MyDF<-cbind(MyDF,MyList)  ## create a logical DF
  
  ### remove words less than 4 letters and more than 11 letters
  MyList2=c(MyList2,(nchar(TweetDF[[i]])<4 | nchar(TweetDF[[i]])>11))
  MyDF2<-cbind(MyDF2,MyList2) 
  ## TRUE is when a cell has a word that contains digits
}
## For all TRUE, replace with blank
TweetDF[MyDF] <- ""
TweetDF[MyDF2] <- ""
(head(TweetDF,10))



# Now we save the dataframe using the write table command 
write.table(TweetDF, file = "UpdatedTweetFile.csv", col.names = FALSE, 
            row.names = FALSE, sep = ",")
TweetTrans <- read.transactions("UpdatedTweetFile.csv", sep =",", 
                                format("basket"),  rm.duplicates = TRUE)


