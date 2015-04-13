# Set working directory to my CSCI 183 folder (which contains the training and test data sets from Kaggle)
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 2")

# Import the training and test data sets (Which were downloaded from Kaggle)
trainDataFrame <- read.csv("trainTitanic.csv")
testDataFrame <- read.csv("testTitanic.csv")

# A logistic regression model is used because:
# (1) It is mandated for the CSCI 183 assignment (as per Professor Mohler's
# instructions).
# (2) This gender-class model is fairly consistent with a passenger's proximity
# to a lifeboat (according to passenger class) as well as the famous saying
# "women and children first" (indicative of gender and age).
# 
# The logistic regression model takes into account:
#   (1) Passenger class (Pclass).
#   (2) Passenger gender (Sex).
# Note: passenger age (Age) would be good to include, but since some passengers 
# have an unknown age (NA), this category cannot be easily utilized.
logisticModel <- glm(Survived ~ Pclass + Sex, 
                     data = trainDataFrame, family = binomial)

# Predict the survival of the test data set using the logistic model.
# Create the final data frame in preparation for the submission, containing
# the two columns required by Kaggle:
#   (1) PassengerId (obtained from the testing data set)
#   (2) Survived (obtained from the logistic model from the training data set)
#
# Additional notes:
# The logistic model yields the probability that the survival variable takes on 
# the value of 1 (the probability itself is of the type double). 
# Consequently, the probability will be rounded to the nearest integer in order to
# convert the probability to the binary value for the Survived category.
# In this manner, if the probability yielded by the logistic model is high 
# (>=0.5), the corresponding passenger is likely to have survived (have a Survived
# value of 1). 
# Conversely, if the probability yielded by the logistic model is low
# (<0.5), the corresponding passenger is likely to have died (have a Survived
# value of 0). 
submitDataFrame <- data.frame(PassengerId = testDataFrame$PassengerId,
                              Survived = round(predict(logisticModel, testDataFrame, type="response")))

# Write the data frame out to a csv file without row names (so that it is
# properly formatted as per Kaggle's instructions).
write.csv(submitDataFrame, file = "TitanicCompetitionPrediction_RK.csv", row.names = FALSE)
