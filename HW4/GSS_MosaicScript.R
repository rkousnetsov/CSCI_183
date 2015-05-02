# Set working directory
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 4")

# Install and load the vcd and foreign packages
install.packages(c("vcd", "foreign"))
library("vcd")
library("foreign")

# Import the data sets, available from the following website: http://www3.norc.org/GSS+Website/Download/SPSS+Format/
data2010 <- read.spss("GSS2010.sav", to.data.frame = TRUE)
data2012 <- read.spss("GSS2012.sav", to.data.frame = TRUE)

# Merge the data sets, including only income redistribution (eqwlth) and gay marriage (marhomo) columns
# Persons on which there is no data (marhomo = IAP or NA, eqwlth = 0) are excluded
# Persons that have a neutral opinion (eqwlth = 4, marhomo = "NEITHER AGREE NOR DISAGREE) are excluded
data2010_2012 <-rbind(subset(data2010, !is.na(eqwlth) & eqwlth > 0 & eqwlth != 4 & !is.na(marhomo) & marhomo != "NEITHER AGREE NOR DISAGREE" & marhomo != "IAP", 
                             select = c("marhomo", "eqwlth")),
                      subset(data2012, !is.na(eqwlth) & eqwlth > 0 & eqwlth != 4 & !is.na(marhomo) & marhomo != "NEITHER AGREE NOR DISAGREE" & marhomo != "IAP", 
                             select = c("marhomo", "eqwlth")))

# Create new columns for future table (FAVOR or OPPOSE for the income redistribution and gay marriage columns)
data2010_2012$marriage <- NA
data2010_2012$income <- NA

# Give each person a category based on the income redistribution and gay marriage opinions
for(x in 1:nrow(data2010_2012))
{
  if(as.character(data2010_2012$marhomo[x]) == "STRONGLY DISAGREE" || as.character(data2010_2012$marhomo[x]) == "DISAGREE")
    data2010_2012$marriage[x] <- "OPPOSE"
  else
    data2010_2012$marriage[x] <- "FAVOR"
  
  if(data2010_2012$eqwlth[x] > 4)
    data2010_2012$income[x] <- "OPPOSE"
  else
    data2010_2012$income[x] <- "FAVOR"
}

# Create contingency table with labels
countTable <- table(data2010_2012$marriage, data2010_2012$income)
names(dimnames(countTable)) <- c("Gay Marriage", "Income Redistribution")

# Create table of labels for use in the mosaic plot cells
labelTable <- round(prop.table(countTable)*100)
labelTable[1] <- paste(labelTable[1], "% \n\"Liberal\"")
labelTable[2] <- paste(labelTable[2], "% \n\"Hardhat\"")
labelTable[3] <- paste(labelTable[3], "% \n\"Libertarian\"")
labelTable[4] <- paste(labelTable[4], "% \n\"Conservative\"")

# Create mosaic plot with cell labels, use the zoom feature in RStudio Plots tab to get a larger image
mosaic(countTable, pop = F, gp = gpar(fill = c("Blue", "Green", "Gold", "Red")), 
       main = "Where to find the Libertarians", sub = "Americans' views on gay marriage and income redistribution, 2010-12")
labeling_cells(text = labelTable, gp_text = gpar(fontface = "bold", col = "White"), margin = 0)(countTable)

# Note, this mosaic plot does not perfectly replicate the image (the author's image appears to be a hybrid of a mosaic/fluctuation plot and a fourfold plot)
# I do not know how to replicate such an image using only mosaic.
# Moreover, the actual data manipulations used here do not perfectly match those made by the author (the percentages of each category are slightly different).
# Imputation is avoided as this is a report of public opinion (imputation could be perceived as creating false opinions).
