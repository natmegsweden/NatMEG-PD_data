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
    bidsroot  = '/home/mikkel/PD_long/data_share/temp';
    addpath('/home/mikkel/fieldtrip/fieldtrip') % Add the path
    addpath('/home/mikkel/jsonlab/jsonlab')
else
    bidsroot  = '/home/igocom/BIDS';
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
general.method   = 'copy'; % the original data is in a BIDS-compliant format and can simply be copied
general.bidsroot = bidsroot;

general.InstitutionName                 = 'Karolinska Institute';
general.InstitutionalDepartmentName     = 'Department of Clinical Neuroscience';
general.InstitutionAddress              = 'Nobels väg 9, 171 77, Stockholm, Sweden';
general.dataset_description.Name        = 'NatMEG_PD_database';
general.dataset_description.BIDSVersion = 'v1.6.0';

general.coordsystem.MEGCoordinateSystem     = 'Neuromag';

general.dataset_description.EthicsApprovals = 'The Swedish Ethical Review Authority. DNR 2019-00542';

% MCV: MISSING FIELDS WHERE WE NEED TO FIND THE CORRECT INFO

general.meg.DewarPosition               = 'upright';    % REQUIRED. Position of the dewar during the MEG scan: "upright", "supine" or "degrees" of angle from vertical: for example on CTF systems, upright=15??, supine = 90??.
general.meg.SoftwareFilters             = 'n/a';        % REQUIRED. List of temporal and/or spatial software filters applied, orideally key:valuepairsofpre-appliedsoftwarefiltersandtheir parameter values: e.g., {"SSS": {"frame": "head", "badlimit": 7}}, {"SpatialCompensation": {"GradientOrder": Order of the gradient compensation}}. Write "n/a" if no software filters applied.
general.meg.DigitizedLandmarks          = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
general.meg.DigitizedHeadPoints         = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
general.meg.RecordingType               = 'continuous';
general.meg.ContinuousHeadLocalization  = 'true';
%general.meg.SamplingFrequency           = '';           % REQUIRED. Sampling frequency (in Hz) of all the data in the recording, regardless of their type (e.g., 2400)
%general.meg.PowerLineFrequency          = '';           % REQUIRED. Frequency (in Hz) of the power grid at the geographical location of the MEG instrument (i.e. 50 or 60)

%% Run loop
for subindx=1:numel(subjects_and_dates(1:2))
  for runindx=1:n_sessions

    % Filenames
    origname = fullfile(raw_path, subjects_and_dates{subindx}, [filenames.rest_fname{subindx},'.fif']);
%     emptyname = fullfile(temp_raw_path, subjects_and_dates{subindx}, filenames.empty_fname{subindx});
    
    % BIDSify rest data
    % Recording info
    cfg = general;
    cfg.dataset  = origname;
    cfg.sub      = linkdata.anonym_id{subindx};
    cfg.task     = 'rest';
    cfg.TaskName = 'rest';
    cfg.run      = runindx;
    cfg.datatype = 'meg';
    if contains(origname, '_mc')
        cfg.proc     = 'tsss+mc';
    else
        cfg.proc     = 'tsss';
        cfg.meg.ContinuousHeadLocalization = 'false';
    end
    
    cfg.meg.DigitizedLandmarks  = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
    cfg.meg.DigitizedHeadPoints = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.


    % Subject info
    cfg.participants.age = metadata.agebin(subindx);
    %cfg.participants.handedness = handedness(i);   % THIS INFO IS MISSING
    cfg.participants.clinical_state = metadata.group(subindx);
    cfg.participants.sex = metadata.sex(subindx);
  
    % Recording specific
    cfg.meg.AssociatedEmptyRoom = ['./sub-',linkdata.anonym_id{subindx},'_ses-',num2str(runindx),'_task-noise_proc-tsss.fif'];
    
    try
      data2bids(cfg);
    catch
      % this is probably because the output dataset already exists
      % this is due to running the script multiple times
      disp(lasterr)
    end
    
%     % BIDSify empty room data
%     cfg = general;
%     cfg.sub      = linkdata.anonym_id{subindx};
%     cfg.task     = 'noise';
%     cfg.TaskName = 'noise';
%     cfg.run      = runindx;
%     cfg.datatype = 'meg';
%     cfg.proc     = 'tsss';
%     cfg.dataset  = emptyname;
%     cfg.writejson = 'no'
%     cfg.meg.ContinuousHeadLocalization = 'false';
%     cfg.meg.DigitizedLandmarks  = 'false';    % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
%     cfg.meg.DigitizedHeadPoints = 'false';    % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
% 
%     try
%       data2bids(cfg);
%     catch
%       % this is probably because the output dataset already exists
%       % this is due to running the script multiple times
%       disp(lasterr)
%     end
    
  end % for each run
end % for each subject
