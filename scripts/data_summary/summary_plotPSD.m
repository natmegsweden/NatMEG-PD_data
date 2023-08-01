%% Calculate and plot PSD
%For information about NatMEG-PD please refer to the data descriptor :
%   Vinding, M. C., Eriksson, A., Comarovschii, I., Waldthaler, J., Manting, C. L., Oostenveld, R., Ingvar, M., Svenningsson, P., & Lundqvist, D. (2023). The Swedish National Facility for Magnetoencephalography Parkinsons Disease Dataset (v1.0) [Data set]. EBRAINS. https://doi.org/10.25493/NMD2-2FW
%
% The NatMEG-PD data is available through at the following location:
% h ttps://search.kg.ebrains.eu/instances/d5088e83-cbf1-4ea2-b64c-b10778121b4e

clear all
addpath('/home/mikkel/fieldtrip/fieldtrip')
ft_defaults

%% Paths
bids_path = '/home/mikkel/PD_long/data_share/BIDS_data';
subj_data_path = '/home/mikkel/PD_long/subj_data/';

%% Load subjects
load(fullfile(subj_data_path, 'linkdata'));
subjects = linkdata.anonym_id;

%% Calculate PSD
for ii = 1:length(subjects)
    subj = ['sub-',subjects{ii}];
    disp(subjects{ii})
    subjdir = fullfile(bids_path, subj, 'meg');

    infile = find_files(subjdir, {'task-rest', '.fif'});

    % Load data
    cfg = [];
    cfg.dataset = fullfile(subjdir, infile{:});
    cfg.channel = 'MEG';
    raw = ft_preprocessing(cfg);

    cfg = [];
    cfg.length = 2;
    cfg.overlap = 0.5;
    epo = ft_redefinetrial(cfg, raw);

    cfg = [];
    cfg.method = 'mtmfft';
    cfg.output = 'pow';
    cfg.taper = 'hanning';
    cfg.foilim = [0.5, 100];
    freq = ft_freqanalysis(cfg, epo);

    allFreq{ii} = freq;

    cfg = [];
    cfg.avgoverfreq = 'no';
    cfg.avgoverchan = 'yes';
    freqGlob = ft_selectdata(cfg, freq);

    allFreqGlob(ii,:) = freqGlob.powspctrm;

end
disp('DONE')
freqax = freqGlob.freq;

%% Save
fprintf('Saving... ')
save('/home/mikkel/PD_long/data_share/misc/freq.mat', 'allFreq', 'allFreqGlob', 'freqax', '-v7.3')
disp('done')

%% Average plot
tab = readtable(fullfile(bids_path,'participants.tsv'), "FileType","text");
grp = any(cell2mat(tab.group) == 'Patient', 2);

avgPsdPtns = mean(allFreqGlob(grp,:));
avgPsdCtrl = mean(allFreqGlob(~grp,:));

fig = figure; hold on
for ii = 1:size(allFreqGlob,1)
    if grp(ii) == 0
        col = '#1f77b4';
    else
        col = '#ff7f0e';
    end
    plot(freqax, log(allFreqGlob(ii,:)), 'color', col)
end

gr1 = plot(freqax, log(avgPsdCtrl), 'color', "#0000FF", 'LineWidth', 2.5); hold on
gr2 = plot(freqax, log(avgPsdPtns), 'color', "#A2142F", 'LineWidth', 2.5);
xlim([0,60]); ylim([-60,-53])
xlabel('Freq. (Hz)'); ylabel('Log-Power')
title('Global signal power')
ax = gca;
ax.FontWeight = 'bold';
legend([gr1, gr2], {'HC','PD'})

% Save
savefig(fig, '/home/mikkel/PD_long/data_share/figures/psd.fig')
saveas(fig, '/home/mikkel/PD_long/data_share/figures/psd.tif', 'tiff')
exportgraphics(fig,'/home/mikkel/PD_long/data_share/figures/psd.tif', ...
    'Resolution',600)
