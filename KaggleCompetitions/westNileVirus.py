from os import chdir
chdir("C:/Users/rkousnet/CSCI 183/WNV Kaggle")

import pandas as pd
import numpy as np
from sklearn import ensemble, preprocessing

# Load dataset 
train = pd.read_csv('train.csv')
test = pd.read_csv('test.csv')
sample = pd.read_csv('sampleSubmission.csv')
weather = pd.read_csv('weather.csv')

# Get labels
labels = train.WnvPresent.values

# Not using codesum for this benchmark
weather = weather.drop('CodeSum', axis=1)

# Split station 1 and 2 and join horizontally
weather_stn1 = weather[weather['Station']==1]
weather_stn2 = weather[weather['Station']==2]
weather_stn1 = weather_stn1.drop('Station', axis=1)
weather_stn2 = weather_stn2.drop('Station', axis=1)
weather = weather_stn1.merge(weather_stn2, on='Date')

# replace some missing values and T with -1
weather = weather.replace('M', -1)
weather = weather.replace('-', -1)
weather = weather.replace('T', -1)
weather = weather.replace(' T', -1)
weather = weather.replace('  T', -1)

# Functions to extract month and day from dataset
# You can also use parse_dates of Pandas.
def create_month(x):
    return x.split('-')[1]

def create_day(x):
    return x.split('-')[2]

train['month'] = train.Date.apply(create_month)
train['day'] = train.Date.apply(create_day)
test['month'] = test.Date.apply(create_month)
test['day'] = test.Date.apply(create_day)

# Add integer latitude/longitude columns
train['Lat_int'] = train.Latitude.apply(int)
train['Long_int'] = train.Longitude.apply(int)
test['Lat_int'] = test.Latitude.apply(int)
test['Long_int'] = test.Longitude.apply(int)

# drop address columns
train = train.drop(['Address', 'AddressNumberAndStreet','WnvPresent', 'NumMosquitos'], axis = 1)
test = test.drop(['Id', 'Address', 'AddressNumberAndStreet'], axis = 1)

# Merge with weather data
train = train.merge(weather, on='Date')
test = test.merge(weather, on='Date')
train = train.drop(['Date'], axis = 1)
test = test.drop(['Date'], axis = 1)

# Convert categorical data to numbers
lbl = preprocessing.LabelEncoder()
lbl.fit(list(train['Species'].values) + list(test['Species'].values))
train['Species'] = lbl.transform(train['Species'].values)
test['Species'] = lbl.transform(test['Species'].values)

lbl.fit(list(train['Street'].values) + list(test['Street'].values))
train['Street'] = lbl.transform(train['Street'].values)
test['Street'] = lbl.transform(test['Street'].values)

lbl.fit(list(train['Trap'].values) + list(test['Trap'].values))
train['Trap'] = lbl.transform(train['Trap'].values)
test['Trap'] = lbl.transform(test['Trap'].values)

# drop columns with -1s
train = train.ix[:,(train != -1).any(axis=0)]
test = test.ix[:,(test != -1).any(axis=0)]

# Extremely Randomized Trees Classifier 
from sklearn.ensemble import ExtraTreesClassifier
et = ExtraTreesClassifier(n_estimators = 10000, n_jobs = -1, 
                          min_samples_split = 1)
et.fit(train, labels)

# Random Forest Classifier 
from sklearn.ensemble import RandomForestClassifier
rf = RandomForestClassifier(n_estimators = 10000, n_jobs = -1, 
                            min_samples_split = 1)
rf.fit(train, labels)

# Gradient Boosting Classifier
from sklearn.ensemble import GradientBoostingClassifier
gbm = GradientBoostingClassifier(n_estimators = 1000, max_depth = 4)
gbm.fit(train, labels)

# For normalization (scaling and centering)
from sklearn.preprocessing import StandardScaler
scaler = StandardScaler()
trainNormal = scaler.fit_transform(train)
testNormal = scaler.fit_transform(test)

# Support vector machine
from sklearn.svm import SVC
svc = SVC(probability = True)
svc.fit(trainNormal, labels)

# Naive Bayes
from sklearn.naive_bayes import GaussianNB
gnb = GaussianNB()
gnb.fit(trainNormal, labels)

# Logistic Regresion
from sklearn.linear_model import LogisticRegression
lr = LogisticRegression()
lr.fit(trainNormal, labels)

# Chained structure (select 21 best features and use logistic regression)
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_classif
bestFeatures = SelectKBest(f_classif, k = 21).fit(trainNormal, labels)
trainBest = bestFeatures.transform(trainNormal)
testBest = bestFeatures.transform(testNormal)
lrBest = LogisticRegression()
lrBest.fit(trainBest, labels)

# Assess auc score on training set (should be >= 0.8)
from sklearn.metrics import roc_auc_score
predictionTrain = lrBest.predict_proba(trainNormal)[:, 1]
roc_auc_score(labels, predictionTrain)

# create predictions and submission file
predictionTest = lr.predict_proba(testNormal)[:, 1]
sample['WnvPresent'] = predictionTest
sample.to_csv('logSubmission.csv', index=False)
