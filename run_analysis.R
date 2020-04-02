## run_analysis.R
##
## run_analysis.R does the following with this raw data
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each
## measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set
## with the average of each variable for each activity and each subject.

library(dplyr)

# download zip file containing data if it hasn't already been downloaded
zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFile <- "UCI HAR Dataset.zip"

if (!file.exists(zipFile)) {
  download.file(zipUrl, zipFile, mode = "wb")
}

# unzip zip file containing data if data directory doesn't already exist
dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
  unzip(zipFile)
}

## read test and train data set
datasets <- c("test","train")

##read subject_"test|train".txt into subjects list with factors for data set
subjects <- datasets %>%
  paste(dataPath,"\\",.,"\\subject_",.,".txt",sep="") %>%
  lapply(read.table)
names(subjects)<-datasets

##read X_"test|train".txt into values list with factors for data set
values <- datasets %>%
  paste(dataPath,"\\",.,"\\X_",.,".txt",sep="") %>%
  lapply(read.table)
names(values)<-datasets

##read y_"test|train".txt into activity list with factors for data set
activity <- datasets %>%
  paste(dataPath,"\\",.,"\\y_",.,".txt",sep="") %>%
  lapply(read.table)
names(activity)<-datasets

## NB: InterialSignals have been excluded for data set
inertialSignalsRequired <- FALSE
#inertialSignalsRequired <- TRUE
if(inertialSignalsRequired)
{
  ## dataset c("test","train)
  signal <- c("body_acc","body_gyro","total_acc")
  axes <- c("x","y","z")
  filepath <- NULL
  
  for(i in signal)
    for(j in axes)
    {
      for(k in datasets)
      {
        filename <- paste(dataPath,"\\",k,"\\Inertial Signals\\",i,"_",j,"_",k,".txt",sep="")
        varname2 <- paste(i,"_",j,"_",k,sep="")
        assign(varname2,read.table(filename))
      }
    }
}

## read features, don't convert text labels to factors by contains duplicates
features <- read.table(file.path(dataPath, "features.txt"), col.names = c("featureId","featureName"), stringsAsFactors = FALSE)
## note: feature names (in features[, 2]) are not unique
##       e.g. fBodyAcc-bandsEnergy()-1,8
## 
## to be unqiue and consistent features.txt should be
## 303 fBodyAcc-bands()-1,8   303 fBodyAcc-bands()-X,1,8
## 317 fBodyAcc-bands()-1,8   317 fBodyAcc-bands()-Y,1,8
## 331 fbodyAcc-bands()-1,8   331 fBodyAcc-bands()-Z,1,8
##
## the same applies to each of the 14 frequency intervals where the FFT
## was applied on the frequency domain variables :
## fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ

## this function will remove duplcate feature names
tidy_duplicate_features <-function() {
  featuredups <- grep("bandsEnergy",features$featureName)
  dups <- features[featuredups,]
  # 14 frequency intervals for fft and 3 axes XYZ
  instances <- nrow(dups) / (3 * 14)
  for(i in 1:instances)
  {
    dups[((i-1)*(3 * 14)+1:14),2] <- gsub("\\(\\)\\-","\\(\\)-X,",dups[((i-1)*(3 * 14)+1:14),2])
    dups[((i-1)*(3 * 14)+15:28),2] <- gsub("\\(\\)\\-","\\(\\)-Y,",dups[((i-1)*(3 * 14)+15:28),2])
    dups[((i-1)*(3 * 14)+29:42),2] <- gsub("\\(\\)\\-","\\(\\)-Z,",dups[((i-1)*(3 * 14)+29:42),2])
  }
  features[featuredups,] <- dups

  if(sum(duplicated(features$featureName)))
    stop("Duplicates")
  
  features
}

## We do not require the fft data, so no need to tidy the fft data
## uncomment function call to tidy_duplicate_features() below, if you
## require tidy fft bandsEnergy feature names
##
# features <- tidy_duplicate_features()

## read activity labels
activities <- read.table(file.path(dataPath, "activity_labels.txt"), col.names = c("activityId", "activityLabel"))

## 1. Merge the test and the train sets to create one long data set
##    add the variable data_group "test" or "train" to identify data set
subjects <- bind_rows(subjects,.id="data_group")
names(subjects)<-c("data_group","subject_id")

values <- bind_rows(values)
names(values) <- c(features$featureName)

activity <- bind_rows(activity)
names(activity) <- c("activity")

## join the three data files together
## subject_"test|train".txt   X_"test|train".txt    y_"test|train.txt
## subjects                   values                activity
subjectActivity <- bind_cols( subjects,values,activity )

freeMemory <- TRUE    ## Free up working memory
# freeMemory <- FALSE ## remove comment to keep complete data

