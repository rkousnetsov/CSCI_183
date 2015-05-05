# Set working directory to folder containing images
setwd("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/In-class Exercises/images_training_rev1")

# Load all relevant packages
## install.packages("pacman")
pacman::p_load(ripa, jpeg, EBImage, foreach, doParallel, caret)

# Read in images list. 
images <- list.files()

# Read in training set and add additional columns for future features to training set.
train <- read.csv("../galaxy_train.csv")

# Set up parallel backend in order to execute foreach in parallel
c1 <- makeCluster(detectCores())
registerDoParallel(c1)

# Loop over all images and fill in the data frame
df <- foreach(x = 1:length(images), .export = c("resize", "rgb2grey", "readJPEG"), .combine = rbind) %dopar% 
{
  # Read in the image, convert it to gray-scale and resize it to 50 x 50
  image <- resize(rgb2grey(readJPEG(images[x])), 50, 50)
  
  # Fetch row from training set
  row <- train[train$GalaxyID == gsub(".jpg", "", images[x]),]
  
  data.frame(
    GalaxyID = gsub(".jpg", "", images[x]), 
    Prob_Smooth = ifelse(nrow(row) == 1, row$Prob_Smooth, NA), 
    Mean = mean(image), 
    Variance = var(as.vector(image)), 
    Q10 = quantile(image, 0.1), 
    Q25 = quantile(image, 0.25), 
    Q75 = quantile(image, 0.75), 
    Q90 = quantile(image, 0.9), 
    row.names = x)
}
stopCluster(c1)

# Extract train and test sets
train <- subset(df, !is.na(Prob_Smooth))
test <- subset(df, is.na(Prob_Smooth))

# Split training set into 2 folds for cross-validation
trainIndex <- createFolds(train$GalaxyID, k = 2)
trainCV1 <- train[trainIndex[[1]],]
trainCV2 <- train[trainIndex[[2]],]

# Create glm fit on CV1 and use it to make prediction on CV2
glmModelFit <- glm(Prob_Smooth ~ Mean + Variance + Q10 + Q25 + Q75 + Q90, data = trainCV1, family = "gaussian")
prediction <- predict(glmModelFit, newdata = trainCV2)

# Calculate the RMSE from the predictions
RMSE <- function(expected, observed) { sqrt(mean((observed - expected)^2) }
predictionRMSE <- RMSE(trainCV2$Prob_Smooth, prediction)
