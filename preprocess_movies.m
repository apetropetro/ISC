% preprocess_movies.m
% by Agustin Petroni on November 2014. Last mod March 2015
% Input:  'EEGraw_' files created in egi2mat.m
% Output: 'EEGppmerg_' files

clear all;
addpath(genpath('~/matlab/inexact_alm_rpca'));

% load some shared settings
load('settings','path_glob','fs','fsref','chan_eog','chan_eeg','padding_start','padding_end');


% mean movie duration at 500Hz and fsref (desired length for all)
mean_samples = [61044	47240	139452	52410	87932	87621 nan 62224]-(padding_start+padding_end)*fs;
mean_samples_new = round(mean_samples/500*fsref);

% directories with subject data
subfiles = dir([path_glob 'm*' ]);

% for all subjects
for nn = 1:length(subfiles)
    
    subjdir = [path_glob subfiles(nn).name filesep];
    
    % Only process new subjects. If there are preprocessed files already, go to the next subject
        if ~isempty(dir([subjdir 'EEGppmerg_*'])); continue; end
    
    % EEG files for this subjects
    eegfiles = dir([subjdir 'EEGraw_*']);
    
    % things to keep track for every eegfile processed
    video_nrs=[]; duration = [];
    
    for w = 1:length(eegfiles)
        
        % which video are we loading
        video_number = str2num(eegfiles(w).name(8));
        
        % load eeg data for that video
        load([subjdir eegfiles(w).name]);
        fs=eeg.srate;
        padding = eeg.extrapadding;
        eeg = double(eeg.data)';
        
        
        % tell user which subject and video are being processed.
        str=['Subject ' num2str(nn) ': ' subfiles(nn).name ', video: ' num2str(video_number)];
        disp(str)
        
        % only select movies with difference less than 100ms from mean
        deviation = length(eeg)-(padding_start+padding_end)*fs-mean_samples(video_number);
        if abs(deviation)> fs*10%0.800
            disp([num2str(video_number) ' not processed, length off by (s):' num2str(deviation/fs)]);
        else
            
            % replace padded zeros (if any) with first valid sample to avoid filter-transients
            eeg(1:padding,:) = repmat(eeg(padding+1,:), [padding 1]);
      
            % Filter
            eeg = eeg-repmat(eeg(1,:),[length(eeg) 1]);
            [b,a]=butter(4,       1/(fs/2),'high'); eeg = filter(b,a,eeg);
            [b,a]=butter(4,[58 61]./(fs/2),'stop'); eeg = filter(b,a,eeg);
            
            % downsample
            eeg = resample(eeg,fsref,fs);
            
            % Cut tails
            eeg = eeg(round(padding_start*fsref)+1:end-round(padding_end*fsref),:);
            
            % Standartize length
            new = mean_samples_new(video_number)-1; old=length(eeg)-1;
            eeg=interp1((0:old)',eeg,(0:new)'/new*old);
            
            % EOG removal
            eog = eeg(:,chan_eog);
            eeg = eeg(:,chan_eeg);
            eog = eog(:,find(sum(eog)~=0)); % exclude eog channels == 0
            eeg = eeg - eog * (eog\eeg);
          
            duration(end+1) = length(eeg);
            video_nrs(end+1) = video_number;
            
            eeg = inexact_alm_rpca(eeg);
            eeg = eeg';
            
            % Final clean: Replace channel outliers with zeros
            for i=1:size(eeg,1) % loop each chan
                threshold = 3*std(eeg(i,:)); %
                eeg(i,eeg(i,:)>=  threshold) = 0;
                eeg(i,eeg(i,:)<= -threshold) = 0;
            end

            % common mean subtraction:
            mask=eeg~=0;
         
            save([subjdir 'EEGppmerg_' num2str(video_number)],'eeg','fs','chan_eeg');
           
        end
       
    end
   
end