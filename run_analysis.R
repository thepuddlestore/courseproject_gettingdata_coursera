library(plyr)
library(reshape2)

setwd("~/Desktop/RWork/UCI HAR Dataset")

## import all Train Set data and merge it together
xTrain <- data.frame(read.table("./train/X_train.txt"))
yTrain <- data.frame(read.table("./train/y_train.txt"))
TrainIDs <- data.frame(read.table("./train/subject_train.txt"))
traincomplete <- cbind(TrainIDs, yTrain, xTrain)

## import all Test Set data and merge it together
xTest <- data.frame(read.table("./test/X_test.txt"))
yTest <- data.frame(read.table("./test/y_test.txt"))
TestIDs <- data.frame(read.table("./test/subject_test.txt"))
testcomplete <- cbind(TestIDs, yTest, xTest)

## Creat session key
## For test IDs
tests <- unique(TestIDs)
tests <- cbind(Session = "Test", Subject = tests, row.names = NULL)
names(tests)[2] <- "Subject"

## For Train IDs
trains <- unique(TrainIDs)
trains <- cbind(Session = "Train", Subject = trains, row.names = NULL)
names(trains)[2] <- "Subject"

## Complete
sessionkey <- rbind(tests, trains)

## Create the complete dataset
dataset <- rbind(traincomplete, testcomplete)
columnlabels <- data.frame(read.table("features.txt")) ## import the column labels
all.labels <- c("Subject", "ActivityLabels", as.vector(columnlabels$V2)) ##create the columnlabels list
colnames(dataset) <- all.labels ## assign the labels to the dataframe

## get all the mean and std column indexes
a <- grep("mean", all.labels)
b <- grep("std", all.labels)
newcolumns <- c(1:2, sort(c(a, b))) ## create the index vector for needed columns
dataset <- dataset[, newcolumns] ## drop all unneeded columns

## merge in activity names
activitylabels <- data.frame(read.table("activity_labels.txt"))
activitylabels[, 2] <- gsub("_", " ", activitylabels[, 2])
colnames(activitylabels) <- c("ActivityLabels", "ActivityName")
final.merged <- merge(activitylabels, dataset, by = "ActivityLabels")

## reshaping
melted <- melt(final.merged, id = c("ActivityLabels", "ActivityName", "Subject"))
array <- with(melted, tapply(value, list(Subject, ActivityName, variable), mean))
tidy.draft <- adply(array, c(1, 2))
names(tidy.draft)[1:2] <- c("Subject", "Activity")
tidy.draft <- merge(sessionkey, tidy.draft, by = "Subject")
draftnames <- c(colnames(tidy.draft))
draftnames <- gsub("-", "", draftnames)
finalnames <- gsub("\\()", "", draftnames)
names(tidy.draft) <- finalnames

## writing tidy independent file
write.table(tidy.draft, "tidyUCI.txt", append = FALSE, sep = "\t", row.names = FALSE)

## writing code book
Subjects <- as.factor(unique(tidy.draft[,1]))
Sessions <- unique(tidy.draft[,2])
Activities <- unique(tidy.draft[, 3])
Measurements <- as.factor(names(tidy.draft[, 4:82]))
str(Subjects)
str(Sessions)
str(Activities)
z <- cbind(Column = c(4:82), Measurement = levels(Measurements))
