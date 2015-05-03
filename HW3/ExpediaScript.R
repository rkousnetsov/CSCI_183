# Note to Professor Mohler:
# This script yields unsatisfactory results. I will continue to work on this problem until a significantly better 
# solution is achieved (for example, this program predicts the actual category of booking_bool and not its 
# probability, which is one reason for why my Kaggle score may be poor).
# I have had difficulty working with this large data set on the computer due to the very long run times of programs.
# Please forgive my poor performance and permit me to give you a second submission when I have developed a better
# program.

# Set working directory to folder containing Titanic training and test data.
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 3")

# Install and load multiple packages into the current session.
installAndLoadPackages <- function(pkg)
{
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg)) 
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}
installAndLoadPackages(c("caret", "gbm", "doParallel"))

# Import the training and test data sets (which were downloaded from Kaggle)
# Eliminate categorical data (id data, since it does not likely have meaningful value in terms of its number and it is too computationally expensive to treat
# it as a factor, there will be an out of memory error). Eliminate the time since it is difficult to utilize. The historical price is also removed because it 
# is not defined in the test set.
train <- read.csv("train.csv")

train$srch_id <- NULL
train$date_time <- NULL
train$prop_id <- NULL
train$prop_log_historical_price <- NULL
train$site_id <- NULL
train$visitor_location_country_id <- NULL
train$prop_country_id <- NULL
train$srch_destination_id <- NULL

test <- read.csv("test.csv")

test$srch_id <- NULL
test$date_time <- NULL
test$prop_id <- NULL
test$prop_log_historical_price <- NULL
test$site_id <- NULL
test$visitor_location_country_id <- NULL
test$prop_country_id <- NULL
test$srch_destination_id <- NULL

# Setup gbm parameters
fitControl <- trainControl(method = "cv", number = 3, repeats = 1)
gbmGrid <- expand.grid(interaction.depth = 4, n.trees = 1000, shrinkage = 0.001)

# Create gbm model (run in parallel to speed up this process)
cl <- makeCluster(detectCores())
registerDoParallel(cl)
modelFit <- train(booking_bool ~ ., data = train, method = "gbm", trControl = fitControl, tuneGrid = gbmGrid)

# Convert probabilities to classifications
# 0.05 is used as a cutoff because it is near the third quartile of the predictions for samples in the training set that had a booking_bool of 1
# This can be seen using the following command: summary(predict(modelFit, newdata = subset(train, booking_bool == 1)))
classificationFunction <- function(x)
{
  if (x < 0.05)
    x <- 0
  else
    x <- 1
}
confusionMatrix(sapply(predict(modelFit, newdata = train), classificationFunction), train$booking_bool)

# Create output .csv file containing predictions
test <- read.csv("test.csv")
submitDataFrame <- data.frame(paste(test$srch_id, test$prop_id, sep = "-"), sapply(predict(modelFit, newdata = test), classificationFunction))
colnames(submitDataFrame) <- c("srch-prop_id", "booking_bool")
write.csv(submitDataFrame, file = "expediaPrediction.csv", row.names = FALSE)
