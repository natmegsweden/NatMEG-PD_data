%% Add trigger info to event.tsv files and copy events.json file to sub folders.
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
addpath('/home/mikkel/fieldtrip/fieldtrip') % Add the path
addpath('/home/mikkel/jsonlab/jsonlab')

ft_defaults

%% Overwrite
overwrite = 0;

%% Paths
bids_path = '/home/mikkel/PD_long/data_share/BIDS_data';
tmp_path  = '/home/mikkel/PD_long/data_share/textfiles';
subj_data_path = '/home/mikkel/PD_long/subj_data/';

%% Load subjects
load(fullfile(subj_data_path, 'linkdata'));
subjects = linkdata.anonym_id;

%% Trigger value defenitions
% RS
startTrigger = 1;
stopTrigger  = 64;

% TASK
go_trig = [8 14600];
rt_trig = [2, 3, 14595];
ps_trig = [2, 14594];

%% RUN
rs_except = [];
go_except = [];
ps_except = [];

for ii = 1:length(subjects)
    subj = subjects{ii};
    subj_path = fullfile(bids_path,['sub-',subj],'meg');
    
    % REST DATA ###########################################################
    fname = find_files(subj_path, {'task-rest', 'events.tsv'});
    if ~isempty(fname)
        % Read tsv file
        tabeve = readtable(fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text');
    
        % Checkt for exceptions (bookkeeping)
        if ~any(strcmp(tabeve.type, 'STI101') & tabeve.value == startTrigger)
            fprintf('No START TRIG for %s REST\n', subj);
            rs_except = [rs_except, {subj}];
        end
        if ~any(strcmp(tabeve.type, 'STI101') & tabeve.value == stopTrigger)
            fprintf('No STOP TRIG for %s REST\n', subj)
            rs_except = [rs_except, {subj}];
        end
    
        if any(strcmp('event_type',tabeve.Properties.VariableNames)) && ~overwrite
            fprintf('%s already has column EVENT_TYPE. Continue!\n', fname{1});
        else
            % ADD VALUES
            tabeve.event_type = repmat({'n/a'}, height(tabeve),1);
        
            % STI101
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & tabeve.value == startTrigger) = {'start'};
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & tabeve.value == stopTrigger)  = {'stop'};
            
            % Trigger
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & tabeve.value == startTrigger) = {'start'};
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & tabeve.value == stopTrigger)  = {'stop'};
            
            % STI0XX
            % tabeve.event_type(strcmp(tabeve.type, 'STI001')) = {'start'};
            % tabeve.event_type(strcmp(tabeve.type, 'STI007')) = {'stop'};
        
            % Write
            writetable(tabeve, fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text')
        end
            
        % Copy json file
        temp_fname = strsplit(fname{1}, '.');
        json_fname =  [temp_fname{1}, '.json'];
        if exist(fullfile(subj_path, json_fname), 'file') && ~overwrite
            fprintf('File %s already exists. Continue!\n', json_fname);
        else
            if ~any(strcmp(rs_except, subj))
                copyfile(fullfile(tmp_path, 'template_events_rs.json'), fullfile(subj_path, json_fname), 'f')
            else
                warning('%s not copied because exception for subj %s rest', json_fname, subj)
            end
        end
        clear tabeve json_fname temp_fname fname
    else
        rs_except = [rs_except, {subj}];
    end
    
    % GO TASK #############################################################   
    % Read tsv file
    fname = find_files(subj_path, {'task-go', 'events.tsv'});
    if ~isempty(fname)
        tabeve = readtable(fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text');
    
        % Checkt for exceptions (bookkeeping)
        if any(strcmp(tabeve.type, 'STI101') & any(tabeve.value==14600))
            fprintf('Inverse trigger values for %s GO\n', subj);
            go_except = [go_except, {subj}];
        end
    
        if any(strcmp('event_type',tabeve.Properties.VariableNames)) && ~overwrite
            fprintf('%s already has column EVENT_TYPE. Continue!\n', fname{1});
        else
            % ADD VALUES
            tabeve.event_type = repmat({'n/a'}, height(tabeve),1);
        
            % STI101
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & any(go_trig==tabeve.value, 2)) = {'go_cue'};
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & any(rt_trig==tabeve.value, 2)) = {'response'};
            
            % Trigger
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & any(go_trig==tabeve.value, 2)) = {'go_cue'};
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & any(rt_trig==tabeve.value, 2)) = {'response'};
            
            % STI102
            tabeve.event_type(strcmp(tabeve.type, 'STI102')) = {'key_press'};
        
            % STI0XX
            % Leave these as N/A
    
            % Write
            writetable(tabeve, fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text')
        end
        
        % Copy json file
        temp_fname = strsplit(fname{1}, '.');
        json_fname =  [temp_fname{1}, '.json'];
        if exist(fullfile(subj_path, json_fname), 'file') && ~overwrite
            fprintf('File %s already exists. Continue!\n', json_fname);
        else
            if ~any(strcmp(go_except, subj))
                copyfile(fullfile(tmp_path, 'template_events_go.json'), fullfile(subj_path, json_fname), 'f')
            elseif any(strcmp(go_except, subj))
                copyfile(fullfile(tmp_path, 'template_events_go2.json'), fullfile(subj_path, json_fname), 'f')
            else
                warning('%s not copied because exception for subj %s Go', json_fname, subj)
            end
        end
        clear tabeve json_fname temp_fname fname
    else
        go_except = [go_except, {subj}];
    end

    
    % PASSIVE TASK ########################################################    
    % Read tsv file
    fname = find_files(subj_path, {'task-passive', 'events.tsv'});
    if ~isempty(fname)
        tabeve = readtable(fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text');
        
        % Checkt for exceptions (bookkeeping)
        if any(strcmp(tabeve.type, 'STI101') & any(tabeve.value==14600))
            fprintf('Inverse trigger values for %s GO\n', subj);
            ps_except = [ps_except, {subj}];
        end
        
        if any(strcmp('event_type',tabeve.Properties.VariableNames)) && ~overwrite
            fprintf('%s already has column EVENT_TYPE. Continue!\n', fname{1});
        else
            % ADD VALUES
            tabeve.event_type = repmat({'n/a'}, height(tabeve),1);
        
            % STI101
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & any(go_trig==tabeve.value, 2)) = {'cue'};
            tabeve.event_type(strcmp(tabeve.type, 'STI101') & any(ps_trig==tabeve.value, 2)) = {'movement'};
            
            % Trigger
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & any(go_trig==tabeve.value, 2)) = {'cue'};
            tabeve.event_type(strcmp(tabeve.type, 'Trigger') & any(ps_trig==tabeve.value, 2)) = {'movement'};
            
            % STI102
            tabeve.event_type(strcmp(tabeve.type, 'STI102')) = {'key_press'};
            
            % STI0XX
            % Leave these as N/A
    
            % Write
            writetable(tabeve, fullfile(subj_path, fname{1}), 'Delimiter', 'tab', 'FileType', 'text')
        end
        
        % Copy json file
        temp_fname = strsplit(fname{1}, '.');
        json_fname =  [temp_fname{1}, '.json'];
        if exist(fullfile(subj_path, json_fname), 'file') && ~overwrite
            fprintf('File %s already exists. Continue!\n', json_fname);
        else
            if ~any(strcmp(ps_except, subj))
                copyfile(fullfile(tmp_path, 'template_events_ps.json'), fullfile(subj_path, json_fname), 'f')
            elseif any(strcmp(ps_except, subj))
                copyfile(fullfile(tmp_path, 'template_events_ps2.json'), fullfile(subj_path, json_fname), 'f')
            else
                warning('%s not copied because exception for subj %s Passive', json_fname, subj)
            end
        end
        clear tabeve json_fname temp_fname fname
    else
        ps_except = [ps_except, {subj}];
    end

    fprintf('Done subj %s\n', subj)
end
disp('DONE')
%END
