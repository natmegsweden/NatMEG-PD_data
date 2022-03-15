function [dirs, subj_mri] = DS_SETUP()
% Setup PDbb2 in MATLAB
% Use: [subdat, dirs, subj_mri, filestrings] = PDbbER_SETUP()

addpath('~/PD_long/data_share/scripts')

% Paths
if ispc
%     dirs.raw_path        = '/archive/20079_parkinsons_longitudinal/MEG/';
%     dirs.meg_path        = 'X:\PD_bbER\meg_data';
    dirs.subj_data_path = 'X:\PD_long\subj_data';
    dirs.group_path     = 'X:\PD_bbER\groupanalysis';
%     dirs.raw_mri         = '/archive/20079_parkinsons_longitudinal/MRI/';
else
    dirs.raw_path       = '/archive/20079_parkinsons_longitudinal/MEG/';
%     dirs.meg_path        = '/home/mikkel/PD_bbER/meg_data';
    dirs.mriout         = '/home/mikkel/PD_long/data_share/mri_warp';
    dirs.subj_data_path = '/home/mikkel/PD_long/subj_data/';
    dirs.group_path     = '/home/mikkel/PD_long/groupanalysis';
    dirs.raw_mri        = '/archive/20079_parkinsons_longitudinal/MRI/';
    dirs.ERproj         = '/home/mikkel/PD_bbER/meg_data';
    ftpath              = '~/fieldtrip/fieldtrip'
end
addpath(ftpath)
ft_defaults 

% 
% % Read subjects
% subj_file = fullfile(dirs.subj_data_path, 'subjects_and_dates.csv');
% 
% subj_dat = readtable(subj_file);
% subj_names = table2cell(subj_dat(:,1));
% include = subj_dat(:,4);
% idxer = table2array(include)==1;
% 
% % Arrange subject id
% for ss = 1:length(subj_names)
%     subj_names{ss} = ['0', num2str(subj_names{ss})];
% end
% 
% subjects = subj_names(idxer);

% Read MRI sequence info
mri_file = fullfile(dirs.subj_data_path, 'mri_seqs.csv');

all_dat = readtable(mri_file);
subj_names = table2cell(all_dat(:,1));
mri_folder = table2cell(all_dat(:,3));

for ss = 1:length(subj_names)
    subj_names{ss} = ['0', num2str(subj_names{ss})];
end

subj_mri = [subj_names, mri_folder];

%END