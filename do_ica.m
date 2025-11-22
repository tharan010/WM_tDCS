clc; clear

%% 
% Assumes you have signal and header loaded.

load('ch32Locations.mat');
eeglab;
% Create EEGLAB structure
EEG = eeg_emptyset;
EEG.nbchan = header.NS;
EEG.srate = header.SPR;
EEG.trials = 1;
EEG.data = signal(:,1:32)';
EEG.pnts = size(EEG.data, 2);
EEG.times = (0:EEG.pnts-1) / EEG.srate;
EEG.chanlocs = ch32Locations;

EEG = pop_importdata('dataformat', 'array', 'data', EEG.data, 'srate', EEG.srate, 'nbchan', EEG.nbchan, 'pnts', EEG.pnts, 'xmin', EEG.times(1), 'chanlocs', EEG.chanlocs);
EEG = pop_runica(EEG, 'extended', 1, 'interupt', 'on'); % run ICA with default settings
EEG = pop_saveset(EEG, 'filename', [files(foi(f)).name '.set'], 'filepath', 'C:\Users\ts39233.AUSTIN\Desktop\New folder');

% EEG = pop_loadset('C:\Users\ts39233.AUSTIN\Desktop\New folder\7_20230407114721_5.set');
pop_selectcomps(EEG);

% EEG = pop_prop(EEG, 0, [1:size(EEG.icaweights, 1)], NaN, {'freqrange', [2 45], 'timewin', [-Inf Inf]});
EEG = pop_subcomp(EEG, [1 2], 0, 0); % enter components to reject in brackets

[erp erp_amp] = get_erp(z, header);
