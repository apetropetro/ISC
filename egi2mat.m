% egi2mat.m
% Input: raw files
% Output EEGraw_*.mat files in each subject directory (m*).
% Requires eeglab
% by Agustin Petroni. Last edited Dec 2014

% load some shared settings
load('settings','path_glob','padding_start','padding_end');

files_eeg_all = dir([path_glob 'm*' ]);
all_names = {files_eeg_all.name};

triggers = [81:86 20];
end_triggers = [triggers(1:6)+20 20];


for i=1:length(all_names)
    pth = [path_glob all_names{i} filesep];
    
    % Only process new subjects. If there are converted files already, go to the next subject
    %if ~isempty(dir([pth 'EEGraw_*'])); continue; end
    
    raw_files = dir([pth 'm*.raw']);
    
    for j=1:length(raw_files)
        clear pEEG;
        pEEG =pop_readegi([pth raw_files(j).name], []);  % EEGLAB function for opening EGI
        
        if ~isempty(pEEG.event) % make sure there are events to analyze
            
            for k=1:length(triggers) % run through and find triggers
                
                
                idx = find([ str2double({pEEG.event.type}) ] == triggers(k));
                
                if ~isempty(idx)
                    
                    %
                    
                    if triggers(k) ~= 20 & numel(idx) == 1 % if it is a movie
                        idx_end = find([ str2double({pEEG.event.type}) ] == end_triggers(k)) % new line
                    else % if resting state
                        idx = idx(1)
                        idx_end = find([ str2double({pEEG.event.type}) ] == end_triggers(k));
                        idx_end = idx_end(end); % take the last "20" marker
                    end
                    
                    if ~isempty(idx_end)
                        
                        t=idx; % trigger index found
                        disp(['found trigger ' pEEG.event(t).type]);
                        
                        eeg = pEEG;
                        
                        
                        % zero pad the begining of the data matrix if not
                        % enough samples
                        padding = [];
                        if ((eeg.event(t).latency-padding_start*eeg.srate) < 1),
                            start_index = 1;
                            %padding = zeros(eeg.nbchan, (padding_start*eeg.srate-eeg.event(t).latency)+1 );
                            padding = repmat(eeg.data(:,start_index), 1, (padding_start*eeg.srate-eeg.event(t).latency)+1);
                        else
                            start_index = eeg.event(t).latency - padding_start*eeg.srate;
                        end
                        % Be careful here. The closing event (e.g. 101) is not always next to the opening event (in the position t + 1)
                        end_index = eeg.event(idx_end(1)).latency + padding_end*eeg.srate;
                        
                        % make new structure for the movie data
                        data = [padding eeg.data(:,start_index:end_index)];
                        
                        eeg.data = data;
                        eeg.xmax = (length(data)-1)/eeg.srate; % recalculate xmax
                        eeg.times = (0:1:(length(data)-1))/eeg.srate;
                        eeg.pnts = length(data);
                        eeg.movie_length = length(eeg.data);
                        eeg.extrapadding = size(padding,2);
                        eeg.padding_start = padding_start;
                        eeg.padding_end = padding_end;
                        
                        eeg.data(end+1,:) = 0;
                        eeg.nbchan = eeg.nbchan+1;
                        eeg = pop_chanedit(eeg,  'load',{'GSN-HydroCel-129.sfp', 'filetype', 'sfp'});
                        
                        
                        %save the movie to a mat file
                        if  k ~= 7 % if it is a movie
                            filename = [pth 'EEGraw_' num2str(rem(triggers(k), 10))];
                            disp(['saving... ' filename]);
                            save(filename, 'eeg'); % disp(['raw file' raw_files(j).name]); pause;
                        else % if it is resting state
                            filename = [pth 'EEGraw_' num2str(8)];
                            disp(['saving... ' filename]);
                            save(filename, 'eeg'); % disp(['raw file' raw_files(j).name]); pause;
                        end
                    end
                end
            end
        end
    end
end