## only bind inertialSignals if they are required
if(inertialSignalsRequired)
{
  body_acc_x <- bind_rows(test = body_acc_x_test, train = body_acc_x_train)
  body_acc_y <- bind_rows(test = body_acc_y_test, train = body_acc_y_train)
  body_acc_z <- bind_rows(test = body_acc_z_test, train = body_acc_z_train)
  body_acc <- bind_cols(x = body_acc_x, y = body_acc_y, z = body_acc_z )
  if(freeMemory)
    rm(body_acc_x,body_acc_y,body_acc_z)
  body_gyro_x <- bind_rows(test = body_gyro_x_test, train = body_gyro_x_train)
  body_gyro_y <- bind_rows(test = body_gyro_y_test, train = body_gyro_y_train)
  body_gyro_z <- bind_rows(test = body_gyro_z_test, train = body_gyro_z_train)
  body_gyro <- bind_cols(x = body_gyro_x, y = body_gyro_y, z = body_gyro_z)
  if(freeMemory)
    rm(body_gyro_x,body_gyro_y,body_gyro_z)
  total_acc_x <- bind_rows(test = total_acc_x_test, train = total_acc_x_train)
  total_acc_y <- bind_rows(test = total_acc_y_test, train = total_acc_y_train)
  total_acc_z <- bind_rows(test = total_acc_z_test, train = total_acc_z_train)
  total_acc <- bind_cols(x = total_acc_x, y = total_acc_y, z = total_acc_z)
  if(freeMemory)
    rm(total_acc_x,total_acc_y,total_acc_z)
  subjectActivity <- bind_cols( subjects,values,activity,body_acc,body_gyro,total_acc )
}


## 2. Extract only the measurements on the mean and standard deviation
##
## determine columns of data set to keep based on column name...
## subject - subject_id
## activity - activity = id (refers to activities data frame)
## data_group - test or train data gorup
## mean( - the mean() variables NB: not meanFreq
## std - the std() standard deviation variables

columnsToKeep <- grepl("subject|activity|data_group|mean\\(|std", colnames(subjectActivity))

## Keep only data in these columns
subjectActivityNew <- subjectActivity[, columnsToKeep]

freeMemory <- TRUE    ## Free up working memory
# freeMemory <- FALSE ## remove comment to keep complete data
if(freeMemory)
{
  rm(subjectActivity, subjects, values, activity)
  if(inertialSignalsRequired)
  {
    rm(body_acc,body_gyro,total_acc)
  }
}

## 3. Use descriptive activity names to name the activities in the data set

## replace activity values with named factor levels
subjectActivityNew$activity <- factor(subjectActivityNew$activity, levels = activities[, 1], labels = activities[, 2])

## 4. Appropriately label the data set with descriptive variable names

## replace column namess with duplicate BodyBody with Body
## this is an error that does not match the features_info.txt
colnames(subjectActivityNew) <- gsub("BodyBody", "Body", colnames(subjectActivityNew))

## complete data set has 10,299 * 561 = 5,777,739 observations of which
## we use 10,299 * 66 = 679,734 observations, therefore
## to debug code using only a few observations :
## uncomment line below: smallSetTest <- TRUE; testRows <- (number of rows)
smallSetTest <- FALSE
#smallSetTest <- TRUE; testRows <- 2
if(smallSetTest)
  subjectActivityNew <- subjectActivityNew[1:testRows,]

## domain c("time","frequency")
timeDomainColumns <- grepl("^t",colnames(subjectActivityNew))
frequencyDomainColumns <-   grepl("^f",colnames(subjectActivityNew))
timeDomain <- subjectActivityNew[,timeDomainColumns|!(timeDomainColumns|frequencyDomainColumns)]
frequencyDomain <- subjectActivityNew[,frequencyDomainColumns|!(timeDomainColumns|frequencyDomainColumns)]
names(timeDomain) <- gsub("^t","",names(timeDomain))
names(frequencyDomain) <- gsub("^f","",names(frequencyDomain))
subjectActivityNew <- bind_rows("time" = timeDomain,"frequency" = frequencyDomain, .id="signal_domain")
subjectActivityNew$signal_domain <- factor(subjectActivityNew$signal_domain, labels = c("time","frequency"), levels = c("time","frequency"))
if(freeMemory)
  rm(timeDomain,frequencyDomain)

#functions c("std",mean") subset of c("std","mad", "max","min","sma","energy","iqr","entropy","arCoeff","correlation","maxInds","meanFreq","skewness","kurtosis","bandsEnergy","angle")
meanColumns <- grepl("mean", colnames(subjectActivityNew))
stdColumns <- grepl("std", colnames(subjectActivityNew))

means <- subjectActivityNew[,meanColumns|!(meanColumns|stdColumns)]
stds <- subjectActivityNew[,stdColumns|!(meanColumns|stdColumns)]
names(means) <- gsub("-mean\\(\\)","",names(means))
names(stds) <- gsub("-std\\(\\)","",names(stds))
subjectActivityNew <- bind_rows("mean" = means,"std" = stds,.id="function_name")
if(freeMemory)
  rm(means,stds)

