## This code is used to perform NB and SVM for Zillow combined dataset

library(naivebayes)
library(e1071)
library(class)
library(plotly)
library(ggplot2)
library(klaR)
library(caret)
library(kernlab)
library(RColorBrewer)

set.seed(11242021)

############
## Naive Bayes
############
re <- read.csv("zillow_NB_df.csv")
str(re)
re$USregion <- as.factor(re$USregion)
re$politics <- as.factor(re$politics)

# remove city and state columns
df <- re[,-which(names(re)%in%c("region","state","X"))]
str(df)

## make test and train data

Size <- (as.integer(nrow(df)/4))  ## Test will be 1/4 of the data
SAMPLE <- sample(nrow(df), Size, replace = FALSE)

(DF_Test_df<-df[SAMPLE, ])
(DF_Train_df<-df[-SAMPLE, ])

## testing data labels
(DF_Test_df_Labels <- DF_Test_df$USregion)
DF_Test_df_NL<-DF_Test_df[ , -2]

## Training data label
(DF_Train_df_Labels <- DF_Train_df$USregion)
DF_Train_df_NL<-DF_Train_df[ , -2]

## NAIVE BAYES with naive bayes classifier
## full model
(NB_e1071_2<-naiveBayes(DF_Train_df_NL, 
                        DF_Train_df_Labels))

NB_e1071_Pred <- predict(NB_e1071_2, DF_Test_df_NL)
#NB_e1071_2 
(cm <- table(NB_e1071_Pred,DF_Test_df_Labels))
(NB_e1071_Pred)

## confusion matrix plot
ggplot(as.data.frame(cm), 
       aes(x=NB_e1071_Pred, y=DF_Test_df_Labels)) + 
  geom_tile(aes(fill=Freq)) +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("Naive Bayes Confusion matrix")

ggsave("confusion_matrix_NB_zillow.png",width = 8, height = 6)

## check independence
pairs.panels(df)

########
## NB with only three feature
########

(DF_Test_t<-DF_Test_df[,c("ZORI","USregion","politics","Inventory")])
(DF_Train_t<-DF_Train_df[,c("ZORI","USregion","politics","Inventory")])

## testing data labels
(DF_Test_t_Labels <- DF_Test_t$USregion)
DF_Test_t_NL<-DF_Test_t[ , -2]

## Training data label
(DF_Train_t_Labels <- DF_Train_t$USregion)
DF_Train_t_NL<-DF_Train_t[ , -2]

## NAIVE BAYES with naive bayes classifier
## full model
(NB_e1071_2t<-naiveBayes(DF_Train_t_NL, 
                         DF_Train_t_Labels))

NB_e1071_Predt <- predict(NB_e1071_2t, DF_Test_t_NL)
#NB_e1071_2 
(cmt <- table(NB_e1071_Predt,DF_Test_t_Labels))
(NB_e1071_Predt)

## confusion matrix plot
ggplot(as.data.frame(cmt), 
       aes(x=NB_e1071_Predt, y=DF_Test_t_Labels)) + 
  geom_tile(aes(fill=Freq)) +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("Naive Bayes Confusion matrix")
ggsave("confusion_matrix_NB_zillow_3feature.png",width = 8, height = 6)


#######
## SVM
#######

re1 <- read.csv("zillow_SVM_df.csv")
str(re1)
re1$USregion <- as.factor(re1$USregion)

# remove city, state, and politics columns, keep only numeric data
svm_df <- re1[,-which(names(re1)%in%c("region","state","X","politics"))]
str(svm_df)

## make test and train data

Size <- (as.integer(nrow(svm_df)/4))  ## Test will be 1/4 of the data
SAMPLE <- sample(nrow(svm_df), Size, replace = FALSE)

(DF_Test_df_svm<-svm_df[SAMPLE, ])
(DF_Train_df_svm<-svm_df[-SAMPLE, ])

## testing data labels
(DF_Test_df_Labels_svm <- DF_Test_df_svm$USregion)
DF_Test_df_NL_svm<-DF_Test_df_svm[ , -2]


## SVM from e1071


## linear kernel

# find optimal cost of misclassification
BestCost <- tune(svm, USregion~., data = DF_Train_df_svm, kernel = "linear",
                 ranges = list(cost = c(0.001, 0.01, 0.1, 1, 5, 10, 100)))

(BEST_li <- BestCost$best.model)



# with best cost
SVM_fit1 <- svm(USregion~.,  data = DF_Train_df_svm, kernel = "linear", 
                scale = TRUE, type = "C",cost=BEST_li$cost)
