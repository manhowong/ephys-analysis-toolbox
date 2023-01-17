fileIndexPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\raw\fileIndex.xlsx';
groupIndexPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\event_stats_results\groupIndex.mat';  % leave blank if no existing groupIndex
fileIndex = readIndex(fileIndexPath);
load(groupIndexPath);

sortedDataPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\event_stats_results\sortedData.mat';
decayReportPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\decay\decayReport.mat';
nsfaReportPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\decay_nsfa_results\nsfa\nsfaReport.mat';
memPropReportPath = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\membrane_props\memPropReport.mat';

prepData;
data = cleanData(data);

outputDir = 'C:\Users\manho\OneDrive - University of Pittsburgh\data\ELE project\ephys\analysis\stats\';

% Check if outputDir exists
if ~available(outputDir,'w')
    return
else
    mkdir(outputDir);
end


metrics = {'freq' 'Amplitude' 'N' 'g' 'tau' 'memTau' 'inputR' 'capacitance'};

for m = 1:length(metrics)
    summary = summarize(data,groupIndex,fileIndex,metrics{m});
    writetable(summary,[outputDir 'summaryStats.xlsx'], ...
        'FileType','spreadsheet','Sheet',metrics{m},'WriteRowNames',true);
end