disp('done)')

%% Topoplots
cfg = [];
avgTopoPtns = ft_freqgrandaverage(cfg, allFreq{grp});
avgTopoCtrl = ft_freqgrandaverage(cfg, allFreq{~grp});

fidx = find(avgTopoPtns.freq==10);
ul = max([avgTopoPtns.powspctrm(:, fidx); avgTopoPtns.powspctrm(:, fidx)]);
ll = min([avgTopoPtns.powspctrm(:, fidx); avgTopoPtns.powspctrm(:, fidx)]);
zlim10 = [ll, ul];

fidx = find(avgTopoPtns.freq==20);
ul = max([avgTopoPtns.powspctrm(:, fidx); avgTopoPtns.powspctrm(:, fidx)]);
ll = min([avgTopoPtns.powspctrm(:, fidx); avgTopoPtns.powspctrm(:, fidx)]);
zlim20 = [ll, ul];

cfg = [];
cfg.parameter   = 'powspctrm';
cfg.xlim        = [8, 10];
cfg.layout      = 'neuromag306mag.lay';
cfg.comment     = 'no';
cfg.colormap =   ft_colormap('-RdBu');
cfg.zlim        = [0, 9e-27];
cfg.figure      = 'no';

fig1 = figure();
ft_topoplotER(cfg, avgTopoPtns)
exportgraphics(fig1,'/home/mikkel/PD_long/data_share/figures/topo10ptns.tif', 'Resolution',600)

fig2 = figure();
ft_topoplotER(cfg, avgTopoCtrl)
exportgraphics(fig2,'/home/mikkel/PD_long/data_share/figures/topo10ctrl.tif', 'Resolution',600)

cfg = [];
cfg.parameter   = 'powspctrm';
cfg.xlim        = [15, 20];
cfg.layout      = 'neuromag306mag.lay';
cfg.comment     = 'no';
cfg.colormap =   ft_colormap('-RdBu');
cfg.zlim        = [0, 15e-28];
cfg.figure      = 'no';

fig3 = figure();
ft_topoplotER(cfg, avgTopoPtns)
exportgraphics(fig3,'/home/mikkel/PD_long/data_share/figures/topo20ptns.tif', 'Resolution',600)

fig4 = figure();
ft_topoplotER(cfg, avgTopoCtrl)
exportgraphics(fig4,'/home/mikkel/PD_long/data_share/figures/topo20ctrl.tif', 'Resolution',600)

cfg = [];
cfg.parameter   = 'powspctrm';
cfg.xlim        = [30, 40];
cfg.layout      = 'neuromag306mag.lay';
cfg.comment     = 'no';
cfg.colormap =   ft_colormap('-RdBu');
cfg.zlim        = [5e-29, 15e-29];
cfg.figure      = 'no';

fig5 = figure();
ft_topoplotER(cfg, avgTopoPtns)
exportgraphics(fig5,'/home/mikkel/PD_long/data_share/figures/topo40ptns.tif', 'Resolution',600)

fig6 = figure();
ft_topoplotER(cfg, avgTopoCtrl)
exportgraphics(fig6,'/home/mikkel/PD_long/data_share/figures/topo40ctrl.tif', 'Resolution',600)

cfg = [];
cfg.parameter   = 'powspctrm';
cfg.xlim        = [50, 50];
cfg.layout      = 'neuromag306mag.lay';
cfg.comment     = 'no';
cfg.colormap =   ft_colormap('-RdBu');
cfg.zlim        = [5e-29, 15e-29];
cfg.figure      = 'no';

fig7 = figure();
ft_topoplotER(cfg, avgTopoPtns)
exportgraphics(fig7,'/home/mikkel/PD_long/data_share/figures/topo50ptns.tif', 'Resolution',600)

fig8 = figure();
ft_topoplotER(cfg, avgTopoCtrl)
exportgraphics(fig8,'/home/mikkel/PD_long/data_share/figures/topo50ctrl.tif', 'Resolution',600)

% END