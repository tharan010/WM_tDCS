clc; clear;

sub = {'6_20230406', '7_20230407', '8_20230407'};

%% erp data
s = 3; % subID - for loop

foi = [11 12 13]; %files of interest
files = dir(['C:\Users\Tharan Suresh\Box\' sub{s}]);
cd(['C:\Users\Tharan Suresh\Box\' sub{s}]);
time_axis = linspace(-200, 500, 616);

for f = 1:length(foi)
    cd(['C:\Users\Tharan Suresh\Box\' sub{s}]);
    subplot(4,2,f)
    cd([files(foi(f)).name])
    disp([files(foi(f)).name])
    [signal, header] = sload([files(foi(f)).name '.gdf']);
    [erp, erp_amp] = get_erp(signal,header);
    master(:,:,f) = erp;
    amplitude = [amplitude; erp_amp(6,:)'];
end