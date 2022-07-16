%% MEG-BIDS, the brain imaging data structure extended to magnetoencephalography.
% MCV: CHANGE HEADER INFO IN FINAL VERSION
% 
% In this script, you will use the FieldTrip toolbox to reorganize MEG data 
% to BIDS.

close all       % Close all open windows
clear all       % Clear all variables from the workspace
restoredefaultpath

raw_path        = '/archive/20080_PD_EBRAINS/ORIGINAL/MEG';
subj_data_path  = '/archive/20080_PD_EBRAINS/ORIGINAL/subj_data/';
if strcmp(java.lang.System.getProperty('user.name'), 'mikkel')
    bidsroot = '/home/mikkel/PD_long/data_share/BIDS_data';
    addpath('/home/mikkel/fieldtrip/fieldtrip') % Add the path
    addpath('/home/mikkel/jsonlab/jsonlab')
else
    bidsroot = '/home/igocom/BIDS';
    addpath('/home/share/fieldtrip/') % Add the path
end
ft_defaults
        
%% Define subjects and sessions
% All subject relevant data is now stored in the 'metadata.mat' file (see
% other script how it is generated). Import and use for the bidsify loop.
     
load(fullfile(subj_data_path, 'linkdata'));
metadata = readtable(fullfile(subj_data_path, 'metadata.csv'));
filenames = readtable(fullfile(subj_data_path, 'filenames.csv'), 'Delimiter', ',' );

linkdata = sortrows(linkdata, 3);
filenames = sortrows(filenames, 3);
subjects_and_dates = linkdata.subject_date;

%% Genral info 
n_sessions = 1;

% Common for all participants or info written to dataset_description file.
general = [];
general.method = 'copy';

% General metadata data
general.bidsroot                    = bidsroot;
general.datatype                    = 'meg';
general.InstitutionName             = 'Karolinska Institute';
general.InstitutionalDepartmentName = 'Department of Clinical Neuroscience';
general.InstitutionAddress          = 'Nobels väg 9, 171 77, Stockholm, Sweden';

% Dataset description
general.dataset_description.Name            = 'NatMEG_PD_dataset';
general.dataset_description.BIDSVersion     = 'v1.6.0';
general.dataset_description.EthicsApprovals = 'The Swedish Ethical Review Authority. DNR 2019-00542';

% MEG recording info common to all recordings
general.meg.DewarPosition              = 'upright';    % REQUIRED. Position of the dewar during the MEG scan: "upright", "supine" or "degrees" of angle from vertical: for example on CTF systems, upright=15??, supine = 90??.
general.meg.SoftwareFilters            = 'n/a';        % REQUIRED. List of temporal and/or spatial software filters applied, orideally key:valuepairsofpre-appliedsoftwarefiltersandtheir parameter values: e.g., {"SSS": {"frame": "head", "badlimit": 7}}, {"SpatialCompensation": {"GradientOrder": Order of the gradient compensation}}. Write "n/a" if no software filters applied.
general.meg.DigitizedLandmarks         = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
general.meg.DigitizedHeadPoints        = 'true';       % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.
general.meg.RecordingType              = 'continuous';
general.meg.ContinuousHeadLocalization = 'true';
general.meg.PowerLineFrequency         = '50';         % REQUIRED. Frequency (in Hz) of the power grid at the geographical location of the MEG instrument (i.e. 50 or 60)

%% Run loop
for subindx = 1:numel(subjects_and_dates)
  for runindx = 1:n_sessions

    % Input filenames
    rs_fname     = fullfile(raw_path, subjects_and_dates{subindx}, [filenames.rest_fname{subindx},'.fif']);
    go_fname     = fullfile(raw_path, subjects_and_dates{subindx}, filenames.go_fname{subindx});
    pam_fname    = fullfile(raw_path, subjects_and_dates{subindx}, filenames.pas_fname{subindx});
    empty_fname  = fullfile(raw_path, subjects_and_dates{subindx}, filenames.empty_fname{subindx});
    
    % General config for subject
    cfg_sub = general;
    cfg_sub.sub                      = linkdata.anonym_id{subindx};

    % Subject info
    cfg_sub.participants.age          = metadata.agebin(subindx);
    cfg_sub.participants.group        = metadata.group(subindx);
    cfg_sub.participants.sex          = metadata.sex(subindx);
    cfg_sub.participants.handedness   = metadata.hand(subindx);
    cfg_sub.participants.disease_dur  = metadata.disease_dur(subindx);
    cfg_sub.participants.LEDD         = metadata.LEDD(subindx);
    cfg_sub.participants.BDI          = metadata.BDI(subindx);
    cfg_sub.participants.MoCA         = metadata.MoCA(subindx);
    cfg_sub.participants.FAB          = metadata.FAB(subindx);
    cfg_sub.participants.HY_stage     = metadata.H_Y_STAGE(subindx);
    cfg_sub.participants.UPDRS_III    = metadata.UPDRS_TOTAL(subindx);
    cfg_sub.participants.UPDRS_III_f1 = metadata.F1(subindx);
    cfg_sub.participants.UPDRS_III_f2 = metadata.F2(subindx);
    cfg_sub.participants.UPDRS_III_f3 = metadata.F3(subindx);
    cfg_sub.participants.UPDRS_III_f4 = metadata.F4(subindx);
    cfg_sub.participants.UPDRS_III_f5 = metadata.F5(subindx);
    cfg_sub.participants.UPDRS_III_f6 = metadata.F6(subindx);
    cfg_sub.participants.UPDRS_III_f7 = metadata.F7(subindx);

    % Recording info
    cfg_sub.meg.AssociatedEmptyRoom = ['./sub-',linkdata.anonym_id{subindx},'_task-noise_proc-tsss_meg.fif'];
    cfg_sub.meg.DigitizedLandmarks  = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether anatomical landmark points (i.e. fiducials) are contained within this recording.
    cfg_sub.meg.DigitizedHeadPoints = 'true';    % REQUIRED. Boolean ("true" or "false") value indicating whether head points outlining the scalp/face surface are contained within this recording.

    % ####################################################################
    % 1) BIDSify REST data
    cfg = cfg_sub;
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
    % 2) BIDSify GO task data
    cfg = cfg_sub;
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
    % 3) BIDSify PASSIVE task data
    cfg = cfg_sub;
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
    cfg = cfg_sub;
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
disp('DONE')
