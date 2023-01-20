%% This is a template to run summarize.m on a list of metrics automatically.
% In this template, the metrics are:
% 'freq' 'Amplitude' 'N' 'g' 'tau' 'memTau' 'inputR' 'capacitance'

%% Input data

% Load fileIndex and groupIndex
fileIndexPath = 'path/to/fileIndex.xlsx';
groupIndexPath = 'path/to/groupIndex.mat';  % leave blank if no existing groupIndex
fileIndex = readIndex(fileIndexPath);
load(groupIndexPath);

% Load input data
sortedDataPath = 'path/to/sortedData.mat';
decayReportPath = 'path/to/decayReport.mat';
nsfaReportPath = 'path/to/nsfaReport.mat';
memPropReportPath = 'path/to/memPropReport.mat';

% Combine data into one table and clean the data
prepData;
data = cleanData(data);

%% Output directory for the results
outputDir = 'path/to/output_directory';

% Check if outputDir exists
if ~available(outputDir,'w')
    return
else
    mkdir(outputDir);
end

%% Metrics to summarize
metrics = {'freq' 'Amplitude' 'N' 'g' 'tau' 'memTau' 'inputR' 'capacitance'};

%% Run summarize.m
for m = 1:length(metrics)
    summary = summarize(data,groupIndex,fileIndex,metrics{m});
    writetable(summary,[outputDir 'summaryStats.xlsx'], ...
        'FileType','spreadsheet','Sheet',metrics{m},'WriteRowNames',true);
end

