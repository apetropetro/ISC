% Defines and saves some shared settings. BE SURE TO EXECUTE this code
% AFTER EDITING, else the other programs will not see your new settings! 
% by Agustin Petroni, last edited Feb 2015

clear all

path_glob           = '/home/agustin/Desktop/adhd_children/recorded_data/';
movies_dir          = [path_glob 'movies/'];
subject_rating_file = [path_glob 'subjects_data_ratings.mat'];
behaviorfile        = [path_glob 'crossCollapse_2016-03-17_02-58-52_all.xlsx'];
                
padding_start   = 4; % 4 seconds of padding
padding_end     = 0.1; % 0.5 seconds of padding 

% define EOG and EEG channels
load([path_glob 'chan111.mat'],'chan111')
chan_eog = [1 32 8 14 17 21 25 125:128];
chan_eeg = setdiff(chan111,chan_eog); 
clear chan111 % no needed anymore
electrode_loc_file  = [path_glob 'GSN-HydroCel-129.sfp'];

% define democraphic categories we are interested in
category(1).demographic =  'DEM_002'; category(1).range = [ 1  1]; category(1).name = 'male';
category(2).demographic =  'DEM_002'; category(2).range = [ 2  2]; category(2).name = 'female';
category(3).demographic =  'DEM_002'; category(3).range = [ 1  2]; category(3).name = 'all';
category(4).demographic =  'DEM_001'; category(4).range = [ 6 11]; category(4).name = 'age-06-11';
category(5).demographic =  'DEM_001'; category(5).range = [12 17]; category(5).name = 'age-12-17';
category(6).demographic =  'DEM_001'; category(6).range = [18 44]; category(6).name = 'age-18-44';

category(7).demographic =  'DEM_001'; category(7).range = [ 6 14]; category(7).name = 'age-06-14';
category(8).demographic =  'DEM_001'; category(8).range = [15 44]; category(8).name = 'age-15-44';

category(9).demographic =  ['DEM_001'; 'DEM_002']; category(9).range  = [6 14; 1 1];  category(9).name  = 'boys-06-14';
category(10).demographic =  ['DEM_001'; 'DEM_002']; category(10).range  = [6 14; 2 2];  category(10).name  = 'girls-06-14';
category(11).demographic = ['DEM_001'; 'DEM_002']; category(11).range = [15 44; 1 1]; category(11).name = 'men-15-44';
category(12).demographic = ['DEM_001'; 'DEM_002']; category(12).range = [15 44; 2 2]; category(12).name = 'women-15-44';
conditions_to_run = [1:3 7:12]; % you may pick a subset if you dont have the time. 
 
% desired sampling rate (data will be resampled to this rate)
fs = 500;
fsref = 125; % Hz

movies(1).name='Diary of a Wimpy Kid Trailer';         movies(1).acronym='Wimpy';
movies(2).name='EHow Math';                            movies(2).acronym='Arith';
movies(3).name='Fun with Fractals';                    movies(3).acronym='Fract';
movies(4).name='Pre Algebra Lesson';                   movies(4).acronym='StudT';
movies(5).name='Reading Lesson';                       movies(5).acronym='Read';
movies(6).name='Three Little Kittens - Despicable Me'; movies(6).acronym='DesMe';
movies(7).name='Surround Suppression';                 movies(7).acronym='Flash';
movies(8).name='Resting';                              movies(8).acronym='Rest';

M=length(movies); % we expect at most 6 eeg files per subject called EEGppmerg_?.mat

save([path_glob 'settings'])% everything is needed, and what is not, we deleted already