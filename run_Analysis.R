#
# 1.	Merges the training and the test sets to create one data set.
# 2.	Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.	Uses descriptive activity names to name the activities in the data set
# 4.	Appropriately labels the data set with descriptive variable names.
# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for 
#       each activity and each subject.
#

library(reshape2)
library(data.table)

#
# [Step 1] Merge the training and test data sets to create a single data set
# ==========================================================================

xtrain          <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
xtest           <- read.table("./data/UCI HAR Dataset/test/X_test.txt")

merged_data     <- rbind(xtest,xtrain)                                      

#
# [Step 2] Filter out measurements containing std and mean
# ========================================================
#
# To do this we first have to add the names of each column to the merged data set by joining 
# the features data set to the cobined test and training data set
# 

features            <- read.table("./data/UCI HAR Dataset/features.txt")
names (merged_data) = features$V2

cols_to_extract = grep("mean|std", features$V2, value=TRUE)

merged_data <- merged_data [, which(names(merged_data) %in% cols_to_extract)]

#
# [Step 3] Uses descriptive activity names to name the activities in the data set
# ============================================================================
#
# Obtain the activity_labels file and substitute these into the merged file e.g. 1 = WALKING 
# ===========================================================================================
#

ytrain            <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
ytest             <- read.table("./data/UCI HAR Dataset/test/y_test.txt")   

merged_activities <- rbind(ytest,ytrain)                                    

activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")

merged_activities <- data.frame(v1=merged_activities$V1, v4=activity_labels[match(merged_activities$V1, activity_labels$V1), 2])

names(activity_labels)   = c("Activity_Identifier", "Activity_description")
names(merged_activities) = c("Activity_Identifier", "Activity_description")

#
# [Step 4] Obtain the subject identifcation numbers for each row of data and merge all 3 files
# ============================================================================================
#

subject_train   <- read.table("./data/UCI HAR Dataset/train/subject_train.txt") 
subject_test    <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")   

merged_subjects  <- rbind(subject_test,subject_train)                           
names(merged_subjects) = "Subject_Identifier"

combined_data = cbind (merged_subjects, merged_activities, merged_data); nrow(tidy_dataset); ncol(tidy_dataset)

#
# [Step 5] Crete final tidy data set, calculate mean of each variable grouped by Subject, Activity and write output file
# ======================================================================================================================

library(reshape2)

tidy_dataset <- melt(combined_data, id = c("Subject_Identifier","Activity_Identifier","Activity_description"))

tidy_dataset <- dcast(tidy_dataset, Subject_Identifier + Activity_description ~ variable, mean)

write.table(tidy_dataset, file = "./data/tidy_dataset.txt")
