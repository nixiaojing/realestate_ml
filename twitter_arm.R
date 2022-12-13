### This session contains code used to produce twitter 
### association rule mining analysis
### Code is revised from Dr.Gates arm code

setwd("~/Desktop/GU/ANLY501/portfolio/data")

library(arules)
library(networkD3)
library(igraph)
library(visNetwork)
library(arulesViz)



TweetTrans <- read.transactions("UpdatedTweetFile.csv", sep =",", 
                                format("basket"),  rm.duplicates = TRUE)

############ Create the Rules  - Relationships ###########
TweetTrans_rules = arules::apriori(TweetTrans, 
                                   parameter = list(support=.04, conf=0.8, minlen=2))

inspect(TweetTrans_rules[1:15])
##  SOrt by Conf
SortedRules_conf <- sort(TweetTrans_rules, by="confidence", decreasing=TRUE)
inspect(SortedRules_conf[1:15])
## Sort by Sup
SortedRules_sup <- sort(TweetTrans_rules, by="support", decreasing=TRUE)
inspect(SortedRules_sup[1:15])
## Sort by Lift
SortedRules_lift <- sort(TweetTrans_rules, by="lift", decreasing=TRUE)
inspect(SortedRules_lift[1:15])


##################################################
## Using arulesViz to view overall results ##
##################################################
## plot first 30 support rules

p <- plot(SortedRules_sup[1:30],method="graph",engine='html', shading="confidence")

htmlwidgets::saveWidget(p, "aruleViz.html", selfcontained = FALSE)


#######################################################
########  Using NetworkD3 To View SUP Results   #######
#######################################################

## Build node and egdes properly formatted data files
## Build the edgeList which will have SourceName, TargetName
##                                    Weight, SourceID, and
##                                    TargetID

#Rules_DF<-as(TweetTrans_rules, "data.frame")
#(head(Rules_DF))

## Convert the RULES to a DATAFRAME
Rules_DF2<-DATAFRAME(TweetTrans_rules, separate = TRUE)
(head(Rules_DF2))
str(Rules_DF2)
## Convert to char
Rules_DF2$LHS<-as.character(Rules_DF2$LHS)
Rules_DF2$RHS<-as.character(Rules_DF2$RHS)

## Remove all {}
Rules_DF2[] <- lapply(Rules_DF2, gsub, pattern='[{]', replacement='')
Rules_DF2[] <- lapply(Rules_DF2, gsub, pattern='[}]', replacement='')

Rules_DF2

#########################
###### Do for SUP #######
#########################

## USING SUP
Rules_S<-Rules_DF2[c(1,2,3)]
names(Rules_S) <- c("SourceName", "TargetName", "Weight")
head(Rules_S,30)

## CHoose and set
Rules_Sup<-Rules_S

## to get better visualization, only use first 30 rules
Rules_Sup <- Rules_Sup[order(-as.numeric(Rules_Sup$Weight)),]
(Rules_Sup <- Rules_Sup[1:30,])
###########################################################################
#############       Build a NetworkD3 edgeList and nodeList    ############
###########################################################################

#edgeList<-Rules_Sup
# Create a graph. Use simplyfy to ensure that there are no duplicated edges or self loops
#MyGraph <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=TRUE))
#plot(MyGraph)

############################### BUILD THE NODES & EDGES ####################################
(edgeList<-Rules_Sup)
(MyGraph <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=TRUE)))

nodeList <- data.frame(ID = c(0:(igraph::vcount(MyGraph) - 1)), 
                       # because networkD3 library requires IDs to start at 0
                       nName = igraph::V(MyGraph)$name)
## Node Degree
(nodeList <- cbind(nodeList, nodeDegree=igraph::degree(MyGraph, 
                                                       v = igraph::V(MyGraph), mode = "all")))

## Betweenness
BetweenNess <- igraph::betweenness(MyGraph, 
                                   v = igraph::V(MyGraph), 
                                   directed = TRUE) 

(nodeList <- cbind(nodeList, nodeBetweenness=BetweenNess))

## This can change the BetweenNess value if needed
#BetweenNess<-BetweenNess/100



## For scaling...divide by 
## RE:https://en.wikipedia.org/wiki/Betweenness_centrality
##/ ((igraph::vcount(MyGraph) - 1) * (igraph::vcount(MyGraph)-2))
## For undirected / 2)
## Min-Max Normalization
##BetweenNess.norm <- (BetweenNess - min(BetweenNess))/(max(BetweenNess) - min(BetweenNess))


## Node Degree


###################################################################################
########## BUILD THE EDGES #####################################################
#############################################################
# Recall that ... 
# edgeList<-Rules_Sup
getNodeID <- function(x){
  which(x == igraph::V(MyGraph)$name) - 1  #IDs start at 0
}

edgeList <- plyr::ddply(
  Rules_Sup, .variables = c("SourceName", "TargetName" , "Weight"), 
  function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                          TargetID = getNodeID(x$TargetName)))

head(edgeList)
nrow(edgeList)

########################################################################
##############  Dice Sim ################################################
###########################################################################
#Calculate Dice similarities between all pairs of nodes
#The Dice similarity coefficient of two vertices is twice 
#the number of common neighbors divided by the sum of the degrees 
#of the vertices. Method dice calculates the pairwise Dice similarities 
#for some (or all) of the vertices. 
DiceSim <- igraph::similarity.dice(MyGraph, vids = igraph::V(MyGraph), mode = "all")
head(DiceSim)

