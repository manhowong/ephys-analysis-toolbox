%% This is a script for fitting decay parameter distribution.
% Each mEPSC event will be fitted to a first order exponential function.
% This script runs fitGroupDist.m automatically on one recording or a group
% of recordings in a folder.

%% User settings

data = decayReport; % input data
subTableCol = 'events'; % by default, the column name is 'events'
varName = 'tau'; % Choose decay parameter (e.g. tau)
r2Thres = 0.5;  % filter data by r^2; set to 0 if not used

outputDir = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\group_dist\';
if available(outputDir, 'w')
    mkdir(outputDir);
else
    return
end

% Bootstrap settings
bootSettings.nResample = 500; % number of resampled events per recording
bootSettings.nBoot = 100; % number of bootstrap runs
bootSettings.jitter = true; % add random jitter to resampled events
 
% GM model settings
k = 2;  % number of components for GM model


%% Run fitGroupDist

distReport = table;
grpDistReport = table;
groups = groupIndex.Properties.RowNames;
for g = 1:height(groupIndex)
    fprintf('%d group(s) processed. Processing %s...\n', g-1, groups{g});
    groupedData = applyFilters(data,groupIndex,fileIndex,groups{g});
    if ~isempty(groupedData)
        [distReport.files{g}, grpResults, fig] = fitGroupDist(groupedData, ...
                                                 subTableCol, varName, ...
                                                 r2Thres, bootSettings, ...
                                                 groups{g}, k);
        distReport.Properties.RowNames{g} = char(groups{g});
        grpDistReport{groups{g},:} = grpResults;
        grpDistReport.Properties.VariableNames = ...
        {'mean','var','component_proportions','mergedData'};
        saveas(fig, [outputDir char(groups{g})]);
        saveas(fig, [outputDir char(groups{g})], 'png');
        close(fig);
    end
end

%% Save analysis report

save([outputDir 'distReport'],'distReport');
save([outputDir 'grpDistReport'],'grpDistReport');
fprintf(['\nDone!\n' ...
    'Figures and analysis reports were saved in %s.\n'], outputDir);
open grpDistReport
