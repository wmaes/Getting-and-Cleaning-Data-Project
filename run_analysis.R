#
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
#

#
# Read training data
#
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = c("activity_id"))  
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = c("subject_id"))

#
# Read test data
#
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = c("activity_id"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = c("subject_id"))

#
# Extract only the measurements on the mean and standard deviation for each measurement
#
features <- read.table("./UCI HAR Dataset/features.txt")[ ,2]
# Cleanup feature names
features <-make.names(features)
meanstd <- grepl("mean|std", features)

# Set column names from features
names(X_train) <- features
names(X_test) <- features

# Select only mean and standard deviation
X_train <- X_train[, meanstd]
X_test <- X_test[, meanstd]

# Read activity labels and set in training and test sets
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[ ,2]
y_train$activity_label <- activity_labels[y_train[, 1]]
y_test$activity_label <- activity_labels[y_test[, 1]]

#
# Bind and merge data sets
#
train <- cbind(as.data.table(subject_train), y_train, X_train)
test <- cbind(as.data.table(subject_test), y_test, X_test)
data <- rbind(train, test)

#
# Create independent tidy data set with the average of each variable for each activity and each subject
#
id_cols = c("subject_id", "activity_id", "activity_label")
measure_cols = setdiff(colnames(data), id_cols)
temp_data = melt(data, id = id_cols, measure.vars = measure_cols)
tidy_data = dcast(temp_data, subject_id + activity_label ~ variable, mean)

write.table(tidy_data, file = "tidy_data.txt")
