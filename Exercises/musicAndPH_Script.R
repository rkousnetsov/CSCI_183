# Set working directory to folder containing Titanic training and test data.
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/In-class Exercises")

# Install and load packages
ipak <- function(pkg)
{
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
ipak(c("caret", "glmnet", "taRifx"))

# -------------------------------------------------------------------------------------------------------------------------------------------
# Music assignment
# -------------------------------------------------------------------------------------------------------------------------------------------

# Read in music-all.csv
music <- read.csv("music-all.csv")

# Impute all NAs using k-nearest neighbors (knnImpute)
music[,4:length(music)] <- predict(preProcess(music[,4:length(music)], method = "knnImpute"), music[,4:length(music)])

# Find principal components of song using prcomp (where retx = TRUE and scale. = TRUE)
# Eliminate X, artist, and type from the formula (since prcomp requires strictly numeric variables)
principalComponents <- prcomp(~ . - X - artist - type, data = music, retx = TRUE, scale. = TRUE)

# Plot the standard deviations of the principal components
plot(principalComponents$sdev, xlab = "Principal Component Number", ylab = "Standard Deviation")

# Scatterplot of first 2 principal components, use artist name for points
temp <- data.frame(Artist = music$artist, PC1 = principalComponents$x[,1], PC2 = principalComponents$x[,2])
ggplot(temp, aes(x = PC1, y = PC2, label = Artist)) + geom_text()

# -------------------------------------------------------------------------------------------------------------------------------------------
# Soil assignment
# -------------------------------------------------------------------------------------------------------------------------------------------

# Read in soil.csv
soil <- read.csv("soil.csv")

# Transform data into matrix
soilMatrix <- as.matrix(soil)

# Fit glmnet model for pH
# pH is the last column of soilMatrix, all other variables are inthe preceding columns of soilMatrix
glmnetModelFit <- glmnet(soilMatrix[,1:length(soil)-1], soil$pH, family = "gaussian")

# Plot coeficients of fit
plot(glmnetModelFit)

# Find best lambda parameter and plot corresponding coefficients
coefBestLambda <- coef(cv.glmnet(soilMatrix[,1:length(soil)-1], soil$pH, family = "gaussian"), s = "lambda.min")
plot(coefBestLambda, ylab = "Coefficients")

# List the 10 best variable names that predict pH
varCoef <- data.frame(varName = rownames(coefBestLambda), coefficient = coefBestLambda[,1])
tail(sort(subset(varCoef, varName != "(Intercept)" & coefficient > 0), f = ~ coefficient), 10)$varName
