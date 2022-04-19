%% Import subject data from database and anonymize. 
%
% <Ref>
%
% Import databases with subject id and clinical data. Generate a key for
% pseudonymization. Save as database and csv.

subj_data_path  = '/home/mikkel/PD_long/subj_data/';

% Read subjects
subj_file = fullfile(subj_data_path, 'subjects_and_dates.csv');

subj_dat = readtable(subj_file);
subj_names = table2cell(subj_dat(:,1));
tmp = subj_dat(:,4);
has_mri = table2array(tmp)==1;
recdate = (table2cell(subj_dat(:,3)));

% Remove old subjects
idxer = subj_dat{:,1} > 500;
has_mri  = has_mri(idxer);
subjects = subj_names(idxer);
recdate  = recdate(idxer);

% Arrange subject id
for ss = 1:length(subjects)
    subjects{ss} = ['0', num2str(subjects{ss})];
end

% Arrange subject and date folders
subject_date = cell(size(subjects));
for ss = 1:length(recdate)
    subject_date{ss} = fullfile(['NatMEG_',subjects{ss}], num2str(recdate{ss}));
end

%% Read other data
subj_file2 = fullfile(subj_data_path, 'subj_data_anonymised.csv');
subj_dat2 = readtable(subj_file2);

subj_names2 = table2cell(subj_dat2(:,6));
for ss = 1:length(subj_names2)
    subj_names2{ss} = ['0', num2str(subj_names2{ss})];
end

%% Generate random name order
rand_subj = randperm(numel(subjects));
anonym_id = cell(size(subjects));
for ss = 1:length(rand_subj)
    anonym_id{ss}     = num2str(rand_subj(ss) , '%03d');
end

%% Bin age data
age = table2array(subj_dat2(:,4));
agebin = cell(size(age));

for aa = 1:length(age)
    ax = age(aa);
    if 41 <= ax && ax <= 45
        agebin{aa} = '41-45';
    elseif 46 <= ax && ax <= 50
        agebin{aa} = '46-50';
    elseif 51 <= ax && ax <= 55
        agebin{aa} = '51-55';
    elseif 56 <= ax && ax <= 60
        agebin{aa} = '56-60';       
    elseif 61 <= ax && ax <= 65
        agebin{aa} = '61-65';
    elseif 66 <= ax && ax <= 70
       agebin{aa} = '66-70';
    elseif 71 <= ax && ax <= 75
       agebin{aa} = '70-75';
    elseif 76 <= ax && ax <= 80
       agebin{aa} = '76-80';      
    end
end

%% Fix variables
group = table2array(subj_dat2(:,1));
for gg = 1:numel(group)
    if strcmp(group{gg}, 'Control ')
        group{gg} = 'Control';
    elseif strcmp(group{gg}, 'Patient ')
        group{gg} = 'Patient';
    end
end

sex = table2array(subj_dat2(:,5));
for gg = 1:numel(group)
    if strcmp(sex{gg}, 'F ')
        sex{gg} = 'F';
    elseif strcmp(sex{gg}, 'M ')
        sex{gg} = 'M';
    end
end

MoCA = table2array(subj_dat2(:,7));
FAB = table2array(subj_dat2(:,8));
BDI = table2array(subj_dat2(:,9));

%% ###########################
% MISSING UPDRS DATA
% MISSING LEDD DATA
% MISSING DISEASE DURATION
% Possibly add this manually to CSV file or combine in other script.

%% Combine as table
linkdata = table(subjects, subject_date, anonym_id);
metadata = sortrows(table(anonym_id, sex, agebin, group, MoCA, FAB, BDI));

%% Save
save(fullfile(subj_data_path, 'metadata'), 'metadata');
writetable(metadata, fullfile(subj_data_path,'metadata.csv'))
save(fullfile(subj_data_path, 'linkdata'), 'linkdata');
writetable(linkdata, fullfile(subj_data_path,'linkdata.csv'))
disp('done')
%END