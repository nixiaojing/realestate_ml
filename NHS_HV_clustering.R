########################################
### This session describe how NHS and HV combined data clustered based on region 
### (SO for South, MW for Midwest, NE for Northeast, and WE for West).
########################################

setwd("~/Desktop/GU/ANLY501/portfolio/data/")

## install.packages("plotly","rgl","xtable","manipulateWidget")
set.seed(20211012)
library(cluster)
library(plotly)
library(rgl)
library(htmlwidgets)
library(factoextra)
library(tidyr)
library(philentropy)
library(amap)
library(pheatmap)
library(RColorBrewer)

## Read data

cluster_df <- read.csv(file = 'NHS_HV_cluster_df.csv')
str(cluster_df)
head(cluster_df)

## Save labels and convert them to 1,2,3,4

(data_class <- lapply(cluster_df[1],as.numeric))

## standarize the columns other than label column
cluster_df[,-1] <- scale(cluster_df[,-1])

##################
## Plot 3D plot 
#################
### ASOLD OCC HOR
fig1 <- plot_ly(cluster_df, x = ~ASOLD, y = ~OCC, z = ~HOR, 
                color = ~label, colors = c('#BF382A', '#0C4B8E'))
fig1 <- fig1 %>% add_markers()
fig1 <- fig1 %>% layout(scene = list(xaxis = list(title = 'ASOLD'),
                                     yaxis = list(title = 'OCC'),
                                     zaxis = list(title = 'HOR')))

fig1
saveWidget(fig1, "kmean_3d_cluster.html", selfcontained = F, 
           libdir = "lib_kmean3d")


### OWNOCC OFFMAR SOLD

fig2 <- plot_ly(cluster_df, x = ~OWNOCC, y = ~OFFMAR, z = ~SOLD, 
                color = ~label, colors = c('#BF382A', '#0C4B8E'))
fig2 <- fig2 %>% add_markers()
fig2 <- fig2 %>% layout(scene = list(xaxis = list(title = 'OWNOCC'),
                                     yaxis = list(title = 'OFFMAR'),
                                     zaxis = list(title = 'SOLD')))

fig2
saveWidget(fig2, "kmean_3d_cluster2.html", selfcontained = F, 
           libdir = "lib_kmean3d2")

#######################
## k mean clustering ##
#######################

cluster_matrx <- as.matrix(cluster_df[,-1])
row.names(cluster_matrx) <- cluster_df[,1]

## change row name to unique but can reflect correct classification
n <- 1:104
row.names(cluster_matrx) <- paste0(cluster_df[,1],"_",n)


png(file="~/Desktop/GU/ANLY501/portfolio/figure/euc_explor_NHSHV.png",
    width=800, height=800)
euc_distance <- get_dist(cluster_matrx)
fviz_dist(edu_distance, gradient = list(low = "#00AFBB", mid = "white", 
                                    high = "#FC4E07"))
dev.off()

######
## Euclidean distance
######

png(file="~/Desktop/GU/ANLY501/portfolio/figure/heatmap_explor_NHSHV.png",
    width=800, height=800)
heatmap(cluster_matrx,Colv = NA)
dev.off()

## k = 2
km2_e <- kmeans(cluster_matrx, 2, iter.max = 10, nstart = 1,trace=FALSE)
print(km2_e$cluster)

## k = 3
km3_e <- kmeans(cluster_matrx, 3, iter.max = 10, nstart = 1,trace=FALSE)
print(km3_e$cluster)

## k = 4
km4_e <- kmeans(cluster_matrx, 4, iter.max = 10, nstart = 1,trace=FALSE)
print(km4_e$cluster)

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k2_e.png",
    width=500, height=500)
fviz_cluster(km2_e, cluster_matrx, ellipse.type = "norm", main = "Euclidean distance, k=2")
dev.off()

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k3_e.png",
    width=500, height=500)
fviz_cluster(km3_e, cluster_matrx, ellipse.type = "norm", main = "Euclidean distance, k=3")
dev.off()

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k4_e.png",
    width=500, height=500)
fviz_cluster(km4_e, cluster_matrx, ellipse.type = "norm", main = "Euclidean distance, k=4")
dev.off()





######
#### Manhattan distance
######

## k = 2
km2_m <- Kmeans(cluster_matrx, 2, iter.max = 10, nstart = 1,method="manhattan")
print(km2_m$cluster)

## k = 3
km3_m <- Kmeans(cluster_matrx, 3, iter.max = 10, nstart = 1,method="manhattan")
print(km3_e$cluster)

