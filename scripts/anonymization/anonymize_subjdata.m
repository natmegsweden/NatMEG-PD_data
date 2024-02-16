%% Import subject data from database and anonymize. 
%
% Import databases with subject id and filepaths. Generate a key for
% pseudonymization. Save as database and csv. NB! This script should only
% ever be run once to generate the key. Otherwise we have to redo the
% entire procedure with a new random key.

% Should the process overwite existing linkdata? If yes, then all previous
% BIDSification will be invalid!
%
% For information about NatMEG-PD please refer to the data descriptor:
%
% Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., 
% 	 Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2024). The 
%   Swedish National Facility for Magnetoencephalography Parkinson's disease dataset.
%   Scientific Data, 11(1), 150. https://doi.org/10.1038/s41597-024-02987-w
%
% The NatMEG-PD data is available through at the following location:
%   https://search.kg.ebrains.eu/instances/d55146e8-fc86-44dd-95db-7191fdca7f30
%
overwrite = 0;

%% Read data
% raw data file
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

%% Generate random name order
rand_subj = randperm(numel(subjects));
anonym_id = cell(size(subjects));
for ss = 1:length(rand_subj)
    anonym_id{ss}     = num2str(rand_subj(ss) , '%03d');
end

%% Combine as table
linkdata = sortrows(table(anonym_id, subject_date, subjects));

%% Save
if overwrite
    save(fullfile(subj_data_path, 'linkdata'), 'linkdata');
    writetable(linkdata, fullfile(subj_data_path,'linkdata.csv'))
    disp('done'); 
end

%END
