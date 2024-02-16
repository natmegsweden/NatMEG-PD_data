%% Import/export raw MRI, from previous project or from raw.
%
% Used for data described in:
% Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., 
% 	 Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2024). The 
%   Swedish National Facility for Magnetoencephalography Parkinson's disease dataset.
%   Scientific Data, 11(1), 150. https://doi.org/10.1038/s41597-024-02987-w
%
% The NatMEG-PD data is available through at the following location:
%   https://search.kg.ebrains.eu/instances/d55146e8-fc86-44dd-95db-7191fdca7f30
%
% Warping pipeline is described in: 
% Vinding, M. C., & Oostenveld, R. (2022). Sharing individualised template MRI data 
% 	 for MEG source reconstruction: A solution for open data while keeping s ubject 
%   confidentiality. NeuroImage, 119165. https://doi.org/10.1016/j.neuroimage.2022.119165
%
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
