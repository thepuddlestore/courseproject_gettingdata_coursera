library(plyr)
library(reshape2)

setwd("~/Desktop/RWork/UCI HAR Dataset")

## import all Train Set data and merge it together
xTrain <- data.frame(read.table("./train/X_train.txt")) ## this reads in all 7352 observations of the 561 variables of the training set
yTrain <- data.frame(read.table("./train/y_train.txt")) ## this reads in the activity number linked to each of the 7352 observations in X_train
TrainIDs <- data.frame(read.table("./train/subject_train.txt")) ## this reads in the subject number linked to each of the 7352 observations in X_train
traincomplete <- cbind(TrainIDs, yTrain, xTrain) ## this creates the complete training data set via cbind

## import all Test Set data and merge it together (same method as for the training set)
xTest <- data.frame(read.table("./test/X_test.txt")) ## this reads in all 2947 observations of the 561 variables of the test set
yTest <- data.frame(read.table("./test/y_test.txt")) ## this reads in the activity number linked to each of the 2947 observations in X_test
TestIDs <- data.frame(read.table("./test/subject_test.txt")) ## this reads in the subject number linked to each of the 2947 observations in X_test
testcomplete <- cbind(TestIDs, yTest, xTest) ## this creates the complete test data set via cbind

## This set of code creates a session key that will be applied to the final tidy set before export. It is the indicator for which dataset a subject came from
## For test IDs
tests <- unique(TestIDs)
tests <- cbind(Session = "Test", Subject = tests, row.names = NULL)
names(tests)[2] <- "Subject"

## For Train IDs
trains <- unique(TrainIDs)
trains <- cbind(Session = "Train", Subject = trains, row.names = NULL)
names(trains)[2] <- "Subject"

## Merging testing and training IDs together via rbind
sessionkey <- rbind(tests, trains)

## Create the complete dataset via rbind
dataset <- rbind(traincomplete, testcomplete) ## rbind together the testing and training datasets
columnlabels <- data.frame(read.table("features.txt")) ## import the column labels for the 561 measurements
alllabels <- c("Subject", "ActivityLabels", as.vector(columnlabels$V2)) ##create the columnlabels list for the complete dataset
colnames(dataset) <- alllabels ## assign the labels to the dataframe

## get all the measurements of mean and standard deviation by column index
a <- grep("mean", alllabels) ## find the index for all means
b <- grep("std", alllabels) ## find the index for all standard deviations
c <- grep("angle", alllabels) ## find the index for all angle measurements (which are all measurements of a mean)
newcolumns <- c(1:2, sort(c(a, b, c))) ## create the index vector for needed columns for the whole dataset
dataset <- dataset[, newcolumns] ## drop all unneeded columns

## Create a dataframe to translate activity number to activity name
activitylabels <- data.frame(read.table("activity_labels.txt")) ## read in the activity labels data
activitylabels[, 2] <- gsub("_", " ", activitylabels[, 2]) ## remove the "_" from the descriptions
colnames(activitylabels) <- c("ActivityLabels", "ActivityName") ## name the columns for easy merging
finalmerged <- merge(activitylabels, dataset, by = "ActivityLabels") ## merge the activity names with the complete dataset

## Calculating means for each measurement by subject and activity names
melted <- melt(finalmerged, id = c("ActivityLabels", "ActivityName", "Subject")) ## melt the complete dataset so that it's tall and skinny with a column for the variable and value
array <- with(melted, tapply(value, list(Subject, ActivityName, variable), mean)) ## create an array of tables for each measurement by subject (in rows) and activity (in columns)
tidydraft <- adply(array, c(1, 2)) ## adply to convert the array back to a dataframe by subject (1) and activity name (2)
names(tidydraft)[1:2] <- c("Subject", "Activity") ## rename the first two columns

## Merge in the session key created earlier to indicate whether subjects came from the test or training set
tidydraft <- merge(sessionkey, tidydraft, by = "Subject") 

## Renaming the descrptive measurements with gsub to remove all "illegal" characters
draftnames <- c(colnames(tidydraft))
draftnames <- gsub("-", "", draftnames)
draftnames <- gsub(",", "", draftnames)
draftnames <- gsub("\\(", "", draftnames)
finalnames <- gsub("\\)", "", draftnames)
names(tidydraft) <- finalnames ## make the assignment of the final column names

## Write tidy independent dataset as a tab delimited .txt file called "tidyUCI.txt" to the working directory
write.table(tidydraft, "tidyUCI.txt", append = FALSE, sep = "\t", row.names = FALSE)


