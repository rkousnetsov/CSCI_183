# Set the working directory (to the folder containing the nyt data sets)
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 1")

# Install the ggplot2 package (for making nice graphic plots) and load it into
# the current session
install.packages("ggplot2")
library("ggplot2")

# Install the summaryBy package (for making tables of summary statistics) and load
# it into the current session
install.packages("doBy")
library("doBy")

# Define the day whose data set will be analyzed
dataSetDay <- 1

# Import nytData
nytData <- read.csv(paste0("nyt", dataSetDay, ".csv"))

# Define the day to which this data set correponds
nytData$Day <- dataSetDay

# Create age groups and partition the nytData among these age groups
nytData$Age_Group <- cut(nytData$Age, 
                         c(-Inf, 0, 18, 24, 34, 44, 54, 64, Inf), 
                         c("Unknown", "<18", "18-24", "25-34", "35-44", "45-54", "55-64", "65+"))

# Plot the distribution of impressions among the age groups
# Note, I present box plots and density plots for distribution plotting.
# Other forms of plotting may also be suitable for this task.

# Box and whisker plot, density plot
ggplot(nytData, aes(x = Age_Group, y = Impressions)) + geom_boxplot()
ggplot(nytData, aes(x = Impressions, color = Age_Group)) + geom_density()

# Plot the distributions of click through rate (CTR)
# Since CTR = # clicks / # Impressions, exclude any nytData points where
# Impressions = 0 (since this could lead to a CTR = Inf or NaN)

# Box and whisker plot, density plot
ggplot(subset(nytData, Impressions > 0), aes(x = Age_Group, y = Clicks/Impressions)) + geom_boxplot() + labs(y = "Click Through Rate")
ggplot(subset(nytData, Impressions > 0), aes(x = Clicks/Impressions, color = Age_Group)) + geom_density() + labs(x = "Click Through Rate")

# Box and whisker plot, density plot
# Using subset where Clicks > 0 (since the distribution is heavily skewed towards 0)
ggplot(subset(nytData, Clicks > 0 & Impressions > 0), aes(x = Age_Group, y = Clicks/Impressions)) + geom_boxplot() + labs(y = "Click Through Rate")
ggplot(subset(nytData, Clicks > 0 & Impressions > 0), aes(x = Clicks/Impressions, color = Age_Group)) + geom_density() + labs(x = "Click Through Rate")

# Define a collection of functions for summarizing data.
# This function include the typical statistics for central tendency (all quartiles and mean) as well 
# as count and proportion statistics.
summaryFunction <- function(x)
{
  c(Min = min(x), 
    Q1 = quantile(x, 0.25, names = FALSE),
    Median = median(x),
    Q3 = quantile(x, 0.75, names = FALSE),
    Max = max(x),
    Mean = mean(x),
    Count = length(x),
    Proportion = length(x) / nrow(nytData))
}

# Summarize age group data according to age statistics
summaryBy(Age ~ Age_Group, data = nytData, FUN = summaryFunction)

# Create a new variable based on click behavior:
# An AD blocking person (= -1) will be defined as someone who does not receive any ads.
# An AD resistant person (= 0) will be defined as someone who does not makes any clicks when presented with ads.
# An AD susceptible person (= 1) will be defined as someone who makes at least one click on an ad.
nytData$AD_Vulnerability[nytData$Impressions == 0] <- -1
nytData$AD_Vulnerability[nytData$Clicks == 0 & nytData$Impressions > 0] <- 0
nytData$AD_Vulnerability[nytData$Clicks > 0 & nytData$Impressions > 0] <- 1

# Summarize all age group data according to the means of major attributes
summaryBy(Gender + Impressions + Clicks + AD_Vulnerability ~ Day + Age_Group, data = nytData)

# Give meaningful aliases to previously defined attributes
nytData$AD_Vulnerability[nytData$Impressions == 0] <- "AD blocking"
nytData$AD_Vulnerability[nytData$Clicks == 0 & nytData$Impressions > 0] <- "AD resistant"
nytData$AD_Vulnerability[nytData$Clicks > 0 & nytData$Impressions > 0] <- "AD susceptible"
nytData$Gender[nytData$Gender == 0] <- "Female"
nytData$Gender[nytData$Gender == 1] <- "Male"

# Define counting function (with a label)
countFunction <- function(x) { c(Count = length(x)) }

# Summarize users according to the counts of all combinations of major categories
summaryBy(Day ~ Day + AD_Vulnerability + Age_Group + Gender, data = nytData, FUN = countFunction)

# Note: the user category count summaries could be shown graphically as a collection of grouped (or stacked) bar 
# graphs. I will provide an one such example:
# ggplot(nytData, aes(x = Gender, fill = AD_Vulnerability)) + geom_bar(position = "dodge")
