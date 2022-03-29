%% MEG-BIDS, the brain imaging data structure extended to magnetoencephalography.
% MCV: CHANGE HEADER INFO IN FINAL VERSION
% 
% In this script, you will use the FieldTrip toolbox to reorganize MEG data 
% to BIDS.
% 
% 
% 
% *1.Define the paths and toolboxes at the beginning of the script*
% 
% If you have several versions of FieldTrip or have used other toolboxes before 
% you run this script, it is also a good idea to restore the PATH. Next, use the 
% MATLAB function |addpath( ... )| to add the path where you downloaded FieldTrip.

% If you have several variables with the same names, it might also be good close 
% all open windows and clear all figures and variables from your workspace.

close all       % Close all open windows
clear all       % Clear all variables from the workspace
restoredefaultpath
% addpath('/home/igocom/fieldtrip/') % Add the path
addpath('~/fieldtrip/fieldtrip') % Add the path
ft_defaults

raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
meg_path        = '/home/mikkel/PD_long/data_share/temp';
% meg_path       = '/home/igocom/PD_data_test';
subj_data_path  = '/home/mikkel/PD_long/subj_data/';
bidsroot        = '/home/mikkel/PD_long/data_share/temp'; 

%% 
% 
% 
% *2.Store data separate by subject and session*
% 
% You can setup subject and recording specific paths as below 

%% Define subjects and sessions

% subjects_and_dates = {
%                 'NatMEG_0521/190417/'
%                 'NatMEG_0522/190426/'
%                 'NatMEG_0523/190429/'
%                 'NatMEG_0524/190429/'
% 
%              };
% 
% subjects =  {
%                 'NatMEG_0521'
%                 'NatMEG_0521'
%                 'NatMEG_0521'
%                 'NatMEG_0521'
%             };
%                 
% filenames = {
%         'rest_ec_mc_avgtrans_tsss_corr95.fif'
%         'rest_ec_mc_avgtrans_tsss_corr95.fif'
%         'rest_ec_mc_avgtrans_tsss_corr95.fif'
%         'rest_ec_mc_avgtrans_tsss_corr95.fif'
%         
%             };
        
%% Define subjects and sessions - NEW
% All subject relevant data is now stored in the 'alldata.mat' file (see
% other script how it is generated). Import and use for the bidsify loop.
     
load(fullfile(subj_data_path, 'alldata'));
       
subjects_and_dates = alldata.subject_date;

%% 
% *Run loop*
n_sessions = 1;

%% Genral info 
% Common for all participants or info written to dataset_description file.
general = [];
general.method = 'copy'; % the original data is in a BIDS-compliant format and can simply be copied
general.bidsroot = bidsroot;

general.InstitutionName                 = 'Karolinska Institute';
general.InstitutionalDepartmentName     = 'Department of Clinical Neuroscience';
general.InstitutionAddress              = 'Nobels väg 9, 171 77, Stockholm, Sweden';
general.dataset_description.Name        = 'NatMEG_PD_database';
general.dataset_description.BIDSVersion = 'v1.5.0';

cfg.coordsystem.MEGCoordinateSystem     = 'Neuromag';



% MCV: MISSING FIELDS WHERE WE NEED TO FIND THE CORRECT INFO
% general.dataset_description.EthicsApprovals =    % ???
% cfg.meg.DewarPosition                 = 'upright'; % REQUIRED. Position of the dewar during the MEG scan: "upright", "supine" or "degrees" of angle from vertical: for example on CTF systems, upright=15??, supine = 90??.
% cfg.meg.SoftwareFilters               = 'n/a'; % REQUIRED. List of temporal and/or spatial software filters applied, orideally key:valuepairsofpre-appliedsoftwarefiltersandtheir parameter values: e.g., {"SSS": {"frame": "head", "badlimit": 7}}, {"SpatialCompensation": {"GradientOrder": Order of the gradient compensation}}. Write "n/a" if no software filters applied.
% cfg.meg.DigitizedLandmarks            = 'true'; % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
% cfg.meg.DigitizedHeadPoints           = 'true'; % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
% cfg.events = ???  %MCV: I am not sure how to add this info. The values
% are 1 = start, 64 = stop. Though not all have 
% MCV: OTHER FIELDS/ISSUES WE NEED TO FIGURE OUT
%cfg.meg.MaxMovement =           % Maxfilter is applied? FT does not read this from file?
%cfg.meg.AssociatedEmptyRoom =  % Empty room files??

%% Run loop
for subindx=1:numel(subjects_and_dates)
  for runindx=1:n_sessions
%     d = dir(sprintf('/home/igocom/PD_data_test/NatMEG_0521/190417/rest_ec_mc_avgtrans_tsss_corr95.fif', subjects{subindx}, runindx));
    d = find_files(fullfile(raw_path, subjects_and_dates{subindx}), 'rest_ec_mc_avgtrans_tsss_corr95');
    if isempty(d)
      % for most subjects the data was recorded in a single run
      % in that case run 2 does not exist
      continue
    else
      origname = fullfile(raw_path, subjects_and_dates{subindx}, d{1});
%       anonname = fullfile(raw_path, sprintf('%s_%d.fif', alldata.anonym_id{subindx}, runindx));
%       disp(anonname); % this is just an intermediate name, the final name will be assigned by data2bids
    end
    
    cfg = general;
%     cfg.bidsroot = '/home/igocom/bids';  % write to the present working directory
    cfg.sub      = alldata.anonym_id{subindx};
    cfg.task     = 'rest';
    cfg.TaskName = 'rest';
%     cfg.run      = runindx;
    cfg.dataset  = origname; % this is the intermediate name
    cfg.datatype = 'meg';
    
    cfg.participants.age = alldata.agebin(subindx);
%     cfg.participants.handedness = handedness(i);   % THIS INFO IS MISSING
    cfg.participants.clinical_state = alldata.group(subindx);
    cfg.participants.sex = alldata.sex(subindx);
  
    try
      data2bids(cfg);
    catch
      % this is probably because the output dataset already exists
      % this is due to running the script multiple times
      disp(lasterr)
    end
    
    
  end % for each run
end % for each subject
