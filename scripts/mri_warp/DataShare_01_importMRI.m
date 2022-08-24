%% Import/export raw MRI, from previous project or from raw.
%
% Used for data described in: <ref>
% DOI: <ref>
%
% Import orignal MRI from previous project or from raw
%
% Warping pipeline is described in: Vinding, M. C., & Oostenveld, R. (2021). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality [Preprint]. bioRxiv.org. https://doi.org/10.1101/2021.11.18.469069

addpath('/home/mikkel/PD_long/data_share/scripts')
[dirs, subj_mri] = DS_SETUP();
overwrite = 0;

noexits = [];

for ii = 1:length(subj_mri)
    subj = subj_mri{ii,1};
    fprintf('Processing subj %s. (%i of %i).\n', subj, ii, length(subj_mri))
    
    % Check if MRI exist
    if strcmp(subj_mri{ii,2}, 'nan')
        fprintf('Subj %s marked as no MRI.\n', subj)
        continue
    end
    
    % Paths
    outdir      = fullfile(dirs.mriout, subj);
    outfname    = fullfile(outdir, 'mri_resliced.mat');
    subjdir_old = fullfile(dirs.ERproj, subj);
    oldfname    = fullfile(subjdir_old, 'mri_resliced.mat');   
    raw_path    = fullfile(dirs.raw_mri, ['NatMEG_',subj_mri{ii,1}], subj_mri{ii,2});

    if ~exist(outdir, 'dir'); mkdir(outdir); end
    
    if exist(outfname, 'file') && ~overwrite
        fprintf('Subj %s previously imported', subj)
        continue
    end
  
    % Check if MRI previously imported
    if exist(oldfname, 'file')
        fprintf('Subj %s previously imported.\nWill copy: \n%s -> %s ...', subj, oldfname, outfname)
        copyfile(oldfname, outfname); disp('done')
    else
        noexits = [noexits; subj];
        fprintf('Import raw MRI from %s...', raw_path)
        tmp = dir(mri_path);
        allnames = {tmp.name};
        allnames = allnames(~[tmp.isdir]);
    
        mri = ft_read_mri(fullfile(mri_path, allnames{1}));

        save(outfname, 'mri'); disp('done')
    end
end

%END