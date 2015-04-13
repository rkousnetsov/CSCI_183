# Set the working directory (the folder containing all the data sets)
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 1")

# Install the summaryBy package (for making tables of summary statistics) and load
# it into the current session
install.packages("doBy")
library("doBy")

# Install the ggplot2 package (for making nice graphic plots) and load it into
# the current session
install.packages("ggplot2")
library("ggplot2")

# Define a count function (with a label)
countFunction <- function(x) { c(Count = length(x)) }

# Define master summary data frames which will contain the data collected over multiple days worth of data
masterSummaryCountDataFrame <- NULL
masterSummaryMeanDataFrame <- NULL

# Sequentially import the data sets
for(x in 1:31)
{
  nytData <- read.csv(paste0("nyt", x, ".csv"))
  
  # Create a new variable signifying the day:
  nytData$Day <- x
  
  # Create age groups and partition the nytData among these age groups
  nytData$Age_Group <- cut(nytData$Age, 
                           c(-Inf, 0, 18, 24, 34, 44, 54, 64, Inf), 
                           c("Unknown", "<18", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"))
  
  # Create a new variable based on click behavior:
  # An AD blocking person (= -1) will be defined as someone who does not receive any ads.
  # An AD resistant person (= 0) will be defined as someone who does not makes any clicks when presented with ads.
  # An AD susceptible person (= 1) will be defined as someone who makes at least one click on an ad.
  nytData$AD_Vulnerability[nytData$Impressions == 0] <- -1
  nytData$AD_Vulnerability[nytData$Clicks == 0 & nytData$Impressions > 0] <- 0
  nytData$AD_Vulnerability[nytData$Clicks > 0 & nytData$Impressions > 0] <- 1
    
  # Summarize the data according to means
  currentSummaryMeanDataFrame <- data.frame(summaryBy(Impressions + Clicks + AD_Vulnerability + Gender ~ Day + Age_Group, data = nytData))
  
  # Rename the categorical variables for the counts (since means are not used here to approximate categories)
  nytData$AD_Vulnerability[nytData$Impressions == 0] <- "AD Blocking"
  nytData$AD_Vulnerability[nytData$Clicks == 0 & nytData$Impressions > 0] <- "AD Resistant"
  nytData$AD_Vulnerability[nytData$Clicks > 0 & nytData$Impressions > 0] <- "AD Susceptible"
  nytData$Gender[nytData$Gender == 0] <- "Female"
  nytData$Gender[nytData$Gender == 1] <- "Male"
  
  # Summarize the data according to counts
  currentSummaryCountDataFrame <- data.frame(summaryBy(Day ~ Day + Age_Group + Gender + AD_Vulnerability, data = nytData, FUN = countFunction))
  
  # Add the current summary data frames to the correponding master summary data frames
  masterSummaryMeanDataFrame <- rbind(masterSummaryMeanDataFrame, currentSummaryMeanDataFrame)
  masterSummaryCountDataFrame <- rbind(masterSummaryCountDataFrame, currentSummaryCountDataFrame)
}

# Plot AD_Vulnerability.mean over time
ggplot(masterSummaryMeanDataFrame, aes(x = Day, y = AD_Vulnerability.mean, color = Age_Group)) + geom_line()

# Plot clicks.mean over time
ggplot(masterSummaryMeanDataFrame, aes(x = Day, y = Clicks.mean, color = Age_Group)) + geom_line()

# Plot Gender.mean over time
ggplot(masterSummaryMeanDataFrame, aes(x = Day, y = Gender.mean, color = Age_Group)) + geom_line()
