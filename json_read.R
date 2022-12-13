## read and save json file

library("rjson")
library("rlist" )
setwd("~/Desktop/GU/ANLY501/portfolio/data")

##### COVID time series data
NY_time_series_covid <- fromJSON(file = "county_time_series_NY.json")

# Convert JSON file to a data frame.
### county info
for(l in length(NY_time_series_covid)){
  df <- data.frame(NY_time_series_covid_NY_time_series_covid[[l]]$fips,
                   NY_time_series_covid_NY_time_series_covid[[l]]$population)
}


NY_time_series_covid <- as.data.frame(NY_time_series_covid$metrics)
### 
for(l in length(NY_time_series_covid)){
  filename <- cat("NY_time_series_covid_",NY_time_series_covid[[l]]$fips,".csv",sep='')
  df <- as.data.frame(NY_time_series_covid[[l]]$metricsTimeseries[1:327])
  write.csv(df,filename)
}

NY_time_series_covid[[l]]$metricsTimeseries

#### Housing Vacancies and Homeownership data, national

HV_1990_2021<-fromJSON(file = "HV_1990_2021.json")
HV_1990_2021 <- as.data.frame(HV_1990_2021)
## transpose HV_1990_2021 and convert to data frame
HV_1990_2021 <- as.data.frame(t(as.matrix(HV_1990_2021)))





