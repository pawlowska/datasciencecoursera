#first, functions are defined to carry out the consecutive steps of reading data from files

#reads test and train data
read_raw_data <- function() {
  feat <- read.table("features.txt", header = F)
  names(feat) <- c("featureindex", "featurename")
  feat$featurename <- as.character(feat$featurename)
  
  test_raw <-read.table("test/X_test.txt", header = F)
  train_raw <-read.table("train/X_train.txt", header = F)
  raw <- rbind(test_raw, train_raw)
  names(raw) <- feat$featurename
  raw
}

#extracts means and stds
extract_relevant_data <- function() {
  #read and combine the two raw data files
  raw <- read_raw_data()
  
  #Find the indices of columns containing "mean(" or "std(" and extract the data
  nazwy <- names(raw)
  pick_index <- as.numeric(c(grep("mean\\(", nazwy), grep("std\\(", nazwy)))
  pick_index <- pick_index[order(pick_index)]
  relevant <- raw[,pick_index]

  #Remove the raw data and return only the relevant data
  rm(raw)
  relevant
}

#reads Subject and Activity information
read_labels <- function() {
  test_subjects <- read.table("test/subject_test.txt")
  train_subjects <- read.table("train/subject_train.txt")
  subjects <- rbind(test_subjects, train_subjects)
  
  test_activities<-read.table("test/y_test.txt", header = F)
  train_activities<-read.table("train/y_train.txt", header = F)
  activities <- rbind(test_activities, train_activities)
  
  l <- cbind(subjects, activities)
  names(l) <- c("SubjectID" , "ActivityID")
  activities_legend <- read.table("activity_labels.txt", header = FALSE)
  l$ActivityName <- activities_legend$V2[l$ActivityID]
  
  l
}

#all data contains the means and standard deviations 
#together with labels identifying Subject and Activity
all_data <- cbind(read_labels(), extract_relevant_data())

#s dataset contains the means of variables grouped by Subject and Activity
# in total 6x30=180 rows
require(dplyr)
s<-summarise_each(group_by(all_data, SubjectID, ActivityName), funs(mean))

