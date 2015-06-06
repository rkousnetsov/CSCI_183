from os import chdir
chdir("C:/Users/Robert/University Homework Notes/Santa Clara University/Computer Science (CSCI)/Computer Science 183 - Data Science/HW 6/Starcraft 2 Blog")

import pandas
data = pandas.read_csv("SkillCraft1_Dataset.csv")
data = data[data.TotalHours != "?"]
data = data[data.HoursPerWeek != "?"]
data = data[data.Age != "?"]
data['TotalHours'] = data.TotalHours.astype("int64")
data['HoursPerWeek'] = data.HoursPerWeek.astype("int64")
bronze = data[data.LeagueIndex == 1]
silver = data[data.LeagueIndex == 2]
gold = data[data.LeagueIndex == 3]
platinum = data[data.LeagueIndex == 4]
diamond = data[data.LeagueIndex == 5]
master = data[data.LeagueIndex == 6]
grandmaster = data[data.LeagueIndex == 7]

import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

def boxPlot(category, xLabel, yLabel, yLowerLimit, yUpperLimit,
            saveFile, fileName):
    figure = plt.figure(figsize = (10, 10))
    plot = figure.add_subplot(111)
    plot.boxplot([bronze[category].values, 
                  silver[category].values, 
                  gold[category].values, 
                  platinum[category].values, 
                  diamond[category].values, 
                  master[category].values, 
                  grandmaster[category].values])
    plt.xticks(range(1, 8), ("Bronze", "Silver", "Gold", "Platinum", "Diamond", "Master", "Grandmaster"))
    plt.xlabel(xLabel)
    plt.ylabel(yLabel)
    plt.ylim(yLowerLimit, yUpperLimit)
    figure.show()  
    if saveFile:
        plt.savefig(fileName, bbox_inches = "tight")

boxPlot(category = "HoursPerWeek", 
        xLabel = "League", yLabel = "Hours Played Per Week",
        yLowerLimit = 0, yUpperLimit = 80,
        saveFile = True, fileName = "hoursPerWeek.png")

boxPlot(category = "TotalHours", 
        xLabel = "League", yLabel = "Total Hours Played",
        yLowerLimit = 0, yUpperLimit = 3500,
        saveFile = True, fileName = "totalHours.png")
        
boxPlot(category = "APM", 
        xLabel = "League", yLabel = "Actions Per Minute (APM)",
        yLowerLimit = 0, yUpperLimit = 350,
        saveFile = True, fileName = "apm.png")
        
boxPlot(category = "ActionLatency", 
        xLabel = "League", yLabel = "Action Latency (ms)",
        yLowerLimit = 0, yUpperLimit = 200,
        saveFile = True, fileName = "actionLatency.png")

boxPlot(category = "NumberOfPACs",
        xLabel = "League", yLabel = "Rate of PACs",
        yLowerLimit = 0, yUpperLimit = 0.0075,
        saveFile = True, fileName = "ratePACs.png")
        
boxPlot(category = "GapBetweenPACs",
        xLabel = "League", yLabel = "Gap Between PACs (ms)",
        yLowerLimit = 0, yUpperLimit = 140,
        saveFile = True, fileName = "gapPACs.png")

from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier, GradientBoostingClassifier
features = data.drop(["GameID", "LeagueIndex"], axis = 1)
leagues = data.LeagueIndex.values
rfc = RandomForestClassifier(n_estimators = 1000, n_jobs = -1, min_samples_split = 1)
etc = ExtraTreesClassifier(n_estimators = 1000, n_jobs = -1, min_samples_split = 1)
gbc = GradientBoostingClassifier(n_estimators = 1000)
rfc.fit(features, leagues)
etc.fit(features, leagues)
gbc.fit(features, leagues)

import numpy
importanceArrayRFC = rfc.feature_importances_
importanceArrayETC = etc.feature_importances_
importanceArrayGBC = gbc.feature_importances_
featureImportanceListRFC = []
featureImportanceListETC = []
featureImportanceListGBC = []
for x in range (0, len(features.columns)):
    maxIndexRFC = numpy.where(importanceArrayRFC == max(importanceArrayRFC))[0][0]
    maxIndexETC = numpy.where(importanceArrayETC == max(importanceArrayETC))[0][0]
    maxIndexGBC = numpy.where(importanceArrayGBC == max(importanceArrayGBC))[0][0]
    importanceArrayRFC[maxIndexRFC] = 0
    importanceArrayETC[maxIndexETC] = 0
    importanceArrayGBC[maxIndexGBC] = 0
    featureImportanceListRFC.append(features.columns[maxIndexRFC])
    featureImportanceListETC.append(features.columns[maxIndexETC])
    featureImportanceListGBC.append(features.columns[maxIndexGBC])
