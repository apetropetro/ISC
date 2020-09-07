%% 3-way ANOVA. Age, gender and movie.

% October 26, 2017. Agustin Petroni

clear all; close all;

load('/home/agustin/Desktop/adhd_children/recorded_data/settings','movies_dir');

group = {'boys-06-14.mat','girls-06-14.mat','men-15-44.mat','women-15-44.mat'}; 

whichcomp = 1:3;

movies = [1 6 2:4 7]; % movie number, check documentation


sname = []; N_sub_age = [];

for c=1:4 % groups
    
    load([movies_dir 'ISCdata_category_' group{c}], 'ISC_permov','ISC_persubj','subjects');
    
    u = 0;
    
    for q = movies; 
        
        u=u+1;
    
        % ISC for group c and movie u
        comp(c,u).l = sum([ISC_persubj{q}(:,whichcomp)],2);
        
        % subject name (not used currently)
        sname(c,u).l = subjects{q};
    
    end
    
end


%% 3 way ANOVA, age, sex, movie

data = []; movie = []; age = []; sex = []; snm = {};

for c = 1:length(group)
    
    for u=1:length(movies)
        
        d = comp(c,u).l;                    % ISC data
        m = ones(length(comp(c,u).l),1)*u;  % which movie (u)
        
        if c<3, ag = ones(length(comp(c,u).l),1); else ag = ones(length(comp(c,u).l),1)*2; end         % ages
        if mod(c,2)==1, ge = ones(length(comp(c,u).l),1); else ge = ones(length(comp(c,u).l),1)*2; end  % sex
        s = sname(c,u).l; % subject name
        
        data    = [data; d];
        movie   = [movie; m];
        age     = [age; ag];
        sex     = [sex; ge];
        snm     =  [snm; s'];
    end
end

[P,T,stats] = anovan(data,{age,sex,movie}, 'model','interaction','varnames',{'Age' 'Sex' 'Movie'});
 

