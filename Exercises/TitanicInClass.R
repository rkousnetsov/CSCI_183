# Set working directory to folder containing Titanic training and test data.
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 2")

# Install and load the caret package
install.packages("caret")
library("caret")

# Import the training and test data sets (Which were downloaded from Kaggle)
trainDataFrame <- read.csv("trainTitanic.csv")
testDataFrame <- read.csv("testTitanic.csv")

# Preprocess the data, imputing any NA entries with the mean.
trainDataFramePreProcess <- trainDataFrame
imputeAgeValue <- mean(trainDataFramePreProcess$Age, na.rm = TRUE)
trainDataFramePreProcess$Age[is.na(trainDataFramePreProcess$Age)] <- imputeAgeValue

# Install and load the rpart package
install.packages("rpart")
library("rpart")

# Create decision tree and plot tree
decisionTreeModel <- rpart(Survived ~ Pclass + Sex + Age + Fare + SibSp + Parch + Embarked, data = trainDataFramePreProcess, method = "class")

# View file on online postscript viewer: http://view.samurajdata.se
post(decisionTreeModel, file = "DecisionTreePicture.ps", title = "Classification Tree for Titanic Survival")

#  Install and load the gbm package
install.packages("gbm")
library("gbm")

# Setup gbm parameters
fitControl <- trainControl(method = "cv", number = 10, repeats = 1, verbose = TRUE)
gbmGrid <- expand.grid(interaction.depth = seq(1, 4), n.trees = seq(200, 10000, by = 200), shrinkage = c(0.1, 0.05, 0.01, 0.005, 0.001))

# Install and load doParallel package
install.packages("doParallel")
library("doParallel")

# Install and load package Required for as.factor
install.packages("e1071")
library("e1071")

# Create gbm model (can run in parallel to speed up this process)
cl <- makeCluster(detectCores())
registerDoParallel(cl)
gbmModelFit <- train(as.factor(Survived) ~ Pclass + Sex + Age + Fare + SibSp + Parch + Embarked, data = trainDataFramePreProcess, method = "gbm", distribution = "bernoulli", 
                     trControl = fitControl, tuneGrid = gbmGrid, verbose = FALSE)

# Create accuracy plot and summary statistics
trellis.par.set(caretTheme())
plot(gbmModelFit)
summary(gbmModelFit)

# Pre-process test set
testDataFramePreProcess <- testDataFrame
imputeFareValue <- mean(trainDataFramePreProcess$Fare, na.rm = TRUE)
testDataFramePreProcess$Age[is.na(testDataFramePreProcess$Age)] <- imputeAgeValue
testDataFramePreProcess$Fare[is.na(testDataFramePreProcess$Fare)] <- imputeAgeValue

# Predict survival using the gbm model
submitDataFrame <- data.frame(PassengerID = testDataFramePreProcess$PassengerId, Survived = predict(gbmModelFit, newdata = testDataFramePreProcess))

# Create csv file from the predicitons
write.csv(submitDataFrame, file = "TitanicCompetitionPrediction_RK.csv", row.names = FALSE)
