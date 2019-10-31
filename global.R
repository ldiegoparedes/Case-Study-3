library(leaflet)   # maps
library(dplyr)     # data manipulation
library(lubridate) # date Manipulation
library(ggplot2)   # graphing

library(fpc)       # Flexible Procedures for Clustering
#library(dbscan)    # Density Base Clustering
library(factoextra)# Plotting densities
library(apcluster) # Affinity Propagation Clustering

library(shiny)     # Shiny lib
library(shinyjs)   # Shiny animations
library(shinythemes)# Shiny themes
library(RColorBrewer)# Shiny lib

library(ggmap)

library(knitr)

# Code commented below to reduce time loading shiny app
#####  

# # Load the .csv files
# apr14 = read.csv("data/uber-raw-data-apr14.csv")
# may14 = read.csv("data/uber-raw-data-may14.csv")
# jun14 = read.csv("data/uber-raw-data-jun14.csv")
# jul14 = read.csv("data/uber-raw-data-jul14.csv")
# aug14 = read.csv("data/uber-raw-data-aug14.csv")
# sep14 = read.csv("data/uber-raw-data-sep14.csv")
# 
# uber14 = rbind.data.frame(apr14, may14, jun14, jul14, aug14, sep14)
#
# # Select a certain area from the map to reduce the number of points
# uber14 = filter(uber14, Lon >= -74.2 & Lon <= -73.75)
# uber14 = filter(uber14, Lat <= 40.81 & Lat >= 40.60)
# 
# # Separate or mutate the Date/Time columns
# uber14$Date.Time = mdy_hms(uber14$Date.Time)
# uber14$Year = as.numeric(year(uber14$Date.Time))
# uber14$Month = as.numeric(month(uber14$Date.Time))
# uber14$Day = as.numeric(day(uber14$Date.Time))
# uber14$Weekday = as.numeric(wday(uber14$Date.Time))
# uber14$Hour = as.numeric(hour(uber14$Date.Time))
# uber14$Minute = as.numeric(minute(uber14$Date.Time))
# uber14$Second = as.numeric(second(uber14$Date.Time))
# uber14$Month.Day = str_extract_all(as.character(uber14$Date.Time),"0\\d-\\d{2}")

#####

load("data/uber2014.RData")
load("data/NYCMap.RData")
#uber14 = uber14[1:100000,]

mi_per_lon = 53

