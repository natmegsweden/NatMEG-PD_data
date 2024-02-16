%% Fix errors in sidcar variables
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
clear all
addpath('/home/mikkel/PD_long/data_share/scripts/bidsify')
addpath('/home/mikkel/fieldtrip/fieldtrip')
addpath('/home/mikkel/jsonlab/jsonlab')
ft_defaults

%% Paths
bids_path = '/home/mikkel/PD_long/data_share/BIDS_data';
tmp_path  = '/home/mikkel/PD_long/data_share/textfiles';
subj_data_path = '/home/mikkel/PD_long/subj_data/';

%% Load subjects
load(fullfile(subj_data_path, 'linkdata'));
subjects = linkdata.anonym_id;
conditions = {'task-rest', 'task-go', 'task-passive', 'task-noise'};

%% Run
exceptions = {};
for ii = 1:length(subjects)
    for cc = 1:length(conditions)
        subj = subjects{ii};
        subj_path = fullfile(bids_path,['sub-',subj],'meg');
        con = conditions{cc};

        % Find file
        base_fname = find_files(subj_path, {con, 'meg.json'});
        if isempty(base_fname)
            exceptions = [exceptions, [subj,con]];
            continue
        end
        fname = fullfile(subj_path, base_fname{1});

        fprintf('Fixing %s\n', base_fname{1})
    
        % Read json
        jsonText = fileread(fname);
        % Convert JSON formatted text to MATLAB data types
        jsonData = jsondecode(jsonText); 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CHANGE VARIABLES
        if strcmp(jsonData.ContinuousHeadLocalization, 'true')
            jsonData.ContinuousHeadLocalization = true;
        elseif strcmp(jsonData.ContinuousHeadLocalization, 'false')
            jsonData.ContinuousHeadLocalization = false;
        end
        
        if strcmp(jsonData.DigitizedLandmarks, 'true')
            jsonData.DigitizedLandmarks = true;
        elseif strcmp(jsonData.DigitizedLandmarks, 'false')
            jsonData.DigitizedLandmarks = false;
        end
        
        if strcmp(jsonData.DigitizedHeadPoints, 'true')
            jsonData.DigitizedHeadPoints = true;
        elseif strcmp(jsonData.DigitizedHeadPoints, 'false')
            jsonData.DigitizedHeadPoints = false;
        end
        
        if ischar(jsonData.PowerLineFrequency)
            jsonData.PowerLineFrequency = str2num(jsonData.PowerLineFrequency);
        end

        if ~isfield(jsonData, 'ManufacturersModelName')
             jsonData.ManufacturersModelName = 'ElektaTRIUX';
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Convert to JSON text
        ft_write_json(fname, jsonData)
        
        clear jsonData fname
    end
end
disp('done')
%END
