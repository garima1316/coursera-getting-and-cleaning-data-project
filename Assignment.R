install.packages("reshape2")
library('reshape2')

file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file_url,destfile = "projectfile.zip")
p <- unzip(zipfile = "projectfile.zip")


# Files that will be used includes the following
# test/subject_test.txt  , test/X_test.txt  , test/y_test.txt
# train/subject_train.txt, train/X_train.txt, train/y_train.txt
# exclude the file Inertial Signals
trainfile <- list.files( "train", full.names = TRUE )[-1]
testfile  <- list.files( "test" , full.names = TRUE )[-1]

# Reading all the six files
file <- c( trainfile, testfile )
data <- lapply( file, read.table, stringsAsFactors = FALSE, header = FALSE )

# Step 1 : Merges the training and the test sets to create one data set
# rbind the train and test data by each variable
data1 <- mapply ( rbind, data[ c(1:3) ], data[ c(4:6) ] )

# data2: the whole single dataset
# column 1 = subject, column 2~562 = feature,  column 563 = activity
data2 <- do.call( cbind, data1 )
 

# Extracts only the measurements on the mean and standard deviation for each measurement.
path <- getwd()
features <- fread(file.path(path, "features.txt")
                  , col.names = c("index", "featureNames"))

featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

colnames(data2) <- c("subject", "activity", features$featureNames)

# Convert classLabels to activityName basically. More explicit. 
activityLabels <- fread(file.path(path, "activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))

data2$activity <- factor(data2$activity, levels = activityLabels[,1], labels = activityLabels[,2])
data$subject <- as.factor(data2$subject)


data2.melted <- melt(data2, id = c("subject", "activity"))
data2.mean <- dcast(data2.melted, subject + activity ~ variable, mean)

data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)

