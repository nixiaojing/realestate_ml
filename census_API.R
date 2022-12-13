################################################################
## For key safety, personal API key is not shown in this code ##
################################################################

## U.S. Census API
## For available API: https://www.census.gov/data/developers/data-sets.html 
## Economic Indicators (Time Series: various years - present):
## https://www.census.gov/data/developers/data-sets/economic-indicators.html
## Register: https://api.census.gov/data/key_signup.html
## Documentation: https://www2.census.gov/data/api-documentation/EITS_API_User_Guide_Dec2020.pdf


## Get the data from "Housing Vacancies and Homeownership" dataset and "New Homes Sales" dataset
## BUILD THE URL
library("httr")
library("jsonlite")

baseHV <- "https://api.census.gov/data/timeseries/eits/hv"
baseNHS<- "https://api.census.gov/data/timeseries/eits/ressales"

get<-"cell_value,time_slot_id,error_data,category_code,geo_level_code&seasonally_adj&data_type_code"
from = "1990"
to = "2021"
filename="census_api_key.txt"
(API_KEY<-read.csv(filename, header=TRUE, sep=","))
(API_KEY <- as.vector(API_KEY$key))


callHV <- paste(baseHV,"?",
               "get", "=", get, "&",
               "time", "=", "from+",from,"to+",to, "&",
               "key", "=", API_KEY,sep = "")

(callHV)

callNHS <- paste(baseNHS,"?",
                "get", "=", get, "&",
                "time", "=", "from+",from,"to+",to, "&",
                "key", "=", API_KEY,sep = "")

(callNHS)

HV_Call<-httr::GET(callHV) ## explicit call httr::GET()
(HV_Call)
NHS_Call<-httr::GET(callNHS) ## explicit call httr::GET()
(NHS_Call)

(MYDF<-httr::content(HV_Call,encoding = "UTF-8"))
(MYDF1<-httr::content(NHS_Call,encoding = "UTF-8"))
## Print to a file
HVname = "HV_1990_2021.json"
NHSname = "NHS_1990_2021.json"
exportJSON <- toJSON(MYDF, force = TRUE)
exportJSON1 <- toJSON(MYDF1, force = TRUE)
## Write json to file
write(exportJSON,"HV_1990_2021.json")
write(exportJSON1,"NHS_1990_2021.json")
