# Code Book

This code book summarizes the resulting data fields in `tidy_data.txt`.

This data is a summary of the mean and standard deviation observations for a
variety of signals calculated for a set of raw data collected from the accelerometers on a Samsung Galaxy S smartphone. The data was obtained from:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Raw Data file used:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

## Identifiers

* `subject_id` - The ID of the test subject
* `activity` - The type of activity performed when the corresponding measurements were taken
* `signal_domain` - The domain in which the features where processed either time or frequency
* `acceleration_component` - The acceleration signal was separated into body and gravity acceleration signals
* `measurement_device` - Type of raw signal measurement device, either accelerometer and gyroscope
* `axis` - The axis on which the signal applies
* `jerk_signal` - TRUE when the body linear acceleration and angular velocity were derived in time to obtain Jerk signals, FALSE otherwise
* `function_name` - The variable that was estimated from the processed signals
* `data_group` - the data group that this subject was in, test or train


## Measurements

* `mean` : the summarised mean of each observation for the group of observations with the same `subject_id`, `activity`, `signal_domain`, `acceleration compment`, `measurement_device`, `axis`, `jerk_signal`, `function_name` and `data_group`
* `number_observations` : the number of observations that make up the `mean`

## Activity Labels

* `WALKING` (value `1`): subject was walking during the test
* `WALKING_UPSTAIRS` (value `2`): subject was walking up a staircase during the test
* `WALKING_DOWNSTAIRS` (value `3`): subject was walking down a staircase during the test
* `SITTING` (value `4`): subject was sitting during the test
* `STANDING` (value `5`): subject was standing during the test
* `LAYING` (value `6`): subject was laying down during the test

## Signal Domain Labels

* `time` (value `1`): Time domain signals were captured at a constant rate of 50 Hz
* `frequency` (value `2`): Frequency domain signals had a Fast Fourier Transform (FFT) was applied to some of the raw signals

## Acceleration Component Labels

* `body` : The acceleration signal with the gravity component removed
* `gravity` : The acceleration signal gravity component

## Measurement Device Labels

* `accelerometer` : The raw signal was captured with an accelerometer
* `gyroscope` : The raw signal was captured with a gyroscope

## Axis Labels

* `X` (value `1`): The data applies to the X axis component
* `Y` (value `2`): The data applies to the Y axis component
* `Z` (value `3`): The data applies to the Z axis component
* `magnitude` (value `4`): The data applies to the Magnitude of these three-dimensional signals, calculated using the Euclidean norm

## Function Name Labels
* `mean`: The value summarised is the estimate of the mean
* `standard_deviation`: The value summarised is the estimate of the standard deviation