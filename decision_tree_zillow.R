## This code is used to create decision tree for zillow SFR and ALL data including
## sale price and inventory

library(rpart)   ## FOR Decision Trees
library(rattle)  ## FOR Decision Tree Vis
library(rpart.plot)
library(RColorBrewer)
coul <- brewer.pal(5, "Set2") 
library(randomForest)
library(reprtree)

# read data
setwd("~/Desktop/GU/ANLY501/portfolio/data")
zillow_DT_df <- read.csv("zillow_DT_df.csv",stringsAsFactors=TRUE)
str(zillow_DT_df)
head(zillow_DT_df)

##########################
### SFR or All as label ##
##########################
# remove region column
zillow_DT_df_1 <- zillow_DT_df[,-1]
# remove state
zillow_DT_df_1 <- zillow_DT_df_1[,-1]
str(zillow_DT_df_1)
head(zillow_DT_df_1)

############################################
## Split into TRAIN and TEST data
############################################

(DataSize=nrow(zillow_DT_df_1)) 
(TrainingSet_Size<-floor(DataSize*(3/4))) ## Size for training set
(TestSet_Size <- DataSize - TrainingSet_Size) ## Size for testing set

set.seed(2021)

## training sample
MyTrainSample <- sample(nrow(zillow_DT_df_1),
                         TrainingSet_Size,replace=FALSE)

MyTrainingSET <- zillow_DT_df_1[MyTrainSample,]
table(MyTrainingSET$label)

## test sample
MyTestSET <- zillow_DT_df_1[-MyTrainSample,]
table(MyTestSET$label)
# remove label
TestKnownLabels <- MyTestSET$label
MyTestSET <- MyTestSET[ , -which(names(MyTestSET) %in% c("label"))]

#################################
## Decision Trees
#################################
MyTrainingSET
str(MyTrainingSET)

## tree 1
DT <- rpart(MyTrainingSET$label ~ ., data = MyTrainingSET, method="class")
summary(DT)
# visualization
rpart.plot(DT,cex=0.7,under = TRUE,main = "Tree 1",space=0,gap=0.2)
# testing data
(DT_Prediction= predict(DT, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction,TestKnownLabels) 
barplot(DT$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 1")

## tree 2
DT2<-rpart(MyTrainingSET$label ~ ., 
           data = MyTrainingSET,method="class", 
           parms = list(split = 'information'))
summary(DT2)
rpart.plot(DT2,cex=0.7,under = TRUE,main = "Tree 2",space=0,gap=0.2)
# testing data
(DT_Prediction2= predict(DT2, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction2,TestKnownLabels) 
barplot(DT2$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 2")


## tree 3
DT3<-rpart(MyTrainingSET$label ~ X2020+X2019+X2018, 
           data = MyTrainingSET,method="class")
summary(DT3)
rpart.plot(DT3,cex=0.5,under = TRUE,main = "Tree 3",space=0,gap=0.2)
# testing data
(DT_Prediction3= predict(DT3, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction3,TestKnownLabels) 
barplot(DT3$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 3")

######################
### Region as label ##
######################

# remove region column
zillow_DT_df_2 <- zillow_DT_df[,-1]
# remove state
zillow_DT_df_2 <- zillow_DT_df_2[,-1]
colnames(zillow_DT_df_2)[4] <- "home_type"
str(zillow_DT_df_2)
head(zillow_DT_df_2)

############################################
## Split into TRAIN and TEST data
############################################

(DataSize=nrow(zillow_DT_df_2)) 
(TrainingSet_Size<-floor(DataSize*(3/4))) ## Size for training set
(TestSet_Size <- DataSize - TrainingSet_Size) ## Size for testing set

set.seed(2021)

## training sample
MyTrainSample <- sample(nrow(zillow_DT_df_2),
                        TrainingSet_Size,replace=FALSE)

MyTrainingSET <- zillow_DT_df_2[MyTrainSample,]
table(MyTrainingSET$USregion)

## test sample
MyTestSET <- zillow_DT_df_2[-MyTrainSample,]
table(MyTestSET$USregion)
# remove label
TestKnownLabels <- MyTestSET$USregion
MyTestSET <- MyTestSET[ , -which(names(MyTestSET) %in% c("USregion"))]

#################################
## Decision Trees
#################################
MyTrainingSET
str(MyTrainingSET)

## tree 1
DT <- rpart(MyTrainingSET$USregion ~ ., data = MyTrainingSET, method="class")
summary(DT)
# visualization
rpart.plot(DT,cex=0.7,under=TRUE,main = "Tree 1",space=0,gap=0.2)
# testing data
(DT_Prediction= predict(DT, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction,TestKnownLabels) 
barplot(DT$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 1")

## tree 2
DT2<-rpart(MyTrainingSET$USregion ~ ., 
           data = MyTrainingSET,method="class", 
           parms = list(split = 'information'))
summary(DT2)
rpart.plot(DT2,cex=0.7,under = TRUE,main = "Tree 2",space=0,gap=0.2)
# testing data
(DT_Prediction2= predict(DT2, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction2,TestKnownLabels) 
barplot(DT2$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 2")


## tree 3
DT3<-rpart(MyTrainingSET$USregion ~ X2020+X2019+X2018, 
           data = MyTrainingSET,method="class")
summary(DT3)
rpart.plot(DT3,cex=0.5,under = TRUE,main = "Tree 3",space=0,gap=0.2)
# testing data
(DT_Prediction3= predict(DT3, MyTestSET, type="class"))
## Confusion Matrix
table(DT_Prediction3,TestKnownLabels) 
barplot(DT3$variable.importance,col=coul,ylab="Importance",
        main = "Variable importance of Tree 3")

## Random forest
## for region 
rf <- randomForest(
  USregion ~ .,
  data=MyTrainingSET
)
## prediction
pred = predict(rf, newdata=MyTestSET[-6])

# confusion matrix
(cm = table(TestKnownLabels, pred))

# visualization

## Using ggplot heatmap to build a confusion matrix
ggplot(as.data.frame(cm), 
       aes(x=pred, y=TestKnownLabels, fill=Freq)) + 
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))

## Feature importance
imp <- data.frame(feature = row.names(rf$importance), rf$importance)
ggplot(data = imp,aes(x = reorder(feature, -MeanDecreaseGini),
                      y=MeanDecreaseGini, fill = feature))+
  geom_bar(stat="identity")+
  ggtitle("Random Forest Feature Importance") +
  xlab("Feature") + ylab("Mean Decrease Gini") 
  
  

