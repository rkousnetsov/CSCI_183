'''
"""
This block of code reads in all the images from file and saves them
to a csv file for later use.
"""
from skimage.io import imread
from skimage.transform import resize
from os import listdir, chdir
import pandas
import numpy

# Set working directory. Initialize list of all image files.
chdir("C:/Users/rkousnet.DCENGR/CSCI 183/Galaxy/Images")
filesList = listdir()

# Read in the data. Prepare data frames for images.
trainDF = pandas.read_csv("../galaxy_train.csv").sort(columns = "GalaxyID")
testDF = pandas.DataFrame(columns = ["GalaxyID", "Prob_Smooth"])
trainImages = pandas.DataFrame(columns = range(0, 64*64*3))
testImages = pandas.DataFrame(columns = range(0, 64*64*3))

# Loop over all image files and add them to the data frames.
for image in filesList:
    GalaxyID = int(image[:-4])
    flattenedImage = resize(imread(image), (64, 64)).flatten()
    if any(trainDF.GalaxyID == GalaxyID):
        trainImages.loc[len(trainImages)] = flattenedImage
    else:
        testDF.loc[len(testDF)] = [GalaxyID, numpy.nan]
        testImages.loc[len(testImages)] = flattenedImage
        
# Save all the data frames as csv files.
trainDF.to_csv("../trainDF.csv", index = False)
testDF.to_csv("../testDF.csv", index = False)
trainImages.to_csv("../trainImages.csv", index = False)
testImages.to_csv("../testImages.csv", index = False)
'''

# Set working directory.
from os import chdir
chdir("C:/Users/rkousnet/CSCI 183/Galaxy/")

# Read in all data.
import pandas
trainDF = pandas.read_csv("trainDF.csv")
testDF = pandas.read_csv("testDF.csv")
trainImages = pandas.read_csv("trainImages.csv")
testImages = pandas.read_csv("testImages.csv")

# Convert all relevant data to float32 type.
trainArray = (trainImages.values).astype("float32")
testArray = (testImages.values).astype("float32")
trainProb_Smooth = (trainDF.Prob_Smooth.values).astype("float32")

# Reshape images into symbolic 4D tensor
trainArray = trainArray.reshape(trainArray.shape[0], 3, 64, 64)
testArray = testArray.reshape(testArray.shape[0], 3, 64, 64)

# Import all relevant packages from keras
from keras.models import Sequential
from keras.layers.core import Dense, Activation, Dropout, Flatten
from keras.layers.convolutional import Convolution2D, MaxPooling2D
from keras.optimizers import SGD

# Create a very deep VGG-like convolutional neural network.
def veryDeepCNN():
    cnnModel = Sequential()

    cnnModel.add(Convolution2D(64, 3, 3, 3, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(Convolution2D(64, 64, 3, 3))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    cnnModel.add(Dropout(0.25))
    
    cnnModel.add(Convolution2D(128, 64, 3, 3, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(Convolution2D(128, 128, 3, 3))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    cnnModel.add(Dropout(0.25))
    
    cnnModel.add(Convolution2D(256, 128, 3, 3, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(Convolution2D(256, 256, 3, 3))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    cnnModel.add(Dropout(0.25))
    
    cnnModel.add(Convolution2D(512, 256, 3, 3, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(Convolution2D(512, 512, 3, 3))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    cnnModel.add(Dropout(0.25))
    
    cnnModel.add(Flatten())

    cnnModel.add(Dense(512 * 4 * 4, 512))
    cnnModel.add(Activation('relu'))
    cnnModel.add(Dropout(0.5))
    
    cnnModel.add(Dense(512, 1))
    cnnModel.add(Activation('linear'))
    
    sgd = SGD(lr = 0.05, decay = 1e-6, momentum = 0.9, nesterov = True)
    cnnModel.compile(loss='mean_squared_error', optimizer = sgd)
    
    return cnnModel

# Create a simple convolutional neural network.
def deepCNN():
    cnnModel = Sequential()

    cnnModel.add(Convolution2D(32, 3, 2, 2, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    
    cnnModel.add(Convolution2D(64, 32, 2, 2, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))
    
    cnnModel.add(Convolution2D(128, 64, 2, 2, border_mode = 'full'))
    cnnModel.add(Activation('relu'))
    cnnModel.add(MaxPooling2D(poolsize=(2,2)))

    cnnModel.add(Flatten())

    cnnModel.add(Dense(128 * 8 * 8, 512))
    cnnModel.add(Activation('relu'))

    cnnModel.add(Dense(512, 1))
    cnnModel.add(Activation('linear'))

    sgd = SGD(lr = 0.05, decay = 1e-6, momentum = 0.9, nesterov = True)
    cnnModel.compile(loss='mean_squared_error', optimizer = sgd)

    return cnnModel

# Initialize neural network
cnnModel = deepCNN()

# Fit CNN to data. Then predict Prob_Smooth for test set.
cnnModel.fit(trainArray, trainProb_Smooth, nb_epoch = 20)
predictions = cnnModel.predict(testArray)

# Save predictions to csv file (with proper types for each column)
testDF.GalaxyID = testDF.GalaxyID.values.astype("int32")
testDF.Prob_Smooth = predictions.astype("float32")
testDF.to_csv("galaxyPredictions.csv", index = False)