## k = 4
km4_m <- Kmeans(cluster_matrx, 4, iter.max = 10, nstart = 1,method="manhattan")
print(km4_m$cluster)

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k2_m.png",
    width=500, height=500)
fviz_cluster(km2_m, cluster_matrx, ellipse.type = "norm", main = "Manhattan distance, k=2")
dev.off()

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k3_m.png",
    width=500, height=500)
fviz_cluster(km3_m, cluster_matrx, ellipse.type = "norm", main = "Manhattan distance, k=3")
dev.off()

png(file="~/Desktop/GU/ANLY501/portfolio/figure/k4_m.png",
    width=500, height=500)
fviz_cluster(km4_m, cluster_matrx, ellipse.type = "norm", main = "Manhattan distance, k=4")
dev.off()



#############################################################3
## Elbow, Silhouette and Gap statistic - choosing k

(Elbow <- fviz_nbclust(
  as.matrix(cluster_df[,-1]), 
  kmeans, 
  k.max = 10,
  method = "wss",
))

(silh <- fviz_nbclust(
  as.matrix(cluster_df[,-1]), 
  kmeans, 
  k.max = 10,
  method = "silhouette",
))

(gap_sta <- fviz_nbclust(
  as.matrix(cluster_df[,-1]), 
  kmeans, 
  k.max = 10,
  method = "gap_stat",
))


### whether clustering correct?




#############################
## Hierarchical clustering ##
#############################
library(ggdendro)
library(dendextend)

######
#### Euclidean distance
######

### using k = 2 in hcut clustering

hc_k2 <- hclust(dist(cluster_matrx), "ave")
hc_k2$labels <- cluster_df$label
groups <- cutree(hc_k2, k = 4)

### 5 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k5_Euclidean.png",
    width=812, height=493)
plot(hc_k2,font.axis=2, cex = 0.6, main = "Euclidean, k=5")
rect.hclust(hc_k2, k = 5, border = c("red","blue","green","black"))
text(90,6,"SO: South")
text(90,5.5,"MW: Midwest")
text(90,5,"NE: Northeast")
text(90,4.5,"WE: West")

dev.off()

### 4 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k4_Euclidean.png",
    width=812, height=493)
plot(hc_k2,font.axis=2, cex = 0.6, main = "Euclidean, k=4")
rect.hclust(hc_k2, k = 4, border = c("red","blue","green","black"))
text(90,6,"SO: South")
text(90,5.5,"MW: Midwest")
text(90,5,"NE: Northeast")
text(90,4.5,"WE: West")
dev.off()

### 3 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k3_Euclidean.png",
    width=812, height=493)
plot(hc_k2,font.axis=2, cex = 0.6, main = "Euclidean, k=3")
rect.hclust(hc_k2, k = 3, border = c("red","blue","green","black"))
text(90,6,"SO: South")
text(90,5.5,"MW: Midwest")
text(90,5,"NE: Northeast")
text(90,4.5,"WE: West")
dev.off()

### 2 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k2_Euclidean.png",
    width=812, height=493)
plot(hc_k2,font.axis=2, cex = 0.6, main = "Euclidean, k=2")
rect.hclust(hc_k2, k = 2, border = c("red","blue","green","black"))
text(90,6,"SO: South")
text(90,5.5,"MW: Midwest")
text(90,5,"NE: Northeast")
text(90,4.5,"WE: West")
dev.off()

######
#### Manhattan distance
######

### using k = 2 in hcut clustering

hc_k2_m <- hclust(dist(cluster_matrx,method = "manhattan"), "ave")
hc_k2_m$labels <- cluster_df$label



### 5 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k5_manhattan.png",
    width=812, height=493)
plot(hc_k2_m,font.axis=2, cex = 0.5, main = "Manhattan, k=5")
rect.hclust(hc_k2_m, k = 5, border = c("red","blue","green","black"))
text(95,16,"SO: South")
text(95,15,"MW: Midwest")
text(95,14,"NE: Northeast")
text(95,13,"WE: West")
dev.off()

### 4 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k4_manhattan.png",
    width=812, height=493)
plot(hc_k2_m,font.axis=2, cex = 0.5, main = "Manhattan, k=4")
rect.hclust(hc_k2_m, k = 4, border = c("red","blue","green","black"))
text(95,16,"SO: South")
text(95,15,"MW: Midwest")
text(95,14,"NE: Northeast")
text(95,13,"WE: West")
dev.off()

### 3 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k3_manhattan.png",
    width=812, height=493)
plot(hc_k2_m,font.axis=2, cex = 0.5, main = "Manhattan, k=3")
rect.hclust(hc_k2_m, k = 3, border = c("red","blue","green","black"))
text(95,16,"SO: South")
text(95,15,"MW: Midwest")
text(95,14,"NE: Northeast")
text(95,13,"WE: West")
dev.off()

