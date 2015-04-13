# Set working directory (to folder containing the BikeTheft.csv)
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/In-class exercises")

# Import data set
bikeData <- read.csv("BikeTheft.csv")

# Find location with most thefts
table(bikeData$LOCATION)[which.max(table(bikeData$LOCATION))]

# Install lubridate package
install.packages("lubridate")

# Load the package into the session
library("lubridate")

# Find day of week with most thefts
bikeData$DAY <- wday(as.Date(bikeData$DATE, "%m/%d/%Y"), label = TRUE)
table(bikeData$DAY)[which.max(table(bikeData$DAY))]

# Find month with most thefts
bikeData$MONTH <- month(as.Date(bikeData$DATE, "%m/%d/%Y"), label = TRUE)
table(bikeData$MONTH)[which.max(table(bikeData$MONTH))]
