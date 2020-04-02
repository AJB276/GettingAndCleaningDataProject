# Getting and Cleaning Data - Course Project

This is the course project for the Getting and Cleaning Data Coursera course.
The R script, `run_analysis.R`, does the following:

`Data Set`
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

1. Download the dataset if it does not already exist in the working directory
2. Extracts the data from the zip file if it has not already been extracted
3. Load the activity and feature info as described in the `readme.txt` found in the data directory `UCI HAR Dataset`
4. Loads both the training and test datasets, keeping only those columns which
   reflect a mean or standard deviation
5. Loads the activity and subject data for each dataset, and merges those
   columns with the dataset
6. Merges the two datasets
7. creates a new variable `data_group` to identify from where the data in dataset originates
8. Tidy the variables found in the data columns by createing new variables
  (see CodeBook.md)
  i.    `signal_domain`
  ii.   `acceleration_component`,
  iii.  `measurement_device`
  iv.   `axis`
  v.    `jerk_signal`
  vi.   `function_name` 
9. Converts the `activity`, `subject_id`, `signal_domain`, `acceleration_component`, `measurement_device`, `axis`, `jerk_signal` and `function_name` columns into factors
10. Creates a tidy dataset that consists of the average (mean) value of each
   variable for each subject and activity pair.

The end result is shown in the file `tidy_data.txt`.