%%
clc; clear;

sub = {'6_20230406', '7_20230407', '8_20230407'};


%% behavioral data
% file_num = [11 12 13];
% data = [];
% for s = 3
%     cd(['C:\Users\ts39233.AUSTIN\Box\' sub{s}]);
%     files = dir(['C:\Users\Tharan Suresh\Box\' sub{s}]);
%     for f = 1:length(file_num)
%         cd(['C:\Users\Tharan Suresh\Box\' sub{s} '\' files(file_num(f)).name]);
%         csv = dir('*.csv');
%         d = readmatrix(csv.name);
%         d(1,:)=[]; d(:,5)=str2double(csv.name(end-4)); d(:,6)=s;
%         data = [data; d];
%     end
% end

%% erp data
s = 2;
master = nan(36,616,8);
amplitude = [];
foi = [6 7 8 11 12 13];
files = dir(['C:\Users\ts39233.AUSTIN\Box\' sub{s}]);
cd('C:\Users\ts39233.AUSTIN\Box\School\Spring 23\ECE 385J NE\Project\eeglab2020_0\eeglab2020_0\');
addpath(genpath(pwd));
cd('C:\Users\ts39233.AUSTIN\Box\School\Spring 23\ECE 385J NE\Project\biosigToolBox\biosigToolBox');
addpath(genpath(pwd));
cd(['C:\Users\ts39233.AUSTIN\Box\' sub{s}]);

time_axis = linspace(-200, 500, 616);

for f = 1:length(foi)
    cd(['C:\Users\ts39233.AUSTIN\Box\' sub{s}]);
    subplot(4,2,f)
    cd([files(foi(f)).name])
    disp([files(foi(f)).name])
    [signal, header] = sload([files(foi(f)).name '.gdf']);
    [erp, erp_amp] = get_erp(signal,header);
    plot(time_axis, erp(6,:), 'k', LineWidth=2);
%     hold on; plot(time_axis, ret(6,:), 'r', LineWidth=2);
    xline(0,'k--'); ylim([-10 15])
    name = [files(foi(f)).name '.gdf'];
    if isnumeric(str2num(name(end-4)))
        title(['ERP for set size ' name(end-4)]);
    else
        title('Control')
    end
    
    master(:,:,f) = erp;
    amplitude = [amplitude; erp_amp(6,:)'];
end

%% compile erp
master_data = [];
for i = 1:8
    master_data = [master_data; master(:,:,i)' i*ones(616,1)];
end

master_data = master_data';

%%

clc;clear;
cd('C:\Users\ts39233.AUSTIN\Box\School\Spring 23\ECE 385J NE\Project\eeglab2020_0\eeglab2020_0\');
addpath(genpath(pwd));
cd('C:\Users\ts39233.AUSTIN\Box\School\Spring 23\ECE 385J NE\Project\biosigToolBox\biosigToolBox');
addpath(genpath(pwd));

cd('C:\Users\ts39233.AUSTIN\Downloads\ica data\ica data');
eeglab;

files = dir('C:\Users\ts39233.AUSTIN\Downloads\ica data\ica data\*.set');
files = sort(files.name, 'ascend');

for i = 1:length(files)
    EEG = pop_loadset(['C:\Users\ts39233.AUSTIN\Downloads\ica data\ica data\' files(i).name]);




