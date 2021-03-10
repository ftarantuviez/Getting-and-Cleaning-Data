
### Downloading data

if(!dir.exists("datasets")) {
  dir.create("datasets")
  datasetURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url = datasetURL, destfile = "datasets/Dataset.zip", method = "curl")
  
  unzip("datasets/Dataset.zip", exdir="./data")
  
}


### Reading data

path_rf <- "datasets"

dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)


### Merging into a respective dataset

activityData <- rbind(dataActivityTest, dataActivityTrain)
subjectData <- rbind(dataSubjectTest, dataSubjectTrain)
featuresData <- rbind(dataFeaturesTest, dataFeaturesTrain)

names(activityData) <- "activity"
names(subjectData) <- "subject"
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(featuresData)<- dataFeaturesNames$V2


### 1. MERGES THE TRAINING AND THE TEST SETS TO CREATE ONE DATA SET.

dataset <- cbind(featuresData, subjectData)
dataset <- cbind(dataset, activityData)


### 2. Extracts only the measurements on the mean and standard deviation for each measurement

subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
dataset<-subset(dataset,select=selectedNames)

### 3. Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
dataset$activity<-factor(dataset$activity);
dataset$activity<- factor(dataset$activity,labels=as.character(activityLabels$V2))

### 4. Appropriately labels the data set with descriptive variable names

names(dataset)<-gsub("^t", "time", names(dataset))
names(dataset)<-gsub("^f", "frequency", names(dataset))
names(dataset)<-gsub("Acc", "Accelerometer", names(dataset))
names(dataset)<-gsub("Gyro", "Gyroscope", names(dataset))
names(dataset)<-gsub("Mag", "Magnitude", names(dataset))
names(dataset)<-gsub("BodyBody", "Body", names(dataset))

### 5. Creates a second,independent tidy data set and output it

if(require(plyr) == F){
  install.packages("plyr")
}
library(plyr)

data_to_export <-aggregate(. ~subject + activity, dataset, mean)
data_to_export <- data_to_export[order(data_to_export$subject,data_to_export$activity),]
write.table(data_to_export, file = "tidydata.txt",row.name=FALSE)
