All of the codes were created in MATLAB R2019a.

The main.m file calls the other functions that are included in the directory, which utilities are:

1.- ausentes_out: It is used to delete instances where more than one measurement is 0 (missing data).

2.- data_norm: Normalization of the data, scaling by standard deviation. 

3.- filter_data: Creates a 5th grade lowpass Butterworth filter, applying to the data. 

4.- outliers_out: Replace the outliers with the mean value plus the standard deviation.
