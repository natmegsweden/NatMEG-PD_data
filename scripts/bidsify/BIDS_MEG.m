%% MEG-BIDS, the brain imaging data structure extended to magnetoencephalography.
% MCV: CHANGE HEADER INFO IN FINAL VERSION
% 
% In this script, you will use the FieldTrip toolbox to reorganize MEG data 
% to BIDS.
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

raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data/';
if strcmp(java.lang.System.getProperty('user.name'), 'mikkel')
    bidsroot = '/home/mikkel/PD_long/data_share/temp';
    addpath('/home/mikkel/fieldtrip/fieldtrip') % Add the path
    addpath('/home/mikkel/jsonlab/jsonlab')
else
    bidsroot = '/home/igocom/BIDS';
    addpath('/home/share/fieldtrip/') % Add the path
end
ft_defaults

% temp_data_path = '/home/mikkel/PD_long/data_share/misc';
% temp_raw_path  = '/archive/20079_parkinsons_longitudinal/MEG';
        
%% Define subjects and sessions
% All subject relevant data is now stored in the 'metadata.mat' file (see
% other script how it is generated). Import and use for the bidsify loop.
     
load(fullfile(subj_data_path, 'linkdata'));
load(fullfile(subj_data_path, 'metadata'));
filenames = readtable(fullfile(subj_data_path, 'filenames.csv'), 'Delimiter', ',' );
      
subjects_and_dates = linkdata.subject_date;

%% Genral info 
n_sessions = 1;

% Common for all participants or info written to dataset_description file.
general = [];
general.method   = 'copy';
general.bidsroot = bidsroot;
general.datatype = 'meg';

general.InstitutionName                 = 'Karolinska Institute';
general.InstitutionalDepartmentName     = 'Department of Clinical Neuroscience';
general.InstitutionAddress              = 'Nobels väg 9, 171 77, Stockholm, Sweden';

general.dataset_description.Name        = 'NatMEG_PD_dataset';
general.dataset_description.BIDSVersion = 'v1.6.0';
general.dataset_description.EthicsApprovals = 'The Swedish Ethical Review Authority. DNR 2019-00542';

% MCV: MISSING FIELDS WHERE WE NEED TO FIND THE CORRECT INFO

general.meg.DewarPosition               = 'upright';    % REQUIRED. Position of the dewar during the MEG scan: "upright", "supine" or "degrees" of angle from vertical: for example on CTF systems, upright=15??, supine = 90??.
general.meg.SoftwareFilters             = 'n/a';        % REQUIRED. List of temporal and/or spatial software filters applied, orideally key:valuepairsofpre-appliedsoftwarefiltersandtheir parameter values: e.g., {"SSS": {"frame": "head", "badlimit": 7}}, {"SpatialCompensation": {"GradientOrder": Order of the gradient compensation}}. Write "n/a" if no software filters applied.
general.meg.DigitizedLandmarks          = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
general.meg.DigitizedHeadPoints         = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
general.meg.RecordingType               = 'continuous';
general.meg.ContinuousHeadLocalization  = 'true';
general.meg.PowerLineFrequency          = '50';         % REQUIRED. Frequency (in Hz) of the power grid at the geographical location of the MEG instrument (i.e. 50 or 60)

%% Run loop
for subindx=1:numel(subjects_and_dates(1:2))
  for runindx=1:n_sessions

    % Filenames
    rs_fname     = fullfile(raw_path, subjects_and_dates{subindx}, [filenames.rest_fname{subindx},'.fif']);
    go_fname     = '...';
    pam_fname    = '...';
    empty_fname  = fullfile(raw_path, subjects_and_dates{subindx}, filenames.empty_fname{subindx});
    
    % General config
    cfg = general;

    % Subject info
    cfg.sub                         = linkdata.anonym_id{subindx};
    cfg.participants.age            = metadata.agebin(subindx);
    cfg.participants.clinical_state = metadata.group(subindx);
    cfg.participants.sex            = metadata.sex(subindx);
    %cfg.participants.handedness     = handedness(i);   % THIS INFO IS MISSING

    % Recording info
    cfg.meg.AssociatedEmptyRoom = ['./sub-',linkdata.anonym_id{subindx},'_ses-',num2str(runindx),'_task-noise_proc-tsss.fif'];
    
    % Task specific info
    cfg.meg.DigitizedLandmarks  = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
    cfg.meg.DigitizedHeadPoints = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.

    % ####################################################################
    % 1) BIDSify REST data
    cfg.dataset  = rs_fname;
    cfg.run      = runindx;
    cfg.task     = 'rest';
    cfg.TaskName = 'rest';
    
    % Exceptions
    if contains(cfg.dataset, '_mc')
        cfg.proc     = 'tsss+mc';
        cfg.meg.ContinuousHeadLocalization = 'true';
    else
        cfg.proc     = 'tsss';
        cfg.meg.ContinuousHeadLocalization = 'false';
    end

    try
      data2bids(cfg);
    catch
      % this is probably because the output dataset already exists
      % this is due to running the script multiple times
      disp(lasterr)
    end
    
    % ####################################################################
    % 2) BIDSify GO data ###
    cfg.dataset  = go_fname;
    cfg.run      = runindx;
    cfg.task     = 'go';
    cfg.TaskName = 'go';
    
    % Exceptions
    if contains(cfg.dataset, '_mc')
        cfg.proc     = 'tsss+mc';
        cfg.meg.ContinuousHeadLocalization = 'true';
    else
        cfg.proc     = 'tsss';
        cfg.meg.ContinuousHeadLocalization = 'false';
    end
    
    try
      data2bids(cfg);
    catch
      disp(lasterr)
    end    

    % ####################################################################
    % 3) BIDSify PASSIVE data ###
    cfg.dataset  = go_fname;
    cfg.run      = runindx;
    cfg.task     = 'passive';
    cfg.TaskName = 'passive';
    
    % Exceptions
    if contains(cfg.dataset, '_mc')
        cfg.proc     = 'tsss+mc';
        cfg.meg.ContinuousHeadLocalization = 'true';
    else
        cfg.proc     = 'tsss';
        cfg.meg.ContinuousHeadLocalization = 'false';
    end
    
    try
      data2bids(cfg);
    catch
      disp(lasterr)
    end    
    
    % ####################################################################
    % 4) BIDSify EMPTY ROOM data
    cfg.dataset  = empty_fname;
    cfg.task     = 'noise';
    cfg.TaskName = 'noise';
    cfg.proc     = 'tsss';
    cfg.meg.DigitizedLandmarks         = 'false';    % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
    cfg.meg.DigitizedHeadPoints        = 'false';    % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
    cfg.meg.ContinuousHeadLocalization = 'false';
    cfg.meg.AssociatedEmptyRoom = [];
    
    try
      data2bids(cfg);    
    catch
      disp(lasterr)
    end
    
    clear cfg
  end % for each run
end % for each subject
