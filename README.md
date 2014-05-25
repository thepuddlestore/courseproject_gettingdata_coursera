Read Me: Course Project for Getting and Cleaning Data
==================================

This Read Me is designed to explain the process I used to create the tidy dataset for this assignment. It is likely not the most efficient, but after many hours of effort, it gets the job done (as I understand it).

My script uses the plyr and reshape2 packages to calculate the means of variables. It also assumes that my working directory is the unzipped UCI HAR Dataset folder provided for the assignemnt and all paths are relative to this assumption. 

This Read Me does not include the actual code script but does follow the run_analysis script in its order

# The Process #
My script begins by importing all of the test set and training set data and assigning it to variables using read.table and data.frame. 

## Importing Data ##

### Steps ###
1.      Import the Training Set data and merge it together
this reads in all 7352 observations of the 561 variables of the training set
this reads in the activity number linked to each of the 7352 observations in X_train
this reads in the subject number linked to each of the 7352 observations in X_train
this creates the complete training data set via cbind

2.      Import the Test Set data and merge it together (same method as for the training set)
this reads in all 2947 observations of the 561 variables of the test set
this reads in the activity number linked to each of the 2947 observations in X_test
this reads in the subject number linked to each of the 2947 observations in X_test
this creates the complete test data set via cbind

3.      Create a session key that will be applied to the final tidy set before export. It is the indicator for which dataset a subject came from
For test IDs
tests <- unique(TestIDs)
tests <- cbind(Session = "Test", Subject = tests, row.names = NULL)
names(tests)[2] <- "Subject"

For Train IDs
trains <- unique(TrainIDs)
trains <- cbind(Session = "Train", Subject = trains, row.names = NULL)
names(trains)[2] <- "Subject"

Merge the the and training IDs together via rbind
sessionkey <- rbind(tests, trains)

4.      Create the complete dataset via rbind
rbind together the testing and training datasets
import the column labels for the 561 measurements
create the columnlabels list for the complete dataset
assign the labels to the dataframe

5.      Locate the indexes for all the measurements of mean and standard deviation by column index. I made the decision to 
find the index for all means
find the index for all standard deviations
find the index for all angle measurements (which are all measurements of a mean)
create the index vector for needed columns for the whole dataset
drop all unneeded columns

6.      Create a dataframe to translate activity number to activity name
read in the activity labels data
remove the "_" from the descriptions
name the columns for easy merging
merge the activity names with the complete dataset

7.      Calculating means for each measurement by subject and activity names
melt the complete dataset so that it's tall and skinny with a column for the variable and value
create an array of tables for each measurement by subject (in rows) and activity (in columns) with the mean of the measurements in the cells
use adply to convert the array back to a dataframe by subject (1) and activity name (2)
rename the first two columns

8.      Merge in the session key created earlier to indicate whether subjects came from the test or training set

9.      Renaming the descrptive measurements with gsub to remove all "illegal" characters
draftnames <- c(colnames(tidy.draft))
draftnames <- gsub("-", "", draftnames)
draftnames <- gsub(",", "", draftnames)
draftnames <- gsub("\\(", "", draftnames)
finalnames <- gsub("\\)", "", draftnames)
names(tidy.draft) <- finalnames ## make the assignment of the final column names

10.     Write tidy independent dataset as a tab delimited .txt file called "tidyUCI.txt" to the working directory
write.table(tidy.draft, "tidyUCI.txt", append = FALSE, sep = "\t", row.names = FALSE)
