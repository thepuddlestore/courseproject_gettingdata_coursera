courseproject_gettingdata_coursera
==================================

Repo Description: Repo for the Course Project for the Getting and Cleaning Data class in Coursera

library(plyr)
library(reshape2)

setwd("~/Desktop/RWork/UCI HAR Dataset")

import all Train Set data and merge it together
this reads in all 7352 observations of the 561 variables of the training set
this reads in the activity number linked to each of the 7352 observations in X_train
this reads in the subject number linked to each of the 7352 observations in X_train
this creates the complete training data set via cbind

import all Test Set data and merge it together (same method as for the training set)
this reads in all 2947 observations of the 561 variables of the test set
this reads in the activity number linked to each of the 2947 observations in X_test
this reads in the subject number linked to each of the 2947 observations in X_test
this creates the complete test data set via cbind

This set of code creates a session key that will be applied to the final tidy set before export. It is the indicator for which dataset a subject came from
For test IDs
tests <- unique(TestIDs)
tests <- cbind(Session = "Test", Subject = tests, row.names = NULL)
names(tests)[2] <- "Subject"

For Train IDs
trains <- unique(TrainIDs)
trains <- cbind(Session = "Train", Subject = trains, row.names = NULL)
names(trains)[2] <- "Subject"

Merging testing and training IDs together via rbind
sessionkey <- rbind(tests, trains)

Create the complete dataset via rbind
rbind together the testing and training datasets
import the column labels for the 561 measurements
create the columnlabels list for the complete dataset
assign the labels to the dataframe

get all the measurements of mean and standard deviation by column index
find the index for all means
find the index for all standard deviations
find the index for all angle measurements (which are all measurements of a mean)
create the index vector for needed columns for the whole dataset
drop all unneeded columns

Create a dataframe to translate activity number to activity name
read in the activity labels data
remove the "_" from the descriptions
name the columns for easy merging
merge the activity names with the complete dataset

Calculating means for each measurement by subject and activity names
melt the complete dataset so that it's tall and skinny with a column for the variable and value
create an array of tables for each measurement by subject (in rows) and activity (in columns) with the mean of the measurements in the cells
use adply to convert the array back to a dataframe by subject (1) and activity name (2)
rename the first two columns

Merge in the session key created earlier to indicate whether subjects came from the test or training set

Renaming the descrptive measurements with gsub to remove all "illegal" characters
draftnames <- c(colnames(tidy.draft))
draftnames <- gsub("-", "", draftnames)
draftnames <- gsub(",", "", draftnames)
draftnames <- gsub("\\(", "", draftnames)
finalnames <- gsub("\\)", "", draftnames)
names(tidy.draft) <- finalnames ## make the assignment of the final column names

Write tidy independent dataset as a tab delimited .txt file called "tidyUCI.txt" to the working directory
write.table(tidy.draft, "tidyUCI.txt", append = FALSE, sep = "\t", row.names = FALSE)
