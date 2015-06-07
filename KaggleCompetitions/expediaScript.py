'''
This code is very simple in terms of data manipulations (no imputation or
normalization; there is only column dropping). 
The data is easy to manipulate using the pandas package, which provides 
support for a DataFrame that is very similar to the data frame structure 
from R.

Surprisingly, this code gets a good score (~0.76) for the Expedia
competition using only a gradient boosting model (250 trees, maximum
depth of 4, all other settings to the defaults of given by sklearn).

This code was run on the remote server provided by the engineering school.
This should provide plentiful memory and processing power.

I used Python 3.4 from the WinPython-64bit-3.4.3.3 distribution that I
installed onto the remote server. 
I wrote and ran the code in the Spyder IDE that comes bundled with this 
installation (along with all relevant packages).
'''

# Set working directory
from os import chdir
chdir("C:/Users/rkousnet.DCENGR/CSCI 183/Expedia")

# Read in data
import pandas
train = pandas.read_csv("train.csv")
test = pandas.read_csv("test.csv")
sample = pandas.read_csv("sample_submission.csv")

# Save booking_bool
train_booking_bool = train.booking_bool.values

'''
(1) Drop all id columns since they do not provide very useful information.
(2) Drop the date column since it is difficult to work with.
(3) Drop the prop_log_historical_price because this column does not have
meaningful values in the test set.
(4) Drop booking_bool in the training set (do not want to predict with
the actual target in the training set).
'''
train = train.drop(["srch_id", 
            "date_time", 
            "prop_id", 
            "prop_log_historical_price", 
            "site_id", 
            "visitor_location_country_id", 
            "prop_country_id", 
            "srch_destination_id", 
            "booking_bool"], 
            axis = 1)
test = test.drop(["srch_id", 
            "date_time", 
            "prop_id", 
            "prop_log_historical_price", 
            "site_id", 
            "visitor_location_country_id", 
            "prop_country_id", 
            "srch_destination_id"], 
            axis = 1)

# Fit gradient boosting model 
from sklearn.ensemble import GradientBoostingClassifier
gb = GradientBoostingClassifier(n_estimators = 250, max_depth = 4)
gb.fit(train, train_booking_bool)

# Save predictions for testing set in csv file
predictionsTest = gb.predict_proba(test)[:, 1]
sample["booking_bool"] = predictionsTest
sample.to_csv("expediaSubmission.csv", index = False)