### 2 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k2_manhattan.png",
    width=812, height=493)
plot(hc_k2_m,font.axis=2, cex = 0.5, main = "Manhattan, k=2")
rect.hclust(hc_k2_m, k = 2, border = c("red","blue","green","black"))
text(95,16,"SO: South")
text(95,15,"MW: Midwest")
text(95,14,"NE: Northeast")
text(95,13,"WE: West")
dev.off()

######
#### Canberra distance
######

### using k = 2 in hcut clustering

hc_k2_can <- hclust(dist(cluster_matrx,method = "canberra"), "ave")
hc_k2_can$labels <- cluster_df$label


### 5 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k5_can.png",
    width=812, height=493)
plot(hc_k2_can,font.axis=2, cex = 0.5, main = "Canberra, k=5")
rect.hclust(hc_k2_can, k = 5, border = c("red","blue","green","black"))
text(95,7,"SO: South")
text(95,6.5,"MW: Midwest")
text(95,6,"NE: Northeast")
text(95,5.5,"WE: West")
dev.off()

### 4 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k4_can.png",
    width=812, height=493)
plot(hc_k2_can,font.axis=2, cex = 0.5, main = "Canberra, k=4")
rect.hclust(hc_k2_can, k = 4, border = c("red","blue","green","black"))
text(95,7,"SO: South")
text(95,6.5,"MW: Midwest")
text(95,6,"NE: Northeast")
text(95,5.5,"WE: West")
dev.off()

### 3 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k3_can.png",
    width=812, height=493)
plot(hc_k2_can,font.axis=2, cex = 0.5, main = "Canberra, k=3")
rect.hclust(hc_k2_can, k = 3, border = c("red","blue","green","black"))
text(95,7,"SO: South")
text(95,6.5,"MW: Midwest")
text(95,6,"NE: Northeast")
text(95,5.5,"WE: West")
dev.off()

### 2 cluster dendrogram
png(file="~/Desktop/GU/ANLY501/portfolio/figure/dendro_k2_can.png",
    width=812, height=493)
plot(hc_k2_can,font.axis=2, cex = 0.5, main = "Canberra, k=2")
rect.hclust(hc_k2_can, k = 2, border = c("red","blue","green","black"))
text(95,7,"SO: South")
text(95,6.5,"MW: Midwest")
text(95,6,"NE: Northeast")
text(95,5.5,"WE: West")
dev.off()

# Optimal cluster numbers using silh, elbow, gap in hierarchical clustering
(WSS <- fviz_nbclust(cluster_df[,-1], FUN = hcut, method = "wss", 
                    k.max = 6) +
  ggtitle("WSS:Elbow"))
(SIL <- fviz_nbclust(cluster_df[,-1], FUN = hcut, method = "silhouette", 
                    k.max = 6) +
  ggtitle("Silhouette"))
(GAP <- fviz_nbclust(cluster_df[,-1], FUN = hcut, method = "gap_stat", 
                    k.max = 6) +
  ggtitle("Gap Stat"))


#################
### Predict
#################

#####
## get three vector from NHS-HV data
#####

(pred <- read.csv(file = "pred_clust.csv"))
## scale
pred[,-1] <- scale(pred[,-1])
pred
##################
## Plot 3D plot -- where are the prediction points
#################
### ASOLD OCC HOR
library(class)


fig3 <- plot_ly()
fig3 <- fig3 %>% add_markers(data=cluster_df,  x = ~ASOLD, y = ~OCC, z = ~HOR, 
                color = ~label, colors = c('#BF382A', '#0C4B8E')) 
fig3 <- fig3 %>% add_markers(data=pred, 
                             name=c("MW predict", "NE predict","SO predict"), 
                             x = ~ASOLD, y = ~OCC, z = ~HOR, 
              symbols = 'x')
fig3 <- fig3 %>% layout(scene = list(xaxis = list(title = 'ASOLD'),
                                    yaxis = list(title = 'OCC'),
                                    zaxis = list(title = 'HOR')))

fig3
saveWidget(fig3, "kmean_3d_cluster_pred.html", selfcontained = F, 
           libdir = "lib_kmean3d_pred")

##################
## Predict using knn
#################
hc <- hclust(dist(cluster_matrx), "ave")
hc$labels <- cluster_df$label
groups <- cutree(hc, k = 4)
knnClust <- knn(train = cluster_df[,-1], test = pred[,-1] , k = 1, cl = groups)
knnClust

## MW, NE,SO





