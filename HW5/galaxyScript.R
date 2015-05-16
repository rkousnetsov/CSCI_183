# Set working directory to folder containing images
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/In-class Exercises/images_training_rev1")

# Load all relevant packages
## install.packages("pacman")
pacman::p_load(ripa, jpeg, EBImage, caret, bigmemory, gbm)

# Read in images list. 
images <- list.files()

# Read in training set and add additional columns for future features to training set.
galaxyProb <- read.csv("../galaxy_train.csv")

#imageMatrix  <- big.matrix(nrow = length(images), ncol = 2500)
#for(x in 1:length(images))
#{
#  imageMatrix[x, ] <- as.vector(resize(rgb2grey(readJPEG(images[x])), 50, 50))
#}
#write.big.matrix(imageMatrix, file = "../Images.csv")
imageMatrix <- read.big.matrix("../Images.csv")

# Calculate the ratio of bright pixels in the outer shell versus the inner shell (left and right denote boundaries of inner shell)
# Bright pixels can be defined based on a quantile (third quantile)
shellRatioByQuantile <- function(x, left, right)
{
  temp <- matrix(imageMatrix[x, ], nrow = 50, ncol = 50)
  countInner <- 0
  magicNumber <- quantile(temp, 0.75)
  for(x in left:right)
  {
    for(y in left:right)
    {
      if(temp[x, y] >= magicNumber)
          countInner <- countInner + 1
    }
  }
  return ((625 - countInner)/countInner)
}

shellRatioByMean <- function(x, left, right)
{
  temp <- matrix(imageMatrix[x, ], nrow = 50, ncol = 50)
  innerSum <- sum(temp[left:right, left:right])
  outerSum <- sum(temp) - innerSum
  innerMean <- innerSum/(left*right)
  outerMean <- outerSum/(2500 - left*right)
  return (outerMean/innerMean)
}

# Create data frame to house features
# Empty vectors are used to initialize each column
df <- data.frame(GalaxyID = integer(length(images)), Prob_Smooth = double(length(images)), ShellMean = double(length(images)), ShellQuantile = double(length(images)))

# Loop over all images and calculate features
for(z in 1:length(images))
{
  GalaxyID <- gsub(".jpg", "", images[z])
  row <- galaxyProb[galaxyProb$GalaxyID == GalaxyID, ]
  
  df$GalaxyID[z] <- GalaxyID
  df$Prob_Smooth[z] <- ifelse(nrow(row) == 1, row$Prob_Smooth, NA)
  df$ShellMean[z] <- shellRatioByMean(z, 15, 36)
  df$ShellQuantile[z] <- shellRatioByQuantile(z, 15, 36)
}

# Extract train and test sets
trainMap <- subset(df, !is.na(Prob_Smooth))
testMap <- subset(df, is.na(Prob_Smooth))

# Create glm fit on CV1 and use it to make prediction on CV2
modelFit <- train(Prob_Smooth ~ ShellMean + ShellQuantile, data = trainMap, method = "gbm")
prediction <- predict(modelFit, newdata = trainMap)

# Calculate the RMSE from the predictions on the training set
RMSE <- function(expected, observed) { sqrt(mean((expected - observed)^2)) }
predictionRMSE <- RMSE(trainMap$Prob_Smooth, prediction)

# Obtain predictions for test set and write these results out to a file
submitDataFrame <- data.frame(GalaxyID = testMap$GalaxyID, Prob_Smooth = predict(modelFit, newdata = testMap))
write.csv(submitDataFrame, file = "../submissionGBM2.csv", row.names = FALSE)