## axes c("X","Y","Z")
xAxisColumns <-grepl("-X$",colnames(subjectActivityNew))
yAxisColumns <-grepl("-Y$",colnames(subjectActivityNew))
zAxisColumns <-grepl("-Z$",colnames(subjectActivityNew))
magColumns <- grepl("Mag",colnames(subjectActivityNew))

if(sum(xAxisColumns&yAxisColumns&zAxisColumns&magColumns))
  stop("Not unique axis columns")

xAxis <- subjectActivityNew[,xAxisColumns|!(xAxisColumns|yAxisColumns|zAxisColumns|magColumns)]
yAxis <- subjectActivityNew[,yAxisColumns|!(xAxisColumns|yAxisColumns|zAxisColumns|magColumns)] 
zAxis <- subjectActivityNew[,zAxisColumns|!(xAxisColumns|yAxisColumns|zAxisColumns|magColumns)]
magnitudeAxes <- subjectActivityNew[,magColumns|!(xAxisColumns|yAxisColumns|zAxisColumns|magColumns)]

names(xAxis) <- gsub("-X$","",names(xAxis))
names(yAxis) <- gsub("-Y$","",names(yAxis))
names(zAxis) <- gsub("-Z$","",names(zAxis))
names(magnitudeAxes) <- gsub("Mag","",names(magnitudeAxes))

subjectActivityNew <- bind_rows("X" = xAxis,"Y" = yAxis, "Z" = zAxis,"Magnitude" = magnitudeAxes,.id="axis")
subjectActivityNew$axis <- factor(subjectActivityNew$axis, labels = c("X","Y","Z","Magntiude"), levels= c("X","Y","Z","Magnitude"))
if(freeMemory)
  rm(xAxis,yAxis,zAxis,magnitudeAxes)

## acceleration signals c("Body","Gravity")
bodyColumns <-  grepl("Body",colnames(subjectActivityNew))
gravityColumns <-  grepl("Gravity",colnames(subjectActivityNew))
bodySignal <- subjectActivityNew[,bodyColumns|!(bodyColumns|gravityColumns)]
gravitySignal <- subjectActivityNew[,gravityColumns|!(bodyColumns|gravityColumns)]
names(bodySignal) <- gsub("Body","",names(bodySignal))
names(gravitySignal) <- gsub("Gravity","",names(gravitySignal))
subjectActivityNew <- bind_rows("Body" = bodySignal,"Gravity" = gravitySignal, .id="acceleration_component")
if(freeMemory)
  rm(bodySignal,gravitySignal)

## Jerk signal
jerkColumns <-  grepl("Jerk",colnames(subjectActivityNew))
tidyColumns <- !grepl("Acc|Gyro",colnames(subjectActivityNew))
jerkSignal <- subjectActivityNew[,jerkColumns|tidyColumns]
names(jerkSignal) <- gsub("Jerk","",names(jerkSignal))
subjectActivityNew <- bind_rows("FALSE" = subjectActivityNew[!jerkColumns],"TRUE" = jerkSignal,.id="jerk_signal")
if(freeMemory)
  rm(jerkSignal)

## meaurement device c("Accelerometer","GyroScope")
accColumns <-  grepl("Acc",colnames(subjectActivityNew))
gyroColumns <-  grepl("Gyro",colnames(subjectActivityNew))
accDevice <- subjectActivityNew[,accColumns|!(accColumns|gyroColumns)]
gyroDevice <- subjectActivityNew[,gyroColumns|!(accColumns|gyroColumns)]
names(accDevice) <- gsub("Acc","value",names(accDevice))
names(gyroDevice) <- gsub("Gyro","value",names(gyroDevice))
subjectActivityNew <- bind_rows("Accelerometer" = accDevice,"Gyroscope" = gyroDevice, .id="measurement_device")
if(freeMemory)
  rm(accDevice,gyroDevice)

subjectActivityNew <- subjectActivityNew[!is.na(subjectActivityNew$value),]

## 5. Create a second, independent tidy set with the average of each
##    variable for each activity and each subject

## group by subject and activity and summarise using mean
subjectActivityMeans <- subjectActivityNew %>%
  group_by(subject_id, activity, signal_domain, acceleration_component,
           measurement_device, axis, jerk_signal, function_name, data_group) %>%
  summarise(mean = mean(value), number_observations=n())

## output to file "tidy_data.txt" Step 5. data
write.table(subjectActivityMeans, "tidy_data.txt", row.names = FALSE, 
            quote = FALSE)

## output to file "tidy_data_set.txt" Step 4. data
writeTidyDataSet <- TRUE
if(writeTidyDataSet)
  write.table(subjectActivityNew, "tidy_data_set.txt", row.names = FALSE, 
            quote = FALSE)

## output to file "tidy_data_set_complete.txt" Step 3. data
if(writeTidyDataSet && !freeMemory)
  write.table(subjectActivity, "tidy_data_set_complete.txt", row.names = FALSE, 
              quote = FALSE)
