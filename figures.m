%% results

% results.m produces the figures of the ISC and age manuscript.
% Last version June 1, 2017 by Agustin Petroni

clear all; close all;

if  ~exist('eeglab') % start eeglab only once so we can use topoplot
    addpath('/matlab/eeglab13_4_4b'); eeglab;
end

addpath('/home/agustin/Desktop/adhd_children/code');

load('/home/agustin/Desktop/adhd_children/recorded_data/settings','electrode_loc_file','chan_eeg','movies_dir','category','movies','behaviorfile','path_glob');

movies=[1 6 2:4 7];
path_glob           = '/home/agustin/Desktop/adhd_children/recorded_data/';
movies_dir          = [path_glob 'movies/'];
behaviorfile        = [path_glob 'crossCollapse_2016-03-17_02-58-52_all.xlsx'];


%% Figure: ISC Correlation.
% This figure shows ISC vs age for each movie

load([path_glob 'settings.mat'],'movies','behaviorfile','path_glob');

whichcomp = 1:3;

load([movies_dir 'ISCdata_category_' 'all'],'ISC_persubj','subjects');

figure();
c=0;
for v=movies
    
    c = c+1;
    subplot(2,3,c);
    behavior=loadbehavior(behaviorfile,subjects{v},{});
    
    isc=nansum(ISC_persubj{v}(:,whichcomp),2); % It is the sum of the first 3 components.

    plot(behavior(:,1),isc,'.k','MarkerSize',10);
    lsline;
    xlim([5 41]); ylim([0 max(isc)+max(isc)*0.01]);
    xlabel('Age','FontSize',16); ylabel('ISC all','FontSize',16);
    [cc, pv] = nancorrcoef(isc,behavior(:,1));
    C(c) = cc; PV(c) = pv;
    title([movies(v).acronym ': c=' num2str(cc,2) ...
        ', p=' num2str(pv,2), ', N=' num2str(sum(~isnan(behavior(:,1))))],'FontSize',9);
end


%% Figure: Spatial distribution of the components for the 4 age-sex groups.

load('/home/agustin/Desktop/adhd_children/recorded_data/settings','electrode_loc_file','chan_eeg','movies_dir','category','movies','behaviorfile','path_glob');

% get electrode locations
elocs = readlocs(electrode_loc_file, 'filetype', 'sfp');
elocs = elocs(chan_eeg);

Ncond=6;
cter = 0;
Ncomp = 3;
conditions = [9 10 11 12];

figure(); 
for c=conditions
    
    cter = cter+1;
    load([movies_dir 'ISCdata_category_' category(c).name], 'A_avg');
    maplimits = [min(A_avg(:)) max(A_avg(:))];
    for k=1:Ncomp
        if k == 1 & A_avg(9,k)  < 0; A_avg(:,k) = -A_avg(:,k); end
        if k == 2 & A_avg(9,k)  > 0; A_avg(:,k) = -A_avg(:,k); end
        if k == 3 & A_avg(72,k) > 0; A_avg(:,k) = -A_avg(:,k); end
        %
        maplimits = [min(A_avg(:,k)) max(A_avg(:,k))];
        subplot(4,Ncomp,(cter-1)*Ncomp+k);
        topoplot(A_avg(:,k),elocs,'numcontour',5,'plotrad',0.5,'electrodes','off','maplimits',maplimits);
        %         title(['C' num2str(k), ' ' category(c).name]);
    end
end


%% ISC mean and STD for the firsts 3 components

load('/home/agustin/Desktop/adhd_children/recorded_data/settings','electrode_loc_file','chan_eeg','movies_dir','category','movies','behaviorfile','path_glob');

isc = []; y = nan(50,4); isc_all = [];
s   = []; ISC = []; isc_temp = [];

for v= movies; s = [s subjects{v}]; end  % create subject list (repeated subjects, because it contains the name of the subject for EVERY movie)

for v= movies; a = ISC_persubj(v); ISC = [ISC; a{1}]; end % ISC  vector, equal size than s

[list, IA, IC] = unique(s); % IC are indices of subjects, LIST has the list of subjects for EACH GROUP 

% Now for each subject calculate the average ISC of his/her movies
for c = 1:length(IA)
    isc_all(1:3,c) = mean(ISC(IC==c,1:3),1); % average ISC
end

mean(isc_all,2)
std(isc_all')

%% Figure: ISC Correlation
% This figure shows 3 panels (3 movies) each one has ISC vs age

load('/home/agustin/Desktop/adhd_children/code/data/data/settings.mat','movies_dir','category','movies');

whichcomp = 1:3;
load([movies_dir 'ISCdata_category_' 'all'],'ISC_persubj','subjects');
beh=[]; isc=[]; c=0;

figure;
for v=1:3
    c = c+1;
    subplot(1,3,c);
    behavior=loadbehavior(behaviorfile,subjects{v},{});
    isc=nansum(ISC_persubj{v}(:,whichcomp),2);
    plot(behavior(:,1),isc,'.k','MarkerSize',10);
    lsline;
    xlim([5 24]); ylim([0 max(isc)+max(isc)*0.01]);
    xlabel('Age','FontSize',16); ylabel('ISC sum','FontSize',16);
    [cc, pv] = nancorrcoef(isc,behavior(:,1));
    C(c) = cc; PV(c) = pv;
    title([movies(v).acronym ': c=' num2str(cc,2) ...
        ', p=' num2str(pv,2), ', N=' num2str(sum(~isnan(behavior(:,1))))],'FontSize',9);
end
hold off