#Create  data frame that contains the Dice similarity between any two vertices
F1 <- function(x) {data.frame(diceSim = DiceSim[x$SourceID +1, x$TargetID + 1])}
#Place a new column in edgeList with the Dice Sim
head(edgeList)
edgeList <- plyr::ddply(edgeList,
                        .variables=c("SourceName", "TargetName", "Weight", 
                                     "SourceID", "TargetID"), 
                        function(x) data.frame(F1(x)))
head(edgeList)

##################################################################################
##################   color #################################################
######################################################
# COLOR_P <- colorRampPalette(c("#00FF00", "#FF0000"), 
#                             bias = nrow(edgeList), space = "rgb", 
#                             interpolate = "linear")
# COLOR_P
# (colCodes <- COLOR_P(length(unique(edgeList$diceSim))))
# edges_col <- sapply(edgeList$diceSim, 
#                     function(x) colCodes[which(sort(unique(edgeList$diceSim)) == x)])
# nrow(edges_col)

## NetworkD3 Object
#https://www.rdocumentation.org/packages/networkD3/versions/0.4/topics/forceNetwork

D3_network_Tweets <- networkD3::forceNetwork(
  Links = edgeList, # data frame that contains info about edges
  Nodes = nodeList, # data frame that contains info about nodes
  Source = "SourceID", # ID of source node 
  Target = "TargetID", # ID of target node
  Value = "Weight", # value from the edge list (data frame) that will be used to value/weight relationship amongst nodes
  NodeID = "nName", # value from the node list (data frame) that contains node description we want to use (e.g., node name)
  Nodesize = "nodeBetweenness",  # value from the node list (data frame) that contains value we want to use for a node size
  Group = "nodeDegree",  # value from the node list (data frame) that contains value we want to use for node color
  height = 400, # Size of the plot (vertical)
  width = 600,  # Size of the plot (horizontal)
  fontSize = 10, # Font size
  linkDistance = networkD3::JS("function(d) { return d.value*1000; }"), # Function to determine distance between any two nodes, uses variables already defined in forceNetwork function (not variables from a data frame)
  linkWidth = networkD3::JS("function(d) { return d.value*5; }"),# Function to determine link/edge thickness, uses variables already defined in forceNetwork function (not variables from a data frame)
  opacity = 5, # opacity
  zoom = TRUE, # ability to zoom when click on the node
  opacityNoHover = 5, # opacity of labels when static
  linkColour = "red"   ###"edges_col"red"# edge colors
) 

# Plot network
D3_network_Tweets

# Save network as html file
networkD3::saveNetwork(D3_network_Tweets, 
                       "twitter_HB_networkd3.html", 
                       
                       selfcontained = TRUE)



#######################################
## Using igraph To View Lift Results ##
#######################################

## Other options for the following
#Rules_Lift<-Rules_DF2[c(1,2,6)]
#Rules_Conf<-Rules_DF2[c(1,2,4)]
#names(Rules_Lift) <- c("SourceName", "TargetName", "Weight")
#names(Rules_Conf) <- c("SourceName", "TargetName", "Weight")
#head(Rules_Lift)
#head(Rules_Conf)

## Using Lift
Rules_Lift<-Rules_DF2[c(1,2,6)]
names(Rules_Lift) <- c("SourceName", "TargetName", "Weight")
Rules_Lift$Weight <- as.numeric(Rules_Lift$Weight)
head(Rules_Lift)

## to get better visualization, only use first 30 rules
Rules_Lift <- Rules_Lift[order(-Rules_Lift$Weight),]
(Rules_Lift <- Rules_Lift[1:30,])

## preparing input edge and node input for igraph from Rules_Lift
(edgeList<-Rules_Lift)
(MyGraph <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=TRUE)))

edgeList <- plyr::ddply(
  Rules_Lift, .variables = c("SourceName", "TargetName" , "Weight"), 
  function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                          TargetID = getNodeID(x$TargetName)))

head(edgeList)
nrow(edgeList)

nodeList <- data.frame(ID = c(0:(igraph::vcount(MyGraph) - 1)), 
                       nName = igraph::V(MyGraph)$name)
## Node Degree
(nodeList <- cbind(nodeList, nodeDegree=igraph::degree(MyGraph, 
                                                       v = igraph::V(MyGraph), mode = "all")))


Myedges <- data.frame(as.integer(edgeList$SourceID),
                      as.integer(edgeList$TargetID),
                      edgeList$Weight)
colnames(Myedges) <- c("from","to","weight")
Myedges

Mynodes <- data.frame(as.integer(nodeList$ID),nodeList$nName)
colnames(Mynodes) <- c("id","label")
Mynodes

### igraph

(My_igraph2 <- 
    graph_from_data_frame(d = Myedges, vertices = Mynodes, directed = TRUE))

E(My_igraph2)
E(My_igraph2)$weight

V(My_igraph2)$size = 10

(E_Weight<-as.integer(Myedges[,"weight"]))
(E(My_igraph2)$weight <- edge.betweenness(My_igraph2))
E(My_igraph2)$color <- "blue"

layout1 <- layout.fruchterman.reingold(My_igraph2)

## plot or tkplot........
tkplot(My_igraph2, 
       vertex.label.cex=1,
       vertex.color="lightblue",
       layout=layout1,
       edge.arrow.size=.7,
       vertex.label.cex=0.8, 
       vertex.label.dist=2, 
       edge.curved=0.2,
       vertex.label.color="black",
       edge.weight=5, 
       edge.width=as.numeric(E(My_igraph2)$weight),
       #edge_density(My_igraph2)
       ## Affect edge lengths
       rescale = FALSE, 
       ylim=c(0,14),
       xlim=c(0,20)
)

