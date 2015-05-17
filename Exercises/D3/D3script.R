# Set working directory (to folder containing the BikeTheft.csv)
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/In-class Exercises/D3")

# install.packages(pacman)
pacman::p_load(lubridate, choroplethr, acs)

# Import data set
bikeData <- read.csv("BikeTheft.csv")

# Remove NA row and rows with multiple dates
bikeData <- bikeData[!is.na(bikeData$CASE), ]
bikeData <- bikeData[grep("-", bikeData$DATE, invert = TRUE), ]

# Get the general location of each theft (this list is not exhaustive, any non-matching elements are assigned "Other")
locations <- c("Bannan", "Benson", "Campisi", "Casa", "Daly", "Dunne", "Engineering", "Graham", "Heafey", "Locatelli", 
               "Malley", "Nobili", "O'Connor", "Sanfilippo", "Sobrato", "Swig", "Villas", "Walsh")
bikeData$location <- NA
for(x in locations)
{
  bikeData[grep(x, bikeData$LOCATION),]$location <- x
}
bikeData[is.na(bikeData$location),]$location <- "Other"

# Get the year-month of each theft
bikeData$yearMonth <- format(as.Date(bikeData$DATE, "%m/%d/%Y"), format = "%Y-%m")

# Create a table of thefts per location, per month
# Can use bikeData$LOCATION if desired (this will use the original location categories)
temp <- table(bikeData$location, bikeData$yearMonth)

# write to .tsv file
write.table(temp, file = "thefts.tsv", sep = "\t", col.names = NA)

# Manually delete the row of 0's (if there is one) and replace the "" label before the row of year-month with "name"

# ------------------------------------------------------------------------------------

# Register key
api.key.install(key = "b44899120bef244134a214226f84c72be9415152")

# Get number of people taking a bike (or taxi/motorcycle) to work in each county:
temp <- data.frame(get_acs_data("B08101", "county",column_idx = 41))

# Modify the data frame so that it matches the format of unemployment2.tsv
temp$title <- NULL
colnames(temp) <- c("id", "rate")

quantile(temp$rate, 0.9) # Use this as the upper limit on the domain in the html file

# Write to .tsv file
write.table(temp, file = "transport.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
