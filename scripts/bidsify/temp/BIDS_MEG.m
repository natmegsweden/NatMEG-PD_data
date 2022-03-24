%% 
%% MEG-BIDS, the brain imaging data structure extended to magnetoencephalography.
% 
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

restoredefaultpath
addpath('/home/igocom/fieldtrip/') % Add the path   
ft_defaults

meg_path = '/home/igocom/PD_data_test';
%% 
% If you have several variables with the same names, it might also be good close 
% all open windows and clear all figures and variables from your workspace.

close all       % Close all open windows
clear all       % Clear all variables from the workspace
%% 
% 
% 
% *2.Store data separate by subject and session*
% 
% You can setup subject and recording specific paths as below 

%% Define subjects and sessions

subjects_and_dates = {
                'NatMEG_0521/190417/'
                'NatMEG_0522/190426/'
                'NatMEG_0523/190429/'
                'NatMEG_0524/190429/'

             };

subjects =  {
                'NatMEG_0521'
                'NatMEG_0521'
                'NatMEG_0521'
                'NatMEG_0521'
            };
                
filenames = {
        'rest_ec_mc_avgtrans_tsss_corr95.fif'
        'rest_ec_mc_avgtrans_tsss_corr95.fif'
        'rest_ec_mc_avgtrans_tsss_corr95.fif'
        'rest_ec_mc_avgtrans_tsss_corr95.fif'
        
            };
%% 
% *Run loop*


%% Run loop

for subindx=1:numel(subjects)
  for runindx=1:2
    d = dir(sprintf('/home/igocom/PD_data_test/NatMEG_0521/190417/rest_ec_mc_avgtrans_tsss_corr95.fif', subjects{subindx}, runindx));
    if isempty(d)
      % for most subjects the data was recorded in a single run
      % in that case run 2 does not exist
      continue
    else
      origname = fullfile(d.folder, d.name);
      anonname = fullfile(d.folder, sprintf('%s_%d.fif', subjects{subindx}, runindx));
      disp(anonname); % this is just an intermediate name, the final name will be assigned by data2bids
    end
    
   

    cfg = [];
    
    cfg.bidsroot = '/home/igocom/bids';  % write to the present working directory
    cfg.sub = subjects{subindx};
    cfg.run = runindx;
    cfg.dataset = anonname; % this is the intermediate name
    
    cfg.datatype = 'meg';
    cfg.method = 'copy'; % the original data is in a BIDS-compliant format and can simply be copied
    
    cfg.InstitutionName             = 'Karolinska Institute';
    cfg.InstitutionalDepartmentName = 'Department of Clinical Neuroscience';
    cfg.InstitutionAddress          = 'Tomtebodavägen 18A, 171 77, Stockholm, Sweden';
    
    % required for dataset_description.json
    cfg.dataset_description.Name                = 'PD_data_share';
    cfg.dataset_description.BIDSVersion         = 'v1.5.0';

    try
      data2bids(cfg);
    catch
      % this is probably because the output dataset already exists
      % this is due to running the script multiple times
      disp(lasterr)
    end
    
    
  end % for each run
end % for each subject
