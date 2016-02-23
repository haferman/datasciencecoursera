
# load libraries
library(data.table)
library(dplyr)

setwd("/home/haferman/Z-R")
dirname <- "UCI HAR Dataset"

# get data if necessary
if (file.exists(dirname)){
  cat(dirname, "exists, we're going to assume the data has already been downloaded")
} else {
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, "./UCI-HAR-dataset.zip")
  unzip("./UCI-HAR-dataset.zip")              
}

setwd(dirname)

# Step 1: merge the training and test datasets into one dataset.
subject_train <- read.table("./train/subject_train.txt", header = FALSE)
y_train <- read.table("./train/y_train.txt", header = FALSE)
x_train <- read.table("./train/X_train.txt", header = FALSE)
subject_test <- read.table("./test/subject_test.txt", header = FALSE)
y_test <- read.table("./test/y_test.txt", header = FALSE)
x_test <- read.table("./test/X_test.txt", header = FALSE)

subject_merge <- rbind(subject_train, subject_test)
y_merge <- rbind(y_train, y_test)
x_merge <- rbind(x_train, x_test)

features <- read.table("./features.txt")
names(subject_merge) <- "subject"
names(x_merge) <- features$V2
names(y_merge) <- "activity"

alldata <- cbind(x_merge, y_merge, subject_merge)

# Step 2: Extract only the measurements on the mean and standard
# deviation for each measurement.
colnums <- grep(".*mean.*|.*std.*", features$V2, ignore.case=TRUE)
colnames <- features$V2[colnums]
selected <- c(as.character(colnames), "subject", "activity")
data <- subset(alldata, select=selected)

# Step 3: Uses descriptive activity names to name the activities 
# in the data set
activity_labels <- read.table("./activity_labels.txt", header = FALSE)
num_labels <- dim(activity_labels)[1]
data$activity <- as.character(data$activity)
for (i in 1:num_labels){
  data$activity[data$activity == i] <- as.character(activity_labels[i,2])
}
data$activity <- as.factor(data$activity)

# Step 4: Appropriately label the data set with descriptive 
# variable names
names(data)<-gsub("^t", "time", names(data))
names(data)<-gsub("^f", "frequency", names(data))
names(data)<-gsub("std()", "SD", names(data))
names(data)<-gsub("mean()", "Mean", names(data))
names(data)<-gsub("Acc", "Accelerometer", names(data))
names(data)<-gsub("Gyro", "Gyroscope", names(data))
names(data)<-gsub("Mag", "Magnitude", names(data))
names(data)<-gsub("BodyBody", "Body", names(data))
names(data)<-gsub("tBody", "TimeBody", names(data))

# Step 5: From the data set in step 4, create a second, 
# independent tidy data set with the average of each variable 
# for each activity and each subject
tidydata <-aggregate(. ~subject + activity, data, mean)
tidydata <-tidydata[order(tidydata$subject,tidydata$activity),]
write.table(tidydata, file = "./tidyout.txt",row.names=FALSE)



