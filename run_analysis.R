# You should create one R script called run_analysis.R that does the following.
# 
# 1- Merges the training and the test sets to create one data set.
# 2- Extracts only the measurements on the mean and standard deviation for each measurement.
# 3- Uses descriptive activity names to name the activities in the data set
# 4- Appropriately labels the data set with descriptive variable names.
# 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Assume packages are already installed
require("data.table")
require("reshape2")
require("dplyr")

# load the libraries
library(data.table)
library(reshape2)
library(dplyr)

# assume that the zip file has been downloaded and exists in the working directory
# The description of the data set is no longer available where the course authors claim it is.
# Instead use Google's cache to find it.

# Get activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Get data for the features
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Get only the mean & s.d for the features
mean_sd_features <- grepl("mean|std", features)

# Load and process x_test & y_test data.
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Get the names for the x_test from the names for the features
names(x_test) = features

# Get just the mean & s.d just like in extract_features
x_test = x_test[,mean_sd_features]

# Make activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, x_test)

# Load and process x_train & y_train data.
x_train <- read.table("./UCI HAR Dataset/train/x_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Load subject_train data.
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Add names to x_train
names(x_train) = features

# Get the mean & s.d. from x_train
x_train = x_train[,mean_sd_features]

# Load activity data
y_train[,2] = activity_labels[y_train[,1]]

# Add names to y_train
names(y_train) = c("Activity_ID", "Activity_Label")

# Add names to subject_train
names(subject_train) = "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, x_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt",row.name=FALSE)