% loop example (from other project)

for ii = 1:length(subjects)
    subj = subjects(ii).subj;
    fprintf('processing subj %s. (%i of %i).\n', subj, ii, length(subjects))
    
    raw_path = fullfile(dirs.raw_path, subjects(ii).subj_date);
    out_path = fullfile(dirs.meg_path, subj);
    outfname_go = fullfile(out_path, [subj, '_go_epo_raw.mat']);

    % Find file(s) - the function find_files is a home made function, I
    % have added it to the folder
    infile = fullfile(raw_path, find_files(raw_path, {'go', 'tsss'}));

    % infile is the filename that we want to do further processing
end


% It just struck me that this example is similar to these wiki pages:
% https://github.com/natmegsweden/NatMEG_Wiki/wiki/Consistent-filenames-in-loops
% https://github.com/natmegsweden/NatMEG_Wiki/wiki/How-to-find-all-raw-files-that-belongs-to-the-same-condition 