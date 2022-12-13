##############################
##
## Basic Steps for Cleaning
## record - type data in R
##
## Gates
##
##  DATA IS HERE:
## https://drive.google.com/file/d/1uNRseS1XPx52QNrPh-rtFCI_ERfMz9RY/view?usp=sharing
##
########################################################################

##
## LIBRARIES
##

library(ggplot2)
#library(plotly)

## Read in the dataset
## In R, read.csv will automatically read
## the data in as a dataframe
setwd("C:/Users/profa/Documents/RStudioFolder_1/DrGExamples/ANLY501")


dataset_Name<-"FemaleHealthDataDirtyExample.csv"

## Open and read into a dataframe
## the ns.string=c("") will turn blank into NA
## which makes cleaning easier.


FemaleHealth_DF <- read.csv(dataset_Name, na.string=c("", " "))

##print it...
head(FemaleHealth_DF, n=15)

## Have a look at the data types
str(FemaleHealth_DF)

####################################
##
## While "cleaning" will also depend
## on later models and methods and goals
## for now - we can do base cleaning.
##
## We will look at and will correct 
## (as needed):
## Missing values
## Incorrect values
## Incorrect formats
## Incorrect data types
## Duplicates
## Outliers
## 
## Then, we will perform discretization
## and in doing so will generate a new feature
##
## We will then use a transformation
## as well as normalization
#########################################################

#########################################################
##  STEP 1: Remove columns we do not need or want
##
#########################################################

## First - some basics..................
## Get column names

(ColNames<-names(FemaleHealth_DF))
ColNames[1] ## Access a column name
FemaleHealth_DF[ColNames[1]] ## Access data in a column by name


for(name in 1:length(ColNames)){
  cat(ColNames[name], "\n")
}

(NumColumns <-ncol(FemaleHealth_DF))
(NumRows <-nrow(FemaleHealth_DF))

## Let's make tables of all the columns

lapply(FemaleHealth_DF,table)  
lapply(FemaleHealth_DF,summary) 
## lapply will apply a function (like table) to all elements in
## a list. A dataframe is a type of list in R and so this works

## Now we can use this to think about cleaning...
## Let's look at the results...

## On a larger dataset, this would not be a very good solution
## for FEMALEID. In fact, because this is an ID number it is like
## a person's name. It CANNOT be used in the analysis. 

## We can see from the table that apple is here too. This is incorrect
## but we do not have to fix it because we plan to remove the entire column. 

## OK - first - let's look at the other tables...what do we see?
## There is at least one error in AGE and at least one in HEIGHT. 

## What else? At least two errors in WEIGHT and at least one in WAIST.
## Children has at least one error and Climate has at least two.

## This is just a first look - a way to EXPLORE. Tables do not ALWAYS
## help - but often they do. 

############################################
## Remove columns we do not want
## In this case - we only plan to remove the ID. 
## NOW - !! If we were cleaning for a job - we might
## keep this column - clean it - and then take special 
## case NOT to include it in any analysis. That is OK too!
## But - here - we will remove it so that you can see how to.
################################################################

## WAY 1: One way is by index - we want to remove column 1 here....
#(FemaleHealth_DF <- FemaleHealth_DF[,-1] )

#FemaleHealth_DF[ColNames[1]]
## Way 2 is using subset. There are other methods as well.
## Notice NO QUOTES around the variable name. 
(FemaleHealth_DF<- subset(FemaleHealth_DF, select=-c(FEMALEID)))


############################################################
## MISSING VALUES
##
############################################################

## check the entire DF for missing values in total
is.na(FemaleHealth_DF)  ## This method is logical 
## and can be useful for other logical operations

## We can also do this per variable and as a count....

lapply(FemaleHealth_DF, is.na)  ## logical per variable

## Using an inline function and sapply (for simplify apply)
sapply(FemaleHealth_DF, function(x) sum(is.na(x)))

## OK! Useful!

#####################################################
## Clean up missing values for each variable...
##
######################################################

### Cleaning - AGE  - WAIST - and WEIGHT      ###

######################################################

str(FemaleHealth_DF)
## This is WRONG.
## AGE should be a num, not a chr. 
## We need to fix this now so that we can then
## evaluate the mean and variance of the AGE values
## to determine if we can replace the missing values
## with a measure of center w/out disrupting the info
## in the dataset.

FemaleHealth_DF$AGE <- as.numeric(FemaleHealth_DF$AGE)
str(FemaleHealth_DF$AGE)
FemaleHealth_DF$AGE

## HANG ON!! - notice the warning about coercion...
sum(is.na(FemaleHealth_DF$AGE))
## Hmmmm- this was 2 and now its 3 - why??
## ANSWER: When we forced the data to go from chr to num
## We forced the word "young" to become NA. 
## This is important to note.
## Quick look
table(FemaleHealth_DF$AGE)  ## Looks OK

## mean, variance, etc.
summary(FemaleHealth_DF$AGE)
nrow(FemaleHealth_DF)
## OK! - so here we have fairly balanced data.
## We are missing 3 values out of 20. That is 15% 
## which is not insignificant.

sd(FemaleHealth_DF$AGE, na.rm = T)

## To do this right - we should look at 
## correlations between age and other variables
## To look at correlations - we need to first
## make sure that all data types are numeric
str(FemaleHealth_DF)

## NO! Here, HEIGHT is not numeric and needs to be
## Let's fix it

FemaleHealth_DF$HEIGHT <- as.numeric(FemaleHealth_DF$HEIGHT)
str(FemaleHealth_DF$HEIGHT)

pairs(FemaleHealth_DF[,c(1,2,3,4)],na.rm = T, col = "blue")
#FemaleHealth_DF
## Hmmm - this is not really working...
## Notice that some weights are so large
## that the vis is not helpful.

## OK - so we must look at the values again...

lapply(FemaleHealth_DF,summary) 
## NOtice the MAX for WEIGHT is 11000.
## We need to fix this too!
## Also - the min is 0 - that wrong also.

## WAIST has a -1 for min - also wrong!


## Now you see one of the many challenges
## of cleaning data.

## We have errors. We want to fix them. 
## but it is not clear which one to fix first
## So - let' do this:
## We were trying to correct the AGEs 
## To do that, we want to look at the
## correlations

## So - let's look at r values instead

## Spearman will get correlations
## without letting the outliers have
## such a great affect
(Temp<-FemaleHealth_DF[,c(1,2,3,4)])
##install.packages("psych")
library(psych)
pairs.panels(Temp)
corr.test(Temp, method = "spearman")

## OK!
## We can see that AGE is most correlated with WAIST

## So - to correct - replace - the missing AGE values
## let's use the WAIST to help us!

## WAIST is very correlated to WEIGHT

## So - a good plan is to correct WEIGHT and WAIST
## and then to correct AGE.

## What is the relationship between WEIGHT and WAIST
##linearEstimate <- lm(WEIGHT ~ WAIST, data=FemaleHealth_DF)  
# build linear regression model on full data
##print(linearEstimate)

## The above is a fun idea - but will not work b/c
## both variables still have outliers and/or missing values

## So - let's estimate....
summary(FemaleHealth_DF)
## One loose estimate is to not 
## that the median of WEIGHT is approx
## twice the median of WAIST.
## This is by no means a perfect estimate
## but given the strong correlation
## it is better than just using the mean or median
## to fix 

## Now! We can replace all missing weights and waists!
## BEFORE
sum(is.na(FemaleHealth_DF$WEIGHT))

## This will replace missing values
FemaleHealth_DF$WEIGHT <- 
  ifelse(is.na(FemaleHealth_DF$WEIGHT), 
         2*FemaleHealth_DF$WAIST, 
         FemaleHealth_DF$WEIGHT)

## This will fix values outside of a range
FemaleHealth_DF$WEIGHT <- 
  ifelse((FemaleHealth_DF$WEIGHT> 350 |FemaleHealth_DF$WEIGHT< 50  ), 
         2*FemaleHealth_DF$WAIST, 
         FemaleHealth_DF$WEIGHT)


## AFTER
sum(is.na(FemaleHealth_DF$WEIGHT))


FemaleHealth_DF[,c("WEIGHT", "WAIST")]


