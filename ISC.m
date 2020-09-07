%% ISC.m 
% computes ISC for different subject categories
% ISC Takes movie_*_category_*.mat files and generates ISC_category_*.mat files
% by Agustin Petroni, last mod Feb 2015

% load some shared settings
load('settings','M','path_glob','category','movies_dir','fsref','conditions_to_run');

Ncomp = 4; % Number of components
Ncond = length(category); % Number of conditions
nsec = 5; % number of seconds included in time window

% for all categories in conditions_to_run
for cond = 6
    clear ISC_avg W_avg A_avg ISC_permov A_movie ISC_persubj ISC_timeresolved subjects Rpool_allM Rxy_allM Rpool_persubj Rpool_time_allmov Rpool_time Rxy_time_allmov Rxy_time Rxy_persubj
   
    % Compute covariance matricies
    for i=1:M
        
        % load data and tell us what will be taking all this time!
        filename = ['movie_' num2str(i) '_category_' category(cond).name];
        load([movies_dir filename],'mov','movie_subs'); disp(['Computing covariances for: ' filename]);
        
        % remember subjects used for this condition and movie
        subjects{i}=movie_subs;
        
        % put into proper shape
        x = permute(mov,[2 1 3]); clear mov;
        [T,D,Nsubj] = size(x);
        
        % Make permutation list for each movie: (in reality is the combination of pairs)
        permutationList = make_perm_list(Nsubj); %combinations of two elements (num of pairs x 2)
        
        % Make covariance matrices for each movie:
        [Rpool,Rxy] = make_covariance_matrices(x,D,permutationList);
        Rpool_allM(:,:,i) = Rpool;
        Rxy_allM(:,:,i) = Rxy;
        
        % Make covariance matricies for each movie, per subject:
        permList_persubj = cell(Nsubj,1);
        Rpool_M = zeros(D,D,Nsubj);
        Rxy_M = zeros(D,D,Nsubj);
        for subj = 1:Nsubj
            permList_persubj{subj} = make_perm_list(Nsubj,subj);
            [Rpool,Rxy] = make_covariance_matrices(x,D,permList_persubj{subj});
            Rpool_M(:,:,subj) = Rpool;
            Rxy_M(:,:,subj) = Rxy;
        end
        Rpool_persubj{i} = Rpool_M;
        Rxy_persubj{i} = Rxy_M;
        
        % save duration of each movie:
        ntjump(i) = floor(T/fsref)-nsec;
        Rpool_time = zeros(ntjump(i),D,D);
        Rxy_time = zeros(ntjump(i),D,D);
        % COV matrices over time
        for t=1:ntjump(i)
            TimePeriod = t*fsref+(1:nsec*fsref);
            [Rpool,Rxy] = make_covariance_matrices(x,D,permutationList,TimePeriod);
            Rpool_time(t,:,:) = Rpool;
            Rxy_time(t,:,:) = Rxy;
        end
        
        Rpool_time_allmov{i} = Rpool_time;
        Rxy_time_allmov{i} = Rxy_time;
        
        clear x
        
    end
    
    % Average Rpool and Rxy over all movies:
    Rpool_avg = sum(Rpool_allM(:,:,[1:7 9]),3)/M;
    Rxy_avg = sum(Rxy_allM(:,:,[1:7 9]),3)/M;
    
    % Compute ISC and W
    [ISC_avg,W_avg] = compute_isc(Rpool_avg,Rxy_avg,Ncomp); %

    % Compute PCA and W
    [PCA_avg,W_avg_pc] = compute_pca(Rpool_avg); %
    
    
    % Forward model scalp topography
    A_avg=Rpool_avg*W_avg*inv(W_avg'*Rpool_avg*W_avg);
    
    % Compute per movie, per subj., and per time window ISCs and forward models:
    for i = 8%1:M
        
        % Compute movie resolved ISC (ISC_permov):
        ISC_permov(i,:) = compute_isc(Rpool_allM(:,:,i),Rxy_allM(:,:,i),Ncomp,W_avg);
        % Forward model for each movie:
        A_movie(i,:,:)=Rpool_allM(:,:,i)*W_avg*inv(W_avg'*Rpool_allM(:,:,i)*W_avg);
        % Compute movie resolved PCA (PCA_permov):
        PCA_permov(i,:) = compute_pca(Rpool_allM(:,:,i));
       
        
        
        % Compute subject resolved ISC (per movie) - ISC_persubj:
        for subj = 1:size(Rpool_persubj{i},3)
            ISC_persubj{i}(subj,:) = ...
                compute_isc(Rpool_persubj{i}(:,:,subj),Rxy_persubj{i}(:,:,subj),Ncomp,W_avg);
        end
        % Compute subject resolved PCA (per movie) - PCA_persubj:
        for subj = 1:size(Rpool_persubj{i},3)
            PCA_persubj{i}(subj,:) = ...
                compute_pca(Rpool_persubj{i}(:,:,subj));
        end
        
    end
    
    % this is where we will save all the work
    iscfile=[movies_dir 'ISCdata_category_' category(cond).name];
    % save for condition
    save(iscfile,'ISC_avg','W_avg','A_avg','ISC_permov','A_movie','ISC_persubj','ISC_timeresolved','subjects')
    
end



