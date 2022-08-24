%% Warp template MRI to subject MRI for creating source model
%
% Used for data described in: <ref>
% DOI: <ref>
%
% Read orignal MRI aligned to MEG coordinate system and export as SPM 
% readable file. Import template (Colin) and "normalize" the template to
% the original MRI. Save and export.
%
% Warping pipeline is described in: Vinding, M. C., & Oostenveld, R. (2021). Sharing individualised template MRI data for MEG source reconstruction: A solution for open data while keeping subject confidentiality [Preprint]. bioRxiv.org. https://doi.org/10.1101/2021.11.18.469069

%% Paths
addpath('/home/mikkel/PD_long/data_share/scripts')
[dirs, subj_mri] = DS_SETUP();

%% Load template MRI
load standard_mri           % Load Colin 27 from FieldTrip
mri_colin = mri;            % Rename to avoid confusion

% Do initial alignmet of fiducials to target coordsys
cfg = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'neuromag';
mri_colin_neuromag = ft_volumerealign(cfg, mri_colin);     

%% Run
for ii = 1:length(subj_mri)
    subj = subj_mri{ii,1};
    fprintf('Processing subj %s. (%i of %i).\n', subj, ii, length(subj_mri))
    
    % Check if MRI exist
    if strcmp(subj_mri{ii,2}, 'nan')
        fprintf('Subj %s marked as no MRI.\n', subj)
        continue
    end
    
    % Paths
    outdir       = fullfile(dirs.mriout, subj);
    infname      = fullfile(outdir, 'mri_resliced.mat');
    outfname_mat = fullfile(outdir, [subj, '_mri_warptmp.mat']);
    outfname_nii = fullfile(outdir, [subj, '_mri_warptmp']);
    
    if exist(outfname_mat, 'file')
        fprintf('File %s exist for subj %s.\n', outfname_mat, subj)
        continue
    end


    % The template anatomy will be saved in a SPM-compatible file (i.e. NIFTI).
    % Then create a tissue probablility map (TPM) based on the subject's
    % anatomy and write that to disk.

    % load data
    load(infname);
    
    % Plot for inspection
    try
        ft_sourceplot([], mri_resliced);
    catch
        title(['Orig MRI subj ', subj])
        saveas(gcf, fullfile(outdir,  [subj,'_orig.jpg']));
        close all
    end

    % Write image
    cfg = [];
    cfg.filetype    = 'nifti';          % .nii exntension
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'double';
    cfg.filename    = fullfile(outdir, 'orig_neuromag_rs');
    ft_volumewrite(cfg, mri_resliced)

    % Make subject tissue probability maps
    cfg = [];
    cfg.spmmethod   = 'new';
    cfg.output      = 'tpm';
    cfg.write       = 'no';   % We will not write to disk yet, as it will write each tissue to seperate files.
    org_seg = ft_volumesegment(cfg, mri_resliced); disp('done')

    % Rearrange data stucture for saving
    sub_tpm = mri_resliced;
    sub_tpm.anatomy          = org_seg.gray;
    sub_tpm.anatomy(:,:,:,2) = org_seg.white;
    sub_tpm.anatomy(:,:,:,3) = org_seg.csf;
    sub_tpm.anatomy(:,:,:,4) = org_seg.bone;
    sub_tpm.anatomy(:,:,:,5) = org_seg.softtissue;
    sub_tpm.anatomy(:,:,:,6) = org_seg.air;
    sub_tpm.dim = [org_seg.dim, size(sub_tpm.anatomy, 4)];

    % Write TPM volume
    cfg = [];
    cfg.filetype    = 'nifti';          % .nii exntension
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'double';
    cfg.filename    = fullfile(outdir, 'sub_tpm');
    ft_volumewrite(cfg, sub_tpm);

    % "Normalise" template -> subject (neuromag coordsys)
    cfg = [];
    cfg.nonlinear        = 'yes';       % Non-linear warping
    cfg.spmmethod        = 'new';       % Note: method="new" uses SPM's default posterior tissue maps unless we specify 'cfg.tpm'.
    cfg.spmversion       = 'spm12';     % Default = "spm12"
    cfg.templatecoordsys = 'neuromag';  % Coordinate system of the template
    cfg.template         = fullfile(outdir,'orig_neuromag_rs.nii'); % Subject "template" created in step 3A
    cfg.tpm              = fullfile(outdir,'sub_tpm.nii');          % Subject TPM created in step 3C
    mri_warptmp = ft_volumenormalise(cfg, mri_colin_neuromag);

    % Determine unit of volume (mm)
    mri_warptmp = ft_determine_units(mri_warptmp);

    % Plot for inspection
    try
        ft_sourceplot([], mri_warptmp); 
    catch
        title(['Warped template subj ', subj])
        saveas(gcf, fullfile(outdir,  [subj,'_warptmp.jpg']));
        close all
    end

    % Save. The output format is not BIDS compatible.
    fprintf('saving...')
    save(outfname_mat, 'mri_warptmp')
    
    % Write image
    cfg = [];
    cfg.filetype    = 'nifti';          % .nii exntension
    cfg.parameter   = 'anatomy';
    cfg.datatype    = 'double';
    cfg.filename    = outfname_nii;
    ft_volumewrite(cfg, mri_warptmp)
    disp('done')
    
    fprintf('%s done\n', subj)
    clear mri_warptmp sub_tmp org_seg mri_resliced
end

% END