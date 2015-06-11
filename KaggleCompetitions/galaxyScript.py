'''
from skimage.io import imread
from skimage.transform import resize
from os import listdir, chdir
import pandas
import numpy

chdir("C:/Users/rkousnet.DCENGR/CSCI 183/Galaxy/Images")
filesList = listdir()

trainDF = pandas.read_csv("../galaxy_train.csv").sort(columns = "GalaxyID")
testDF = pandas.DataFrame(columns = ["GalaxyID", "Prob_Smooth"])
trainImages = pandas.DataFrame(columns = range(0, 64*64*3))
testImages = pandas.DataFrame(columns = range(0, 64*64*3))

for image in filesList:
    GalaxyID = int(image[:-4])
    flattenedImage = resize(imread(image), (64, 64)).flatten()
    if any(trainDF.GalaxyID == GalaxyID):
        trainImages.loc[len(trainImages)] = flattenedImage
    else:
        testDF.loc[len(testDF)] = [GalaxyID, numpy.nan]
        testImages.loc[len(testImages)] = flattenedImage
        
trainDF.to_csv("../trainDF.csv", index = False)
testDF.to_csv("../testDF.csv", index = False)
trainImages.to_csv("../trainImages.csv", index = False)
testImages.to_csv("../testImages.csv", index = False)
'''

from os import chdir
chdir("C:/Users/rkousnet/CSCI 183/Galaxy/")

import pandas
trainDF = pandas.read_csv("trainDF.csv")
testDF = pandas.read_csv("testDF.csv")
trainImages = pandas.read_csv("trainImages.csv")
testImages = pandas.read_csv("testImages.csv")

import numpy
trainArray = (trainImages.values).astype("float32")
testArray = (testImages.values).astype("float32")
trainProb_Smooth = (trainDF.Prob_Smooth.values).astype("float32")

trainArray = trainArray.reshape(trainArray.shape[0], 3, 64, 64)
testArray = testArray.reshape(testArray.shape[0], 3, 64, 64)

from keras.models import Sequential
from keras.layers.core import Dense, Activation, Dropout, Flatten
from keras.layers.convolutional import Convolution2D, MaxPooling2D
from keras.optimizers import SGD

cnnModel = Sequential()

cnnModel.add(Convolution2D(32, 3, 3, 3, border_mode = "full"))
cnnModel.add(Activation('relu'))
cnnModel.add(MaxPooling2D(poolsize=(2,2)))

cnnModel.add(Convolution2D(32, 32, 3, 3, border_mode = "full"))
cnnModel.add(Activation('relu'))
cnnModel.add(MaxPooling2D(poolsize=(2,2)))

cnnModel.add(Convolution2D(32, 32, 3, 3, border_mode = "full"))
cnnModel.add(Activation('relu'))
cnnModel.add(MaxPooling2D(poolsize=(2,2)))

cnnModel.add(Flatten())

cnnModel.add(Dense(2592, 512))
cnnModel.add(Activation('relu'))
cnnModel.add(Dropout(0.25))

cnnModel.add(Dense(512, 1))
cnnModel.add(Activation('linear'))

sgd = SGD(lr = 0.05, decay = 1e-6, momentum = 0.9, nesterov = True)
cnnModel.compile(loss='mean_squared_error', optimizer = sgd)

cnnModel.fit(trainArray, trainProb_Smooth, nb_epoch = 20)

predictions = cnnModel.predict(testArray)
testDF.Prob_Smooth = predictions
testDF.to_csv("galaxyPredictions.csv", index = False)
