# ISC
Inter Subject Correlation of the EEG signal while voluntaries watched short movies. Consistency of EEG signal vs age.
See https://www.eneuro.org/content/5/1/ENEURO.0244-17.2017

settings.m 
Writes global settings for the analysis

egi2mat.m 
Imports EGI data and extract "epochs" with movie data.
Input: raw files
Output EEGraw_*.mat files in each subject directory.
Requires eeglab

preprocess_movies.m
Preprocess the EEG signal

ISC.m
Computes ISC for different subject categories (age and sex)

compute_isc.m
Computes ISC

three_way_anova.m
Runs 3-way ANOVA (ages, sex, movie)

figures.m
Produces figures

