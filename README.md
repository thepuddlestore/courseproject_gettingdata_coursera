Read Me: Course Project for Getting and Cleaning Data
==================================

This Read Me is designed to explain the process I used to create the tidy dataset for this assignment. It is likely not the most efficient, but after many hours of effort, it gets the job done (as I understand it).

My script uses the plyr and reshape2 packages to calculate the means of variables. It also assumes that my working directory is the unzipped UCI HAR Dataset folder provided for the assignemnt and all paths are relative to this assumption. 

This Read Me does not include the actual code script but does follow the run_analysis script in its order.


### Steps ###
#### Import the Training Set data and merge it together ####
* After reading in all three .txt files, they are merged together via cbind
* Variables used include:
1. xTrain (data frame): 7352 observations of 561 variables, these are the measurements
2. yTrain (data frame): 7352 observations of 1 variable, these are the activity numbers
3. TrainIDs (data frame): 7352 observations of 1 variable, these are the subject ID numbers
4. traincomplete (data frame): 7352 observations of 563 variables, this is the merged (via cbind) training dataset


#### Import the Test Set data and merge it together ####
* After reading in all three .txt files, they are merged together via cbind
* Variables used include:
1. xTest (data frame): 2947 observations of 561 variables, these are the measurements
2. yTest (data frame): 2947 observations of 1 variable, these are the activity numbers
3. TestIDs (data frame): 2947 observations of 1 variable, these are the subject ID numbers
4. testcomplete (data frame): 2947 observations of 563 variables, this is the merged (via cbind) test dataset


#### Create a session key that will be applied to the final tidy set before export ####
* This creates data frame used later to merge in the indicator for  which dataset a subject came from
* Variables used include
1. tests (data frame): 9 observations of 2 variables, this indicates all subjects from the test dataset
2. trains (data frame): 21 observations of 2 variables, this indicates all subjects from the train dataset
3. sessionkey (data frame): 30 observations of 2 variables, this is tests and trains merged together via rbind. It is applied to the nearly tidy dataset prior to export


#### Create the complete dataset via rbind ####
* This step merges together the test and training sets and names the columns
* Variables used include:
1. dataset (data frame): 10299 observations of 563 variables, this is the merged (via rbind) traincomplete and testcomplete dataframes
2. columnlabels (data frame): 561 observations of 2 variables, this is the complete list of column labels for the 561 measurements in the dataset by index number
3. alllabels (563-object character vector): this is the complete list of column labels which are applied to dataset


#### Locate the indexes for all the measurements of mean and standard deviation by column index. ####
* I made the decision to include any column whose name contains the word "mean" or "std" (standard deviation). While I realize this may be over-inclusive, the assignment is not specific and asks to use all measurements of mean and standard deviation. It is easier to exclude columns after the fact than go back and rewrite the script to include them.
* Variables used include:
1. a (46-object integer vector): these are the indices for all columns containing "mean" in the name
2. b (33-onject integer vector): these are the indices for all columns containting "std" in the name
3. c (7-onject integer vector): these are the indices for all columns containing "angle" in the name which all have "mean" inside the parentheses in the name
4. newcolumns (88-object integer vector): these are all indices from dataset that need to be included in the tidy dataset
5. dataset (data frame): 10299 observations of 88 variables, dataset is transformed by applying newcolums to it, thereby dropping all measurements not associated with mean and standard deviation


#### Create a dataframe to translate activity number to activity name ####
* Variables used include:
1. activitylabels (data frame): 6 observations of 2 variables, this matches the activity number with its matching descriptive name 


#### Merge descriptive activity names with the complete dataset ####
* I used merge() to combine the descriptive activity names with the activity numbers
* Variables used include:
1. finalmerged (data frame): 10299 observations of 89 variables, this is the complete training and test dataset with columnames and descriptive activity names

#### Calculating means for each measurement by subject and activity names ####
* I melted the complete dataset (finalmerged) so that it was tall and skinny with ID variables including activity numbers (colname = "ActivityLabels"), activity names (colname = "ActivityNames") and subject (colname = "Subject"). The variable is the measurement (means and standard deviations) name and value is the normalized measurement itself. 
* I then created an array of tables by measurement with the subject number in the row and the activity name in the columns and the mean of each measurement in the cells. 
* I used adply() to convert the array back to a data frame by subject number and descriptive activity. Finally, I renamed the columns
*Variables used include:
1. melted (data frame): 885174 observations of 5 variables, the tall skinny data frame
2. array (an array): the array of tables for all 86 measurement varuables
3. tidydraft (data frame): 180 observations of 88 variables created via adply()


#### Merge in the session key ####
* I used merge() to add the session key created earlier to indicate which session a subject came from 
* Variable used include:
1. tidydraft (data frame): 180 observations of 89 variables (including session)

#### Renaming the descrptive measurements to remove all illegal characters ####
* I used gsub() to replace all illegal characters in the descriptive measurement names
* Variables used include:
1. draftnames (89-object character vector): I applied gsub() on this variable to remove unwanted characters from the columnames
2. finalnames (89-object character vector): this is the end result of the gsub() operations and are applied to the tidy dataset


#### Write tidy independent dataset ####
* I used write.table() to write the tidydraft data frame as a tab delimited .txt file called "tidyUCI.txt" in the working directory
