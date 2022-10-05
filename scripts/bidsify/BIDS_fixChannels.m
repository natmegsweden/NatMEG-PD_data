%% Fix errors in how trigger channels are strond in channels.tsv files

clear all
addpath('/home/mikkel/PD_long/data_share/scripts/bidsify')

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
        base_fname = find_files(subj_path, {con, 'channels.tsv'});
        if isempty(base_fname)
            exceptions = [exceptions, [subj,con]];
            continue
        end
        fname = fullfile(subj_path, base_fname{1});

        fprintf('Fixing %s\n', base_fname{1})
    
        % Read file as table
        channels_tsv = readtable(fname, 'Delimiter', 'tab', 'FileType', 'text');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % CHANGE VARIABLES
        channels_tsv.type(contains(channels_tsv.type, 'trigger', 'IgnoreCase', true)) = {'TRIG'};

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Convert to JSON text
        writetable(channels_tsv, fname, 'Delimiter', 'tab', 'FileType', 'text')

        clear channels_tsv fname
    end
end
disp('done')
%END