## Next - we can clean incorrect values in WAIST the same
## way. AGAIN - will this always work?  NO! There is no
## "always" in data cleaning. Cleaning is dataset and goal
## specific. These are methods (not rules)

## Check the data type of WAIST
str(FemaleHealth_DF$WAIST)
## OK! its num - that;s good.
##Let's look at the summary

summary(FemaleHealth_DF$WAIST)


## BEFORE
sum(is.na(FemaleHealth_DF$WAIST))

## This will replace missing values
FemaleHealth_DF$WAIST <- 
  ifelse(is.na(FemaleHealth_DF$WAIST), 
         1/2*FemaleHealth_DF$WEIGHT, 
         FemaleHealth_DF$WAIST)

## This will fix values outside of a range
FemaleHealth_DF$WAIST <- 
  ifelse((FemaleHealth_DF$WAIST > 127  |
            FemaleHealth_DF$WAIST < 5  ), 
         1/2*FemaleHealth_DF$WEIGHT, 
         FemaleHealth_DF$WAIST)


## AFTER
sum(is.na(FemaleHealth_DF$WAIST))


FemaleHealth_DF[,c("WEIGHT", "WAIST")]




#############################################
## Now - where are we?
##
##############################################

## Check missing values again...

sum(is.na(FemaleHealth_DF))
## We still have some....

## Let's look more closely....

lapply(FemaleHealth_DF,summary)  

### So - we can see that we still need to fix AGE....
## and then HEIGHT

####  For AGE, we can again use
## its correlation with WASIT
## to replace missing values 
## with a better estimate then say median
## Here, AGE is correlated to WAIST. 
FemaleHealth_DF
## Let's look....
Temp <- FemaleHealth_DF[,c(1,2,4)]
pairs.panels(Temp)
corr.test(Temp, method = "spearman")

## I therefore can use aome estimate for AGE
## based on WAIST. 

## However, for teaching reasons and to show other
## common methods and alternatives - I will instead 
## replace

summary(FemaleHealth_DF[,c(1,4)])

## Good! First, in both AGE and WAIST
## the mean and median are close - 
## this implies more balanced (not skewed) data
## Next, in both cases, the WAIST is about 3 times
## the AGE. True also for the min and the max. 
## Again, this is just an estimate - but a 
## pretty good one.

################ FIX AGE......................
## BEFORE
sum(is.na(FemaleHealth_DF$AGE))

## This will replace missing values
FemaleHealth_DF$AGE <- 
  ifelse(is.na(FemaleHealth_DF$AGE), 
         1/3*FemaleHealth_DF$WAIST, 
         FemaleHealth_DF$AGE)

## This will fix values outside of a range
FemaleHealth_DF$AGE <- 
  ifelse((FemaleHealth_DF$AGE > 110  |
            FemaleHealth_DF$AGE < 15  ), 
         1/3*FemaleHealth_DF$WAIST, 
         FemaleHealth_DF$AGE)


## AFTER
sum(is.na(FemaleHealth_DF$AGE))


FemaleHealth_DF[,c("AGE", "WAIST")]

## Summary AFTER we fix things
summary(FemaleHealth_DF[,c(1,4)])


#################### FIX HEIGHT ............
## Let's fix height 
## Interestingly, we can just use the median 
## here. FOr HEIGHT, the summary stats are
## very close. 
##############################################

summary(FemaleHealth_DF[,c(2)])
sd(FemaleHealth_DF$HEIGHT, na.rm=T)

## We can see that HEIGHT has 2 NAs

## Replace the NAs with the median. 

## BEFORE
sum(is.na(FemaleHealth_DF$HEIGHT))

## This will replace missing values
FemaleHealth_DF$HEIGHT <- 
  ifelse(is.na(FemaleHealth_DF$HEIGHT), 
         median(FemaleHealth_DF$HEIGHT, na.rm=T), 
         FemaleHealth_DF$HEIGHT)


## AFTER
sum(is.na(FemaleHealth_DF$HEIGHT))

## Let's look.........
lapply(FemaleHealth_DF, table)


## Looks good! But we are not done yet!
## First - we have a lot of decimals now that we do not need
## Let's changes things to ints
str(FemaleHealth_DF)

