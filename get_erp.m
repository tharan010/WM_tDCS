function [erp, erp_amp] = get_erp(signal, header)

% time window for segmenting the data
pre_trigger = 200; % Time (in ms) before trigger onset
post_trigger = 500; % Time (in ms) after trigger onset

% filter parameters
fs = header.SPR; % Sampling rate in Hz
fc1 = 0.1; % First cutoff frequency in Hz
fc2 = 12; % Second cutoff frequency in Hz
order = 2; % Filter order

% filter
[b, a] = butter(order, [fc1 fc2]/(fs/2), 'bandpass');

% Apply the filter
filtered_eeg = zeros(size(signal));
for i = 1:size(signal, 2)
    filtered_eeg(:,i) = filtfilt(b, a, signal(:,i));
end
% plot(mean(signal,2)); hold on; plot(mean(filtered_eeg,2));

% eeg = filtered_eeg;
for chan = 1:size(signal,2)
    eeg_demeaned(:,chan) = filtered_eeg(:,chan) - mean(filtered_eeg(:,chan));
    eeg_detrended(:,chan) = detrend(eeg_demeaned(:,chan));
end

% plot(mean(filtered_eeg,2)); hold on; plot(mean(eeg_detrended,2));
eeg = eeg_detrended;

% Get the position in samples
event_pos = header.EVENT.POS;
event_typ = header.EVENT.TYP;

% Define the indices of the different trigger events
run_start_end_idx = find(event_typ == 32766);
fixation_idx = find(event_typ == 768);
task_start_idx = find(event_typ == 769);
task_end_idx = find(event_typ == 770);
trial_end_idx = find(event_typ == 771);

name = header.FileName;
% if name(end-10:end-4) ~= 'control'
%     ret_start_idx = find(event_typ == 771);
%     ret_end_idx_corr = find(event_typ == 1000);
%     ret_end_idx_wro = find(event_typ == 2000);
% end

pre_trigger_samples = round(pre_trigger / 1000 * fs);
post_trigger_samples = round(post_trigger / 1000 * fs);
run_start_end_pos = event_pos(run_start_end_idx);

num_channels = size(header.CHANTYP,2);

% Find the trial with the shortest duration
min_duration = Inf;
for i = 1:length(task_end_idx)
    trial_start_pos = event_pos(task_start_idx(i)) - pre_trigger_samples;
    trial_end_pos = event_pos(task_end_idx(i)) + post_trigger_samples;
    trial_duration = trial_end_pos - trial_start_pos + 1;
    if trial_duration < min_duration
        min_duration = trial_duration;
    end
end

% Segment the data
data = zeros(num_channels, min_duration, length(task_end_idx));
% ret = zeros(num_channels, min_duration, length(task_end_idx));
for trl = 1:length(task_end_idx)
    trial_start_pos = event_pos(task_start_idx(trl)) - pre_trigger_samples;
    trial_end_pos = event_pos(task_end_idx(trl)) + post_trigger_samples;
    for chan = 1:num_channels
        dat = eeg(trial_start_pos:trial_end_pos,chan)';
        base = mean(dat(1:pre_trigger_samples));
        data(chan,:,trl) = dat(1:min_duration)-base;
    end
end

% if name(end-10:end-4) ~= 'control'
%     for trl = 1:length(ret_start_idx)
%         ret_start_pos = event_pos(ret_start_idx(trl)) - pre_trigger_samples;
%         if length(ret_end_idx_wro) ~= 0
%             if event_pos(ret_end_idx_corr(trl))-ret_start_pos < event_typ(ret_end_idx_wro(trl))-ret_start_pos
%                 ret_end_pos = event_pos(ret_end_idx_corr(trl));
%             else
%                 ret_end_pos = event_pos(ret_end_idx_wro(trl));
%             end
%         else
%             ret_end_pos = ret_start_pos + min_duration;
%         end
%         for chan = 1:num_channels
%             re = eeg(ret_start_pos:ret_end_pos, chan)';
%             base = mean(re(1:pre_trigger_samples));
%             ret(chan,:,trl) = re(1:min_duration) - base;
%         end
%     end
% end

for trl = 1:length(task_end_idx)
    for chan = 1:36
        if data(chan,:,trl) >= 100
            disp('** artifactual trial rejected **')
            data(chan,:,trl) = nan;
            ret(chan,:,trl) = nan;
        end
    end
end


% plot(squeeze(mean(data(6,:,:),3)))
erp_trl = nan(num_channels,min_duration,length(trial_end_idx));
if name(end-10:end-4) ~= 'control'
    idx = 1:str2num(name(end-4)):str2num(name(end-4))*length(trial_end_idx)+str2num(name(end-4));
    for chan = 1:num_channels
        for trl = 1:length(trial_end_idx)
            erp_trl(chan,:,trl) = nanmean(squeeze(data(chan,:,idx(trl):idx(trl+1)-1)),2);
        end
    end
end

erp_amp = nan(num_channels,length(trial_end_idx));
win = [309:572];
for chan = 1:num_channels
    for trl = 1:length(trial_end_idx)
        erp_amp(chan,trl)= max(erp_trl(chan,win,trl)) - min(erp_trl(chan,win,trl));
    end
end

% Average the segmented data across events to create the ERP waveform
erp = squeeze(nanmean(data(:,:,:),3));
% ret = squeeze(nanmean(ret(:,:,:),3));

end