SVM_fit1

# prediction 
SVM_Pred1 <- predict(SVM_fit1, DF_Test_df_NL_svm)

## Basic Comfusion Matrix
(cm_svm_li<-table(SVM_Pred1,DF_Test_df_Labels_svm))
str(cm_svm_li)

## Create a DF from the table to use in the heat map below...
(MyTable_DF<-as.data.frame(cm_svm_li))
str(MyTable_DF)

## Using ggplot heatmap to build a confusion matrix
ggplot(MyTable_DF, aes(x=SVM_Pred1, y=DF_Test_df_Labels_svm, fill=Freq)) + 
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("SVM with Linear Kernel and Tunned Cost")
ggsave("cm_SVM_zillow_linear_cost.png",width = 8, height = 6)


# with default cost (1)
SVM_fit1.1 <- svm(USregion~.,  data = DF_Train_df_svm, kernel = "linear", 
                scale = TRUE, type = "C",cost=BEST_li$cost)
SVM_fit1.1

# prediction 
SVM_Pred1.1 <- predict(SVM_fit1.1, DF_Test_df_NL_svm)

## Basic Comfusion Matrix
(cm_svm_li.1<-table(SVM_Pred1.1,DF_Test_df_Labels_svm))
str(cm_svm_li.1)

## Create a DF from the table to use in the heat map below...
(MyTable_DF.1<-as.data.frame(cm_svm_li.1))
str(MyTable_DF.1)

## BE CAREFUL - you need the steps above to REFORMAT
## So that you can create the heat map.

## Using ggplot heatmap to build a confusion matrix
ggplot(MyTable_DF.1, aes(x=SVM_Pred1.1, y=DF_Test_df_Labels_svm, fill=Freq)) + 
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("SVM with Linear Kernel")
ggsave("cm_SVM_zillow_linear.png",width = 8, height = 6)

## Polynomial kernel
BestCost <- tune(svm, USregion~., data = DF_Train_df_svm, kernel = "poly",
                 ranges = list(cost = c(0.001, 0.01, 0.1, 1, 5, 10, 100)))

(BEST_li <- BestCost$best.model)

SVM_fit2 <- svm(USregion~.,  data = DF_Train_df_svm, kernel = "poly", 
                scale = TRUE, type = "C",cost=BEST_li$cost)
SVM_fit2

# prediction 
SVM_Pred2 <- predict(SVM_fit2, DF_Test_df_NL_svm)

## Basic Comfusion Matrix
(cm_svm_pl<-table(SVM_Pred2,DF_Test_df_Labels_svm))
str(cm_svm_pl)

## Create a DF from the table to use in the heat map below...
(MyTable_DF<-as.data.frame(cm_svm_pl))
str(MyTable_DF)

## BE CAREFUL - you need the steps above to REFORMAT
## So that you can create the heat map.

## Using ggplot heatmap to build a confusion matrix
ggplot(MyTable_DF, aes(x=SVM_Pred2, y=DF_Test_df_Labels_svm, fill=Freq)) + 
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("SVM with Polynomial Kernel")

ggsave("cm_SVM_zillow_poly.png",width = 8, height = 6)

## radial kernel

BestCost <- tune(svm, USregion~., data = DF_Train_df_svm, kernel = "radial",
                 ranges = list(cost = c(0.001, 0.01, 0.1, 1, 5, 10, 100)))

(BEST_li <- BestCost$best.model)

SVM_fit3 <- svm(USregion~.,  data = DF_Train_df_svm, kernel = "radial", 
                scale = TRUE, type = "C",cost=BEST_li$cost)
SVM_fit3

# prediction 
SVM_Pred3 <- predict(SVM_fit3, DF_Test_df_NL_svm)

## Basic Comfusion Matrix
(cm_svm_rd<-table(SVM_Pred3,DF_Test_df_Labels_svm))
str(cm_svm_rd)

## Create a DF from the table to use in the heat map below...
(MyTable_DF<-as.data.frame(cm_svm_rd))
str(MyTable_DF)

## BE CAREFUL - you need the steps above to REFORMAT
## So that you can create the heat map.

## Using ggplot heatmap to build a confusion matrix
ggplot(MyTable_DF, aes(x=SVM_Pred3, y=DF_Test_df_Labels_svm, fill=Freq)) + 
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue")+
  geom_text(aes(label=Freq))+
  xlab("Prediction")+ylab("Observation")+
  ggtitle("SVM with Radial Kernel")

ggsave("cm_SVM_zillow_radical.png",width = 8, height = 6)
