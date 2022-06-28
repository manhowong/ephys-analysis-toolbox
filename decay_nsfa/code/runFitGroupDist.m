%% This is a script for fitting decay parameter distribution.
% Each mEPSC event will be fitted to a first order exponential function.
% This script runs fitGroupDist.m automatically on one recording or a group
% of recordings in a folder.

%%
r2Thres = 0.5;
nResample = 500;
nBoot = 100;
jitter = true;

resultDir = 'C:\Users\manho\OneDrive - University of Pittsburgh\M and M\MATLAB scripts\manhoscripts\decayAndNSFA\data\all\group_dist\';
% mkdir(resultDir);

% reportByGroup = getReportByGroup(groupIndex, nsfaReport, decayReport);

distReport = table;
nBoot = 1;
for g = 1:height(reportByGroup)
    if ~isempty(reportByGroup.decay{g})
        decayReport = reportByGroup.decay{g};
        groupName = reportByGroup.Properties.RowNames(g);
        [distReport.Info{g}, fig] = ...
        fitGroupDist(decayReport,groupName,r2Thres,nBoot,nResample,jitter);
        distReport.Properties.RowNames{g} = char(groupName);
        saveas(fig, [resultDir char(groupName)], 'png');
        close(fig);
    end
end

%%
% Save analysis report
save([resultDir 'distReport'],'distReport');
writetable(nsfaReport,[resultDir 'distReport.xlsx'],'WriteRowNames',true);
fprintf(['\nAnalysis completed!\n' ...
    'Figures and analysis reports were saved in %s.\n'], resultDir);
diary off
open distReport