FemaleHealth_DF[,c(1,2,3,4)]<-lapply(FemaleHealth_DF[,c(1,2,3,4)], as.integer)
## Better!

str(FemaleHealth_DF)

## Let's use some vis now.....to see where we are at

(MyPlotBEFORE<-ggplot(FemaleHealth_DF, 
                      aes(x=Children, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=2)+
    ggtitle("Number of Children"))


## OK - we have an error here.
## By looking at the data, we are confident that
## viable options are No or Yes
## The "sometimes" is an error. 

## In this case, we cannot fix this easily.
## If the number of children is a label - we need to 
## remove this row because guessing a label can
## create false models.

## Let's remove this row....
## There are MANY ways to do this. 
## BEFORE is above - the vis

FemaleHealth_DF<-
  FemaleHealth_DF[(FemaleHealth_DF$Children=="Yes" | 
                     FemaleHealth_DF$Children=="No"),]

(MyPlotAFTER<-ggplot(FemaleHealth_DF, 
                     aes(x=Children, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=2)+
    ggtitle("Number of Children"))


### Good!

####################  Let's look at climate......


(Climate_BEFORE<-ggplot(FemaleHealth_DF, 
                        aes(x=Climate, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=2)+
    ggtitle("Climate"))



## OK! This vis helps a lot. 
## It helps US to SEE what needs to be cleaned
## It also helps the reader to SEE and understand
## what and why we are cleaning

## We have three issues that this vis reveals.
## kelvin, 4, and NA

## Let's fix them

## We have options here. 
## These options DEPEND ON how important Climate
## is for the analyses. 
## If climate is the core of the interest or
## something we are trying to predict - 
## we should drop these rows because there
## is no smart ways to guess. 

## However, if climate is just a variable in the 
## dataset - we can replace the values. 
## Replacing (inventing) values is not easy and WILL
## alter the information in the dataset.
## so - if this is a for human health and safety - 
## it may not be a good idea.

## Now - in looking at the vis - we can see 
## some intersting things....

## Notice "Cool". 

## None of these people have children. 
## With "cold" most do have children. 
## We could choose to "guess" and replace the 
## missing values with this (limited) info.

## So - we can replace the "4" with "Cold"
## We can replace the NA with "Hot 
## We can replace "kelvin" with "Cool"

## In doing this we do not affect the original 
## balance of the data.

## Is this perfect? NO
## SHould we always do things like this? NO
## ALL DATA and GOALS ARE DIFFERENT!

### Replace the "NA" with "Hot"

FemaleHealth_DF$Climate <- 
  ifelse(is.na(FemaleHealth_DF$Climate), 
         "Hot", 
         FemaleHealth_DF$Climate)

## Check it!


(Climate_After1<-ggplot(FemaleHealth_DF, 
                        aes(x=Climate, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=0)+
    ggtitle("Climate"))

## OK good!

## Next - replace the "4" with "Cold"
str(FemaleHealth_DF$Climate)

## These are characters - NOT numbers....
FemaleHealth_DF$Climate <- 
  ifelse((FemaleHealth_DF$Climate=="4"), 
         "Cold", 
         FemaleHealth_DF$Climate)


## Check it!
(Climate_After2<-ggplot(FemaleHealth_DF, 
                        aes(x=Climate, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=0)+
    ggtitle("Climate"))


########### Now replace "kelvin" with "Cool"


## These are characters - NOT numbers....
FemaleHealth_DF$Climate <- 
  ifelse((FemaleHealth_DF$Climate=="kelvin"), 
         "Cool", 
         FemaleHealth_DF$Climate)


## Check it!
(Climate_After2<-ggplot(FemaleHealth_DF, 
                        aes(x=Climate, fill=Children)) + 
    geom_bar()+
    geom_text(stat='count',aes(label=..count..),vjust=1)+
    ggtitle("Climate"))



##################################################
## Let's check everything now
##
##################################################
## Are ALL the data types correct?

str(FemaleHealth_DF)

## No!

## Once you are done cleaning - you must
## update all categorical variables to type FACTOR

FemaleHealth_DF

FemaleHealth_DF[c(5,6)] <- 
  lapply(FemaleHealth_DF[c(5,6)], factor)

str(FemaleHealth_DF)

## OK  - good!

## Now - double check for any missing values...

sum(is.na(FemaleHealth_DF))

## Good!

####################################################
## Outliers - 
## Here - we already took care of this 
## because we know the ranges and so replaced
## values out of range.
## BUT - if we did not - we can use vis to SEE
###################################################

colors=c("lightblue", "darkgreen", "red", "purple")
par(mfrow = c(2, 2))  # subplots 2 by 2
#names(FemaleHealth_DF)[1]

for (i in 1:4) { # Loop over loop.vector
  
  # store data 
  x <- FemaleHealth_DF[,i]
  
  # Plot histogram of x
  boxplot(x,
          main = names(FemaleHealth_DF)[i],
          xlab = names(FemaleHealth_DF)[i],
          col=colors[i]
  )
}


## Looks OK- we do have an AGE and a HEIGHT
## that are a bit outside.

## Let's look:

(AGE_BP<-ggplot(FemaleHealth_DF, aes(x="", y = AGE, label=AGE, fill=Climate))+
    geom_violin(trim=TRUE)+
    geom_jitter(position=position_jitter(.01), aes(color=Children))+
    ggtitle("AGE"))


(Weight_BP<-ggplot(FemaleHealth_DF, aes(x="", y = WEIGHT, label=WEIGHT , fill=Climate))+
    geom_boxplot()+
    geom_jitter(position=position_jitter(.01), aes(color=Children))+
    ggtitle("WEIGHT"))




####################################################
##
##      Correlations
##
######################################################
library(GGally)
ggpairs(FemaleHealth_DF, mapping=ggplot2::aes(color = Children))

ggpairs(FemaleHealth_DF[,c(1,2,5)], mapping=ggplot2::aes(color = Children))


###########################################################
##
##  Transformation and normalization
##
##########################################################

## Let's CREATE a new feature (a new variable)
## By binning (discretizing) one of the variables

## This creates a new variable that is qualitative

FemaleHealth_DF

## Let's create a new variable (feature)
## called AGEGROUP

## Let's have 5 age groups

FemaleHealth_DF$AGEGROUP<- 
  cut(FemaleHealth_DF$AGE, breaks = c(0, 18, 25, 38, 45, Inf),
      labels = c("PreCollege", "Teen", "Adult", "Mature", "Senior"))


## Check the type!
str(FemaleHealth_DF)

FemaleHealth_DF

## Now we can fill by this new qual var
(MyL1_Age_Waist<-ggplot(FemaleHealth_DF, 
                        aes(x=AGEGROUP, y=WAIST, fill=Children))+
    geom_boxplot()+
    geom_jitter(position=position_jitter(.01), aes(fill=Children))+
    ggtitle("Age, Waist, and Children"))




############################################
##
## Transformation
##
###############################################
## You can create a new variable by 
## mathematically transforming another
## or by re-mapping - etc.
###############################################
##
## Let's create a aggregate of weight and waist
## using sum. This may not make much sense - 
## but it will show you how.

#######################################
FemaleHealth_DF$WW <- 
  FemaleHealth_DF$WEIGHT + FemaleHealth_DF$WAIST

FemaleHealth_DF


#############################################
## Normalization
##
## This is a large topic. There are MANY ways
## to normalize data - such as z scores, min/max
## tf-idf, etc. 
##
## One of the most simple is min-max which
## can be used to force all numeric data to be 
## between 0 and 1.

## First - let's create a new dataframe with 
## just the numeric data:

(FemaleHealth_DF_just_numeric <- 
   FemaleHealth_DF[,c(1,2,3,4)])

## Next - to practice - let's create a function
## - our OWN function - for min-max

My_Min_Max_Function <- function(x) {
  MyMax=max(x)
  MyMin = min(x)
  Diff = MyMax - MyMin
  normVal = x/(Diff)
  return(normVal)
}

(FemaleHealth_DF_just_numeric<-
    My_Min_Max_Function(FemaleHealth_DF_just_numeric))



############################
## Write the two dataframes to csv files
##################################################
FemaleHealth_DF

write.csv(FemaleHealth_DF_just_numeric, "Female_DF_Norm_Numeric.csv")
write.csv(FemaleHealth_DF, "Female_DF.csv